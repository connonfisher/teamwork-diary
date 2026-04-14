import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodiary/common/models/isar/diary.dart';
import 'package:moodiary/common/values/keyboard_state.dart';
import 'package:moodiary/components/keyboard_listener/keyboard_listener.dart';
import 'package:moodiary/persistence/isar.dart';
import 'package:moodiary/src/rust/api/jieba.dart';
import 'package:moodiary/utils/rust_util.dart';
import 'package:throttling/throttling.dart';

import 'search_sheet_state.dart';

class SearchSheetLogic extends GetxController {
  final SearchSheetState state = SearchSheetState();
  late TextEditingController textEditingController = TextEditingController();
  late FocusNode focusNode = FocusNode();

  late final KeyboardObserver _keyboardObserver;

  late final Throttling _throttling = Throttling(
    duration: const Duration(milliseconds: 500),
  );

  String _lastText = '';

  Timer? _timer;

  @override
  void onInit() {
    _keyboardObserver = KeyboardObserver(
      onHeightChanged: (height) {
        if (height > 0) {
          state.keyboardHeight.value = height;
        }
      },
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
    _keyboardObserver.start();
    textEditingController.addListener(() {
      _throttling.throttle(() async {
        await doSearch();
      });
    });

    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      final currentText = textEditingController.text.trim();
      if (currentText != _lastText) {
        _lastText = currentText;
        if (currentText.isNotBlank) {
          await doSearch();
        } else {
          clear();
        }
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    _keyboardObserver.stop();
    textEditingController.dispose();
    focusNode.dispose();
    _throttling.close();
    _timer?.cancel();
    _timer = null;
    super.onClose();
  }

  void unFocus() {
    focusNode.unfocus();
  }

  void clear() {
    state.searchList.clear();
    state.totalCount.value = 0;
    state.queryList = [];
    state.isSearching.value = false;
    update();
  }

  Future<void> doSearch() async {
    final currentText = textEditingController.text.trim();
    if (currentText.isBlank) {
      clear();
      return;
    }
    state.isSearching.value = true;
    _lastText = currentText;

    // ========== 分级搜索策略 ==========
    final rustReady = await RustUtil.waitForInit(
      timeout: const Duration(seconds: 1),
    );

    List<String> queryList = [];
    List<Diary> searchResults = [];

    if (rustReady) {
      try {
        // 方案A：使用 Jieba 分词搜索
        queryList = await JiebaRs.cutForSearch(text: _lastText, hmm: true);
        searchResults = await IsarUtil.searchDiaries(queryList: queryList);
      } catch (e) {
        // Jieba 失败，降级到简单搜索
        searchResults = await _simpleSearch(currentText);
        queryList = [currentText];
      }
    } else {
      // 方案B：简单搜索
      searchResults = await _simpleSearch(currentText);
      queryList = [currentText];
    }

    state.searchList = searchResults;
    state.totalCount.value = state.searchList.length;
    state.queryList = queryList;
    state.isSearching.value = false;
  }

  Future<List<Diary>> _simpleSearch(String keyword) async {
    // 简单搜索：直接搜索标题和内容
    final diaries = await IsarUtil.getAllDiariesSorted();
    return diaries.where((diary) {
      final titleMatch = diary.title.toLowerCase().contains(
        keyword.toLowerCase(),
      );
      final contentMatch = diary.contentText.toLowerCase().contains(
        keyword.toLowerCase(),
      );
      return titleMatch || contentMatch;
    }).toList();
  }
}
