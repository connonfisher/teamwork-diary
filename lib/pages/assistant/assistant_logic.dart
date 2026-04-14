import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodiary/api/api.dart';
import 'package:moodiary/common/models/ark.dart';
import 'package:moodiary/common/models/hunyuan.dart';
import 'package:moodiary/common/values/keyboard_state.dart';
import 'package:moodiary/components/keyboard_listener/keyboard_listener.dart';
import 'package:moodiary/utils/notice_util.dart';
import 'package:moodiary/utils/signature_util.dart';

import 'assistant_state.dart';

class AssistantLogic extends GetxController {
  final AssistantState state = AssistantState();

  //输入框控制器
  late TextEditingController textEditingController = TextEditingController();

  //控制器
  late ScrollController scrollController = ScrollController();

  //聚焦对象
  late FocusNode focusNode = FocusNode();
  late final KeyboardObserver keyboardObserver;

  List<double> heightList = [];

  @override
  void onInit() {
    keyboardObserver = KeyboardObserver(
      onStateChanged: (state) {
        switch (state) {
          case KeyboardState.opening:
            break;
          case KeyboardState.closing:
            unFocus();
            break;
          case KeyboardState.closed:
            break;
          case KeyboardState.unknown:
            break;
        }
      },
    );
    keyboardObserver.start();
    super.onInit();
  }

  @override
  void onClose() {
    keyboardObserver.stop();
    textEditingController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void handleBack() {
    if (focusNode.hasFocus) {
      unFocus();
      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    } else {
      Get.back();
    }
  }

  void unFocus() {
    focusNode.unfocus();
  }

  void newChat() {
    state.messages = {};
    update();
  }

  void clearText() {
    textEditingController.clear();
  }

  //对话 - 只使用火山方舟API
  Future<void> getAi(String ask) async {
    final check = SignatureUtil.checkArk();
    if (check != null) {
      clearText();
      unFocus();

      final askTime = DateTime.now();
      state.messages[askTime] = Message(role: 'user', content: ask);
      update();
      toBottom();

      // 转换为ArkMessage格式
      final arkMessages = state.messages.values
          .map((msg) => ArkMessage(role: msg.role, content: msg.content))
          .toList();

      final stream = await Api.getArkChat(
        check['apiKey']!,
        check['endpoint']!,
        arkMessages,
        state.modelVersion.value,
      );

      final replyTime = DateTime.now();
      state.messages[replyTime] = const Message(role: 'assistant', content: '');
      update();

      stream?.listen((content) {
        if (content != '' && content.contains('data')) {
          try {
            final dataPart = content.split('data: ')[1];
            if (dataPart.trim() != '[DONE]') {
              final ArkResponse result = ArkResponse.fromJson(
                jsonDecode(dataPart),
              );
              final currentMessage = state.messages[replyTime]!;
              if (result.choices != null &&
                  result.choices!.isNotEmpty &&
                  result.choices!.first.delta != null &&
                  result.choices!.first.delta!.content != null) {
                state.messages[replyTime] = currentMessage.copyWith(
                  content:
                      currentMessage.content +
                      result.choices!.first.delta!.content!,
                );
                update();
                toBottom();
              }
            }
          } catch (e) {
            // 忽略解析错误
          }
        }
      });
    }
  }

  void toBottom() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  String getText() {
    return textEditingController.text;
  }

  Future<void> checkGetAi() async {
    final text = getText();
    if (text != '') {
      await getAi(text);
    } else {
      toast.info(message: '还没有输入问题');
    }
  }

  void changeModel(version) {
    state.modelVersion.value = version;
    state.messages = {};
  }
}
