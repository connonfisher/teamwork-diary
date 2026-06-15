import 'package:flutter/material.dart';

class UpdateUtil {
  static TextSpan buildReleaseNote(
    String version,
    List<String> fix,
    List<String> add, {
    required BuildContext context,
  }) {
    // 创建一个文本段落列表，用于存放每个部分的文本段
    final List<TextSpan> children = [];
    final textStyle = context.textTheme;
    // 添加版本信息
    children.add(
      TextSpan(
        text: '$version\n',
        style: textStyle.titleSmall!.copyWith(fontWeight: FontWeight.bold),
      ),
    );

    // 添加新增内容
    if (add.isNotEmpty) {
      children.add(TextSpan(text: '新增:\n', style: textStyle.titleSmall));
      // 遍历新增内容列表，将每个新增项目添加到文本段落中
      for (final String item in add) {
        children.add(TextSpan(text: '• $item\n', style: textStyle.bodySmall));
      }
    }

    // 添加修复内容
    if (fix.isNotEmpty) {
      children.add(TextSpan(text: '修复:\n', style: textStyle.titleSmall));
      // 遍历修复内容列表，将每个修复项目添加到文本段落中
      for (final String item in fix) {
        children.add(TextSpan(text: '• $item\n', style: textStyle.bodySmall));
      }
    }
    children.add(const TextSpan(text: '\n'));
    // 返回包含所有文本段的 TextSpan 对象
    return TextSpan(children: children);
  }
}
