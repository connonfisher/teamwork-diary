import 'package:flutter/material.dart';
import 'package:moodiary/l10n/l10n.dart';

enum AppColorType {
  common(0),
  pantone(1);

  final int value;

  const AppColorType(this.value);
}

class AppColor {
  static List<Color> themeColorList = [
    //百草霜
    const Color(0xFF303030),
    //群青
    const Color(0xFF2E59A7),
    //青黛
    const Color(0xFF45465E),
    //水朱华
    const Color(0xFFA72126),
    //芰荷
    const Color(0xFF4F794A),
    //缃叶
    const Color(0xFFECD452),
  ];

  static List<Color> specialColorList = [
    // PANTONE 2025 Mocha Mousse
    const Color(0xFFA47B67),
  ];

  // PANTONE 2008 Blue Iris
  static Color answerColor = const Color(0xFF5A5B9F);

  static String colorName(index, BuildContext context) {
    return switch (index) {
      0 => context.l10n.colorNameBaiCaoShuang,
      1 => context.l10n.colorNameQunQin,
      2 => context.l10n.colorNameQinDai,
      3 => context.l10n.colorNameShuiZhuHua,
      4 => context.l10n.colorNameJiHe,
      5 => context.l10n.colorNameXiangYe,
      9990 => context.l10n.specialColorNameMochaMousse,
      _ => context.l10n.colorNameSystem,
    };
  }

  static List<Color> emoColorList = [
    const Color(0xFFFA4659),
    const Color(0xFF2EB872),
  ];

  // 扩展情绪调色盘（12色阶）
  static List<Color> extendedEmoColorList = [
    const Color(0xFF8B0000), // 深红 - 极度糟糕
    const Color(0xFFB22222), // 砖红 - 很差
    const Color(0xFFDC143C), // 猩红 - 糟糕
    const Color(0xFFFF6347), // 番茄红 - 不好
    const Color(0xFFFFA500), // 橙色 - 一般偏下
    const Color(0xFFFFD700), // 金色 - 中性
    const Color(0xFF9ACD32), // 黄绿 - 一般偏上
    const Color(0xFF7CCD7C), // 淡绿 - 不错
    const Color(0xFF458B74), // 青绿 - 好
    const Color(0xFF3CB371), // 中绿 - 很好
    const Color(0xFF2EB872), // 翠绿 - 优秀
    const Color(0xFF228B22), // 森林绿 - 完美
  ];

  // 预设情绪配置
  static Map<String, Map<String, dynamic>> presetEmotions = {
    'terrible': {'color': const Color(0xFF8B0000), 'label': '崩溃', 'value': 0.0},
    'sad': {'color': const Color(0xFFDC143C), 'label': '难过', 'value': 0.15},
    'bad': {'color': const Color(0xFFFF6347), 'label': '糟糕', 'value': 0.3},
    'neutral': {'color': const Color(0xFFFFD700), 'label': '平静', 'value': 0.5},
    'okay': {'color': const Color(0xFF9ACD32), 'label': '还行', 'value': 0.65},
    'good': {'color': const Color(0xFF458B74), 'label': '不错', 'value': 0.8},
    'great': {'color': const Color(0xFF2EB872), 'label': '开心', 'value': 0.95},
  };

  // 根据情绪值获取颜色（支持扩展色阶）
  static Color getEmotionColor(double value) {
    if (value <= 0.0) return extendedEmoColorList.first;
    if (value >= 1.0) return extendedEmoColorList.last;

    final index = (value * (extendedEmoColorList.length - 1)).round();
    return extendedEmoColorList[index.clamp(
      0,
      extendedEmoColorList.length - 1,
    )];
  }
}

class ShareCardColor {
  static List<Color> cardColorList = [
    const Color(0xFFF8F3D4),
    const Color(0xFFF5F5F5),
    const Color(0xFFFFFFFF),
    const Color(0xFF393e46),
    const Color(0xFF252A34),
    const Color(0xFF212121),
    const Color(0xFF000000),
  ];
}
