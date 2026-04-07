import 'package:flutter/material.dart';

class WebDavOptions {
  static const String basePath = '/心色彩记';
  static const String imagePath = '/心色彩记/Asset/Image';
  static const String audioPath = '/心色彩记/Asset/Audio';
  static const String videoPath = '/心色彩记/Asset/Video';

  static const String diaryPath = '/心色彩记/Diary';
  static const String categoryPath = '/心色彩记/Category';

  //增量同步标记文件路径
  static const String syncFlagPath = '/心色彩记/sync.json';

  // 连通性颜色标记
  static const Color connectivityColor = Color(0xFF4CAF50);
  static const Color unConnectivityColor = Color(0xFFF44336);
  static const Color connectingColor = Color(0xFFFFC107);
}

enum WebDavConnectivityStatus { connected, unconnected, connecting }
