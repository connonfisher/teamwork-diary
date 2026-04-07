import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:moodiary/api/api.dart';
import 'package:moodiary/common/models/ark.dart';
import 'package:moodiary/common/models/isar/diary.dart';
import 'package:moodiary/common/values/diary_type.dart';
import 'package:moodiary/common/values/keyboard_state.dart';
import 'package:moodiary/components/base/text.dart';
import 'package:moodiary/components/keyboard_listener/keyboard_listener.dart';
import 'package:moodiary/components/quill_embed/audio_embed.dart';
import 'package:moodiary/components/quill_embed/image_embed.dart';
import 'package:moodiary/components/quill_embed/text_indent.dart';
import 'package:moodiary/components/quill_embed/video_embed.dart';
import 'package:moodiary/l10n/l10n.dart';
import 'package:moodiary/persistence/isar.dart';
import 'package:moodiary/persistence/pref.dart';
import 'package:moodiary/router/app_routes.dart';
import 'package:moodiary/src/rust/api/jieba.dart';
import 'package:moodiary/src/rust/api/kmp.dart';
import 'package:moodiary/utils/file_util.dart';
import 'package:moodiary/utils/markdown_util.dart';
import 'package:moodiary/utils/media_util.dart';
import 'package:moodiary/utils/notice_util.dart';
import 'package:moodiary/utils/rust_util.dart';
import 'package:moodiary/utils/signature_util.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import 'edit_state.dart';

class EditLogic extends GetxController {
  final EditState state = EditState();

  //标题
  late final TextEditingController titleTextEditingController =
      TextEditingController();

  //编辑器控制器
  QuillController? quillController;

  // markdown控制器
  TextEditingController? markdownTextEditingController;

  //聚焦对象
  late FocusNode contentFocusNode = FocusNode();
  late FocusNode titleFocusNode = FocusNode();
  Timer? _timer;

  late final KeyboardObserver keyboardObserver;

