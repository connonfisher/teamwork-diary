import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:moodiary/components/base/tile/qr_tile.dart';
import 'package:moodiary/l10n/l10n.dart';
import 'package:moodiary/persistence/pref.dart';
import 'package:moodiary/utils/notice_util.dart';

import 'laboratory_logic.dart';

class LaboratoryPage extends StatelessWidget {
  const LaboratoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Bind.find<LaboratoryLogic>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingLab)),
      body: GetBuilder<LaboratoryLogic>(
        builder: (_) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            children: [
              QrInputTile(
                title: '${context.l10n.labTencentCloud} ID',
                value: PrefUtil.getValue<String>('tencentId') ?? '',
                prefix: 'tencentId',
                onValue: (value) async {
                  final res = await logic.setTencentID(id: value);
                  if (res) {
                    toast.success();
                  } else {
                    toast.error();
                  }
                },
              ),
              const Gap(12),
              QrInputTile(
                title: '${context.l10n.labTencentCloud} Key',
                value: PrefUtil.getValue<String>('tencentKey') ?? '',
                prefix: 'tencentKey',
                onValue: (value) async {
                  final res = await logic.setTencentKey(key: value);
                  if (res) {
                    toast.success();
                  } else {
                    toast.error();
                  }
                },
              ),
              const Gap(12),
              QrInputTile(
                title: '${context.l10n.labQweather} Key',
                value: PrefUtil.getValue<String>('qweatherKey') ?? '',
                prefix: 'qweatherKey',
                onValue: (value) async {
                  final res = await logic.setQweatherKey(key: value);
                  if (res) {
                    toast.success();
                  } else {
                    toast.error();
                  }
                },
              ),
              const Gap(12),
              QrInputTile(
                title: '${context.l10n.labQweather} API Host',
                value: PrefUtil.getValue<String>('qweatherApiHost') ?? '',
                prefix: 'qweatherApiHost',
                onValue: (value) async {
                  final res = await logic.setQweatherApiHost(host: value);
                  if (res) {
                    toast.success();
                  } else {
                    toast.error();
                  }
                },
              ),

              const Gap(12),
              QrInputTile(
                title: '${context.l10n.labTianditu} Key',
                value: PrefUtil.getValue<String>('tiandituKey') ?? '',
                prefix: 'tiandituKey',
                onValue: (value) async {
                  final res = await logic.setTiandituKey(key: value);
                  if (res) {
                    toast.success();
                  } else {
                    toast.error();
                  }
                },
              ),
              const Gap(12),
              const Divider(),
              const Gap(12),
              QrInputTile(
                title: '火山方舟 API Key',
                value: PrefUtil.getValue<String>('arkApiKey') ?? '',
                prefix: 'arkApiKey',
                onValue: (value) async {
                  final res = await logic.setArkApiKey(apiKey: value);
                  if (res) {
                    toast.success();
                  } else {
                    toast.error();
                  }
                },
              ),
              const Gap(12),
              QrInputTile(
                title: '火山方舟 Endpoint',
                value: PrefUtil.getValue<String>('arkEndpoint') ?? '',
                prefix: 'arkEndpoint',
                onValue: (value) async {
                  final res = await logic.setArkEndpoint(endpoint: value);
                  if (res) {
                    toast.success();
                  } else {
                    toast.error();
                  }
                },
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              GetBuilder<LaboratoryLogic>(
                id: 'MoodPalette',
                builder: (_) {
                  return SwitchListTile(
                    title: const Text('启用情绪调色盘'),
                    value:
                        PrefUtil.getValue<bool>('moodPaletteEnabled') ?? true,
                    onChanged: (value) async {
                      final res = await logic.setMoodPaletteEnabled(
                        enabled: value,
                      );
                      if (res) {
                        toast.success();
                        logic.update(['MoodPalette']);
                      } else {
                        toast.error();
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              GetBuilder<LaboratoryLogic>(
                id: 'MoodPaletteStyle',
                builder: (_) {
                  return ListTile(
                    title: const Text('调色盘样式'),
                    subtitle: Text(
                      switch (PrefUtil.getValue<int>('moodPaletteStyle') ?? 0) {
                        0 => '默认样式',
                        1 => '简约样式',
                        _ => '默认样式',
                      },
                    ),
                    trailing: const Icon(Icons.arrow_right_rounded),
                    onTap: () async {
                      final result = await showModalActionSheet<int>(
                        context: context,
                        actions: [
                          const SheetAction(key: 0, label: '默认样式'),
                          const SheetAction(key: 1, label: '简约样式'),
                        ],
                      );
                      if (result != null) {
                        final res = await logic.setMoodPaletteStyle(
                          style: result,
                        );
                        if (res) {
                          toast.success();
                          logic.update(['MoodPaletteStyle']);
                        } else {
                          toast.error();
                        }
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              GetBuilder<LaboratoryLogic>(
                id: 'AiMoodRecommend',
                builder: (_) {
                  return SwitchListTile(
                    title: const Text('启用AI情绪推荐'),
                    value: PrefUtil.getValue<bool>('aiMoodRecommend') ?? true,
                    onChanged: (value) async {
                      final res = await logic.setAiMoodRecommend(
                        enabled: value,
                      );
                      if (res) {
                        toast.success();
                        logic.update(['AiMoodRecommend']);
                      } else {
                        toast.error();
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              GetBuilder<LaboratoryLogic>(
                id: 'MoodTrendChart',
                builder: (_) {
                  return SwitchListTile(
                    title: const Text('启用情绪趋势图'),
                    value: PrefUtil.getValue<bool>('moodTrendChart') ?? true,
                    onChanged: (value) async {
                      final res = await logic.setMoodTrendChart(enabled: value);
                      if (res) {
                        toast.success();
                        logic.update(['MoodTrendChart']);
                      } else {
                        toast.error();
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                onTap: () async {
                  logic.exportErrorLog();
                },
                title: const Text('导出日志文件'),
              ),
              const Gap(12),
              ListTile(
                onTap: () async {
                  final res = await logic.aesTest();
                  if (res) {
                    toast.success(message: '加密测试通过');
                  } else {
                    toast.error(message: '加密测试失败');
                  }
                },
                title: const Text('加密测试'),
              ),
              const Gap(12),
              ListTile(
                onTap: () async {
                  final res = await logic.clearImageThumbnail();
                  if (res) {
                    toast.success(message: '清理成功');
                  } else {
                    toast.error(message: '清理失败');
                  }
                },
                title: const Text('清理图片缩略图缓存'),
              ),
              const Gap(12),
              ListTile(
                onTap: () async {
                  final res = logic.generateFTSAndKeyword();
                  if (res) {
                    toast.success(message: '重新生成成功');
                  } else {
                    toast.error(message: '重新生成失败');
                  }
                },
                title: const Text('重新进行全文搜索索引'),
              ),
            ],
          );
        },
      ),
    );
  }
}