  @override
  void onInit() {
    if (state.showWriteTime) _calculateDuration();
    keyboardObserver = KeyboardObserver(
      onHeightChanged: (_) {},
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
  void onReady() async {
    await _initEdit();
    quillController?.addListener(_listenCount);
    markdownTextEditingController?.addListener(_listenCount);
    if (state.firstLineIndent) {
      quillController?.document.changes.listen((change) {
        final operations = change.change.operations;
        final lastOperation = operations.last;
        if (lastOperation.key == 'insert' && lastOperation.value == '\n') {
          insertNewLine();
        }
      });
    }
    super.onReady();
  }

  @override
  void onClose() {
    keyboardObserver.stop();
    titleTextEditingController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    quillController?.dispose();
    markdownTextEditingController?.dispose();
    _timer?.cancel();
    _timer = null;
    super.onClose();
  }

  Future<void> _initEdit() async {
    //如果是新增，更具不同的分类展示不同的操作
    if (Get.arguments.runtimeType == List<Object?>) {
      // 配置日记类型
      state.type = Get.arguments[0] as DiaryType;
      switch (state.type) {
        case DiaryType.text:
        case DiaryType.richText:
          quillController = QuillController.basic();
        case DiaryType.markdown:
          markdownTextEditingController = TextEditingController();
      }
      state.currentDiary = Diary()..type = state.type.value;
      if (state.firstLineIndent) insertNewLine();
      if (state.autoWeather) {
        unawaited(getPositionAndWeather(context: Get.context!));
      }
      if (state.autoCategory) selectCategory(Get.arguments[1] as String?);
    } else {
      //如果是编辑，将日记对象赋值
      state.isNew = false;
      state.originalDiary = Get.arguments as Diary;
      state.type = DiaryType.values.firstWhere(
        (type) => type.value == state.originalDiary!.type,
      );
      state.currentDiary = state.originalDiary!.clone();
      // 获取分类名称
      if (state.originalDiary!.categoryId != null) {
        state.categoryName = IsarUtil.getCategoryName(
          state.originalDiary!.categoryId!,
        )!.categoryName;
      }
      // 初始化标题控制器
      titleTextEditingController.text = state.originalDiary!.title;
      // 待替换的字符串map
      final Map<String, String> replaceMap = {};
      //临时拷贝一份图片数据
      for (final name in state.originalDiary!.imageName) {
        // 生成一个临时文件
        final xFile = XFile(FileUtil.getRealPath('image', name));
        replaceMap[name] = xFile.path;
        state.imageFileList.add(xFile);
      }
      //临时拷贝一份拷贝音频数据到缓存目录
      for (final name in state.originalDiary!.audioName) {
        state.audioNameList.add(name);
        await File(
          FileUtil.getRealPath('audio', name),
        ).copy(FileUtil.getCachePath(name));
      }
      //临时拷贝一份视频数据，别忘记了缩略图
      for (final name in state.originalDiary!.videoName) {
        // 生成一个临时文件
        final videoXFile = XFile(FileUtil.getRealPath('video', name));
        replaceMap[name] = videoXFile.path;
        state.videoFileList.add(videoXFile);
      }
      switch (state.type) {
        case DiaryType.text:
        case DiaryType.richText:
          quillController = QuillController(
            document: Document.fromJson(
              jsonDecode(
                await Kmp.replaceWithKmp(
                  text: state.originalDiary!.content,
                  replacements: replaceMap,
                ),
              ),
            ),
            selection: const TextSelection.collapsed(offset: 0),
          );
        case DiaryType.markdown:
          markdownTextEditingController = TextEditingController(
            text: await Kmp.replaceWithKmp(
              text: state.originalDiary!.content,
              replacements: replaceMap,
            ),
          );
      }
      state.totalCount.value = _toPlainText().length;
    }
    state.isInit = true;
    update(['body']);
  }

  //计算写作时长
  void _calculateDuration() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state.duration += const Duration(seconds: 1);
      state.durationString.value = state.duration
          .toString()
          .split('.')[0]
          .padLeft(8, '0');
    });
  }

  String _toPlainText() {
    return state.type == DiaryType.markdown
        ? _markdownToPlainText(markdownTextEditingController!.text)
        : quillController!.document.toPlainText([
            ImageEmbedBuilder(isEdit: true),
            VideoEmbedBuilder(isEdit: true),
            AudioEmbedBuilder(isEdit: true),
            TextIndentEmbedBuilder(isEdit: true),
          ]).trim();
  }

  String _markdownToPlainText(String markdown) {
    if (markdown.isEmpty) return '';

    return MarkdownConverter.convert(markdown);
  }

  void _listenCount() {
    state.totalCount.value =
        markdownTextEditingController?.text.length ??
        quillController?.selection.baseOffset ??
        0;
  }

  // 插入换行时自动首行缩进
  void insertNewLine() {
    if (quillController == null) return;
    final index = quillController!.selection.baseOffset;
    final length = quillController!.selection.extentOffset - index;
    quillController?.replaceText(
      index,
      length,
      const TextIndentEmbed('2'),
      null,
    );
    quillController?.moveCursorToPosition(index + 1);
  }

  void insertNewImage({required String imagePath}) {
    if (quillController == null) return;
    final imageBlock = ImageBlockEmbed.fromName(imagePath);
    final index = quillController!.selection.baseOffset;
    final length = quillController!.selection.extentOffset - index;
    quillController?.replaceText(index, length, imageBlock, null);
    quillController?.moveCursorToPosition(index + 1);
  }

  void insertNewVideo({required String videoPath}) {
    if (quillController == null) return;
    final videoBlock = VideoBlockEmbed.fromName(videoPath);
    final index = quillController!.selection.baseOffset;
    final length = quillController!.selection.extentOffset - index;
    quillController?.replaceText(index, length, videoBlock, null);
    //插入一个换行
    quillController?.moveCursorToPosition(index + 1);
  }

  Future<void> addNewImage(XFile xFile, {bool isMarkdown = false}) async {
    state.imageFileList.add(xFile);
    if (!isMarkdown) insertNewImage(imagePath: xFile.path);
    update(['Image']);
  }

  // 多张图片

  Future<void> pickMultiPhoto(BuildContext context) async {
    final List<XFile> photoList = await MediaUtil.pickMultiPhoto(10);
    if (photoList.isNotEmpty && context.mounted) {
      Navigator.pop(context);
      for (final photo in photoList) {
        await addNewImage(photo, isMarkdown: false);
      }
      return;
    } else {
      if (!context.mounted) return;
      toast.info(message: context.l10n.cancelSelect);
    }
  }

  //单张照片
  Future<void> pickPhoto(
    ImageSource imageSource,
    BuildContext context, {
    bool isMarkdown = false,
  }) async {
    //获取一张图片
    final XFile? photo = await MediaUtil.pickPhoto(imageSource);
    if (photo != null && context.mounted) {
      Navigator.pop<String>(context, photo.path);
      await addNewImage(photo, isMarkdown: isMarkdown);
    } else {
      if (!context.mounted) return;
      toast.info(message: context.l10n.cancelSelect);
    }
  }

  //画图照片
  Future<void> pickDraw(Uint8List dataList, BuildContext context) async {
    final path = FileUtil.getCachePath('${const Uuid().v7()}.png');
    Navigator.pop(context, path);
    addNewImage(XFile.fromData(dataList, path: path)..saveTo(path));
  }

  //网络图片
  Future<void> networkImage(BuildContext context) async {
    toast.info(message: context.l10n.imageFetching);
    final imageUrl = await Api.updateImageUrl();
    if (imageUrl == null && context.mounted) {
      toast.error(message: context.l10n.imageFetchError);
      return;
    }
    final imageData = await Api.getImageData(imageUrl!.first);
    if (imageData == null && context.mounted) {
      toast.error(message: context.l10n.imageFetchError);
      return;
    }
    final path = FileUtil.getCachePath('${const Uuid().v7()}.png');
    if (context.mounted) Navigator.pop(context, path);
    addNewImage(XFile.fromData(imageData!, path: path)..saveTo(path));
  }

  Future<void> addNewVideo(XFile xFile) async {
    //视频list中新增一个
    state.videoFileList.add(xFile);
    insertNewVideo(videoPath: xFile.path);
    update(['Video']);
  }

  //选择视频
  Future<void> pickVideo(ImageSource imageSource, BuildContext context) async {
    // 获取一个视频
    final XFile? video = await MediaUtil.pickVideo(imageSource);
    if (video != null && context.mounted) {
      Navigator.pop(context);
      await addNewVideo(video);
    } else {
      if (!context.mounted) return;
      toast.info(message: context.l10n.cancelSelect);
    }
  }

  //预览图片
  // void toPhotoView(List<String> imagePath, int index) {
  //   Get.toNamed(AppRoutes.photoPage, arguments: [imagePath, index]);
  // }

  //预览视频
  // void toVideoView(List<String> videoPath, int index) {
  //   Get.toNamed(AppRoutes.videoPage, arguments: [videoPath, index]);
  // }

  //删除图片
  void deleteImage({required String path}) async {
    // 移除这个图片
    state.imageFileList.removeWhere((file) => file.path == path);
    await FileUtil.deleteFile(path);
    //Get.backLegacy();
    toast.success(message: '删除成功');
    update(['Image']);
  }

  //长按设置封面
  void setCover(int index) {
    final coverFile = state.imageFileList[index];
    state.imageFileList
      ..removeAt(index)
      ..insert(0, coverFile);
    toast.info(message: '设置第${index + 1}张图片为封面');
    update(['Image']);
  }

  //获取封面颜色
  Future<int?> getCoverColor() async {
    if (state.imageFileList.isNotEmpty) {
      return await MediaUtil.getColorScheme(
        FileImage(File(state.imageFileList.first.path)),
      );
    } else {
      return null;
    }
  }

  //获取封面比例
  Future<double?> getCoverAspect() async {
    //如果有封面就获取
    if (state.imageFileList.isNotEmpty) {
      return await MediaUtil.getImageAspectRatio(
        FileImage(File(state.imageFileList.first.path)),
      );
    } else {
      return null;
    }
  }

  //保存日记
  Future<void> saveDiary({required BuildContext context}) async {
    try {
      state.isSaving = true;
      update(['modal']);

      // 步骤1：进行AI情绪检测（仅当API配置完成且启用时）
      double? detectedMood;
      final aiMoodRecommend =
          PrefUtil.getValue<bool>('aiMoodRecommend') ?? true;
      final arkCheck = SignatureUtil.checkArk();

      if (aiMoodRecommend && arkCheck != null) {
        try {
          detectedMood = await _aiDetectMoodOnSave();
          if (detectedMood != null) {
            state.currentDiary.mood = detectedMood;
            update(['Mood']);
          }
        } catch (e) {
          // AI检测失败不影响保存
        }
      }

      // 步骤2：尝试使用 Rust 库处理内容（如果已初始化），否则降级处理
      final originContent = state.type == DiaryType.markdown
          ? markdownTextEditingController!.text.trim()
          : jsonEncode(quillController!.document.toDelta().toJson());

      final rustReady = await RustUtil.waitForInit(
        timeout: const Duration(seconds: 1),
      );

      Map<String, String> imageNameMap = {};
      Map<String, String> videoNameMap = {};
      Map<String, String> audioNameMap = {};
      String content = originContent;
      final contentText = _toPlainText().removeLineBreaks();
      List<String> tokenizer = [];
      List<String> sortedKeywords = [];

      if (rustReady) {
        try {
          // 使用 KMP 处理媒体文件
          final needImage = await Kmp.findMatches(
            text: originContent,
            patterns: state.imagePathList,
          );
          final needVideo = await Kmp.findMatches(
            text: originContent,
            patterns: state.videoPathList,
          );
          final needAudio = await Kmp.findMatches(
            text: originContent,
            patterns: state.audioNameList,
          );
          state.imageFileList.removeWhere(
            (file) => !needImage.contains(file.path),
          );
          state.videoFileList.removeWhere(
            (file) => !needVideo.contains(file.path),
          );
          state.audioNameList.removeWhere((name) => !needAudio.contains(name));

          // 保存媒体文件
          imageNameMap = await MediaUtil.saveImages(
            imageFileList: state.imageFileList,
          );
          videoNameMap = await MediaUtil.saveVideo(
            videoFileList: state.videoFileList,
          );
          audioNameMap = await MediaUtil.saveAudio(state.audioNameList);

          // 替换内容中的媒体文件路径
          content = await Kmp.replaceWithKmp(
            text: originContent,
            replacements: {...imageNameMap, ...videoNameMap, ...audioNameMap},
          );

          // 使用 Jieba 进行分词和关键词提取
          tokenizer = await JiebaRs.cutAll(text: contentText);
          final keywords = await JiebaRs.extractKeywordsTfidf(
            text: contentText,
            topK: BigInt.from(5),
            allowedPos: [],
          );
          final sortByWeight = keywords
            ..sort((a, b) => b.weight.compareTo(a.weight));
          sortedKeywords = sortByWeight.map((e) => e.keyword).toList();
        } catch (e) {
          // Rust 调用失败，使用降级方案
          imageNameMap = {};
          videoNameMap = {};
          audioNameMap = {};
          content = originContent;
          tokenizer = [];
          sortedKeywords = [];
        }
      } else {
        // Rust 未初始化，使用降级方案
        imageNameMap = {};
        videoNameMap = {};
        audioNameMap = {};
        content = originContent;
        tokenizer = [];
        sortedKeywords = [];
      }

      // 步骤5：更新日记对象
      state.currentDiary
        ..title = titleTextEditingController.text
        ..content = content
        ..type = state.type.value
        ..contentText = contentText
        ..audioName = state.audioNameList
        ..imageName = imageNameMap.values.toList()
        ..videoName = videoNameMap.values.toList()
        ..tokenizer = tokenizer
        ..keywords = sortedKeywords
        ..imageColor = await getCoverColor()
        ..aspect = await getCoverAspect();

      // 步骤6：保存到数据库
      await IsarUtil.updateADiary(
        oldDiary: state.originalDiary,
        newDiary: state.currentDiary,
      );

      // 步骤7：先显示成功提示
      if (context.mounted) {
        toast.success(
          message: state.isNew
              ? context.l10n.editSaveSuccess
              : context.l10n.editChangeSuccess,
        );
      }

      // 步骤8：显示情绪评级（如果检测成功）
      if (detectedMood != null && context.mounted) {
        final moodText = _getMoodRatingText(detectedMood);
        toast.info(message: moodText);
      }

      // 步骤9：短暂延迟后返回
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        state.isNew
            ? Get.back(result: state.currentDiary.categoryId ?? '')
            : Get.back(result: 'changed');
      }
    } catch (e) {
      // 错误处理
      if (context.mounted) {
        toast.error(message: '保存失败，请重试\n${e.toString()}');
      }
    } finally {
      state.isSaving = false;
      update(['modal']);
    }
  }

  DateTime? oldTime;

  void handleBack({required BuildContext context}) {
    final DateTime currentTime = DateTime.now();
    if (oldTime != null &&
        currentTime.difference(oldTime!) < const Duration(seconds: 3)) {
      Get.back();
    } else {
      oldTime = currentTime;
      toast.info(message: context.l10n.backAgainToExit);
    }
  }

  Future<void> changeDate({required BuildContext context}) async {
    final nowDateTime = await showDatePicker(
      context: context,
      initialDate: state.currentDiary.time,
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
    );
    if (nowDateTime != null) {
      state.currentDiary.time = state.currentDiary.time.copyWith(
        year: nowDateTime.year,
        month: nowDateTime.month,
        day: nowDateTime.day,
      );
      update(['Date']);
    }
  }

  Future<void> changeTime({required BuildContext context}) async {
    final nowTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(state.currentDiary.time),
    );
    if (nowTime != null) {
      state.currentDiary.time = state.currentDiary.time.copyWith(
        hour: nowTime.hour,
        minute: nowTime.minute,
      );
      update(['Date']);
    }
  }

  void unFocus() {
    titleFocusNode.unfocus();
    contentFocusNode.unfocus();
  }

  //去画画
  void toDrawPage(BuildContext context) {
    unFocus();
    Get.toNamed(AppRoutes.drawPage);
  }

  void changeRate(value) {
    state.currentDiary.mood = value;
    update(['Mood']);
  }

  //获取天气，同时获取定位
  Future<void> getPositionAndWeather({required BuildContext context}) async {
    final key = PrefUtil.getValue<String>('qweatherKey');
    final apiHost = PrefUtil.getValue<String>('qweatherApiHost');
    if (key.isNullOrBlank || apiHost.isNullOrBlank) return;

    try {
      state.isProcessing = true;
      update(['Weather']);

      // 获取定位
      final position = await Api.updatePosition(context);
      if (position == null && context.mounted) {
        _handleError(context, context.l10n.locationError);
        return;
      }
      state.currentDiary.position = position!;
      if (!context.mounted) return;
      // 获取天气
      final weather = await Api.updateWeather(
        context: context,
        position: LatLng(double.parse(position[0]), double.parse(position[1])),
      );
      if (weather == null && context.mounted) {
        _handleError(context, context.l10n.weatherError);
        return;
      }
      state.currentDiary.weather = weather!;
      state.isProcessing = false;
      if (context.mounted) {
        toast.success(message: context.l10n.weatherSuccess);
      }
      update(['Weather']);
    } catch (e) {
      state.isProcessing = false;
      update(['Weather']);
      if (context.mounted) {
        toast.error(message: context.l10n.weatherError);
      }
    }
  }

  void _handleError(BuildContext context, String message) {
    state.isProcessing = false;
    update(['Weather']);
    if (context.mounted) {
      toast.error(message: message);
    }
  }

  Future<void> pickAudio(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
        withReadStream: true,
      );

      if (result == null && context.mounted) {
        toast.info(message: context.l10n.cancelSelect);
        return;
      }

      final pickedFile = result!.files.single;
      final originalFileName = pickedFile.name;
      final fileExtension = extension(originalFileName);

      final audioName = 'audio-${const Uuid().v7()}$fileExtension';
      final cachePath = FileUtil.getCachePath(audioName);

      await pickedFile.readStream!.pipe(File(cachePath).openWrite());

      if (context.mounted) {
        Navigator.pop(context);
      }

      setAudioName(audioName);
    } catch (e) {
      if (!context.mounted) return;
      toast.error(message: context.l10n.audioFileError);
    }
  }

  //获取音频名称
  void setAudioName(String name) {
    if (quillController == null) return;
    state.audioNameList.add(name);
    final audioBlock = AudioBlockEmbed.fromName(name);
    final index = quillController!.selection.baseOffset;
    final length = quillController!.selection.extentOffset - index;
    // 插入音频 Embed
    quillController?.replaceText(index, length, audioBlock, null);
    quillController?.moveCursorToPosition(index + 1);
    update(['Audio']);
  }

  //删除音频
  Future<void> deleteAudio(String path) async {
    // 删除文件
    await FileUtil.deleteFile(path);
    // 删除对应的组件
    state.audioNameList.removeWhere((name) => path.endsWith(name));
    update(['Audio']);
    toast.success(message: '删除成功');
  }

  //添加一个标签
  void addTag({required String tag, required BuildContext context}) {
    tag = tag.trim();
    if (tag.isNotEmpty) {
      if (state.currentDiary.tags.contains(tag)) {
        toast.info(message: context.l10n.editAddTagAlreadyExist);
        return;
      }
      state.currentDiary.tags.add(tag);
      update(['Tag']);
    } else {
      toast.info(message: context.l10n.editAddTagCannotEmpty);
    }
  }

  //移除一个标签
  void removeTag(index) {
    state.currentDiary.tags.removeAt(index);
    update(['Tag']);
  }

  void selectCategory(String? id) {
    state.currentDiary.categoryId = id;
    if (id == null) {
      state.categoryName = '';
    } else {
      final category = IsarUtil.getCategoryName(id);
      if (category != null) {
        state.categoryName = category.categoryName;
      }
    }
    update(['CategoryName']);
  }

  void renderMarkdown() {
    state.renderMarkdown.value = !state.renderMarkdown.value;
  }

  void focusContent() {
    if (!contentFocusNode.hasFocus) contentFocusNode.requestFocus();
  }

  // AI情绪推荐
  Future<void> aiRecommendMood(BuildContext context) async {
    final content = _toPlainText();
    if (content.isEmpty) {
      toast.info(message: '请先写点内容~');
      return;
    }

    final arkCheck = SignatureUtil.checkArk();
    if (arkCheck == null) {
      toast.info(message: '请先在实验室配置火山方舟API');
      return;
    }

    toast.info(message: 'AI正在分析您的情绪...');
    state.loadingAiMood = true;
    update(['AiMood']);

    try {
      final stream = await Api.getArkChat(
        arkCheck['apiKey']!,
        arkCheck['endpoint']!,
        [
          ArkMessage(
            role: 'system',
            content:
                '你是一个专业的情绪分析师。请根据用户提供的日记内容，分析用户的情绪状态，并返回一个0.0到1.0之间的数值，其中0.0表示非常糟糕，1.0表示非常好。请只返回一个数字，不要有其他任何文字。',
          ),
          ArkMessage(role: 'user', content: content),
        ],
        1,
      );

      if (stream != null) {
        String result = '';
        await for (final content in stream) {
          if (content.isNotEmpty && content.contains('data')) {
            try {
              final dataPart = content.split('data: ')[1];
              if (dataPart.trim() != '[DONE]') {
                final ArkResponse arkResult = ArkResponse.fromJson(
                  jsonDecode(dataPart),
                );
                if (arkResult.choices != null &&
                    arkResult.choices!.isNotEmpty &&
                    arkResult.choices!.first.delta != null &&
                    arkResult.choices!.first.delta!.content != null) {
                  result += arkResult.choices!.first.delta!.content!;
                }
              }
            } catch (e) {
              // 忽略解析错误
            }
          }
        }

        // 尝试从结果中提取数字
        final match = RegExp(r'(\d+\.?\d*)').firstMatch(result);
        if (match != null) {
          final moodValue = double.tryParse(match.group(1)!);
          if (moodValue != null) {
            final clampedMood = moodValue.clamp(0.0, 1.0);
            state.currentDiary.mood = clampedMood;
            toast.success(message: 'AI推荐成功！');
            update();
          } else {
            toast.error(message: '无法解析AI返回的结果');
          }
        } else {
          toast.error(message: '无法解析AI返回的结果');
        }
      }
    } catch (e) {
      toast.error(message: 'AI分析失败，请稍后再试');
    } finally {
      state.loadingAiMood = false;
      update(['AiMood']);
    }
  }

  // 获取情绪评级文本
  String _getMoodRatingText(double mood) {
    if (mood >= 0.9) return '😊 非常开心';
    if (mood >= 0.7) return '🙂 心情不错';
    if (mood >= 0.5) return '😐 一般般';
    if (mood >= 0.3) return '😔 有点低落';
    return '😢 很不开心';
  }

  // 保存日记时进行AI情绪检测
  Future<double?> _aiDetectMoodOnSave() async {
    final content = _toPlainText();
    if (content.isEmpty) return null;

    final arkCheck = SignatureUtil.checkArk();
    if (arkCheck == null) return null;

    try {
      final stream = await Api.getArkChat(
        arkCheck['apiKey']!,
        arkCheck['endpoint']!,
        [
          ArkMessage(
            role: 'system',
            content:
                '你是一个专业的情绪分析师。请根据用户提供的日记内容，分析用户的情绪状态，并返回一个0.0到1.0之间的数值，其中0.0表示非常糟糕，1.0表示非常好。请只返回一个数字，不要有其他任何文字。',
          ),
          ArkMessage(role: 'user', content: content),
        ],
        1,
        showErrorToast: false,
      );

      if (stream != null) {
        String result = '';
        await for (final content in stream) {
          if (content.isNotEmpty && content.contains('data')) {
            try {
              final dataPart = content.split('data: ')[1];
              if (dataPart.trim() != '[DONE]') {
                final ArkResponse arkResult = ArkResponse.fromJson(
                  jsonDecode(dataPart),
                );
                if (arkResult.choices != null &&
                    arkResult.choices!.isNotEmpty &&
                    arkResult.choices!.first.delta != null &&
                    arkResult.choices!.first.delta!.content != null) {
                  result += arkResult.choices!.first.delta!.content!;
                }
              }
            } catch (e) {}
          }
        }

        final match = RegExp(r'(\d+\.?\d*)').firstMatch(result);
        if (match != null) {
          final moodValue = double.tryParse(match.group(1)!);
          if (moodValue != null) {
            return moodValue.clamp(0.0, 1.0);
          }
        }
      }
    } catch (e) {
      // AI检测失败不阻塞保存
    }
    return null;
  }
}
