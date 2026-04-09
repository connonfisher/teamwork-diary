import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:moodiary/common/values/border.dart';
import 'package:moodiary/common/values/colors.dart';
import 'package:moodiary/common/values/language.dart';
import 'package:moodiary/components/base/clipper.dart';
import 'package:moodiary/components/base/sheet.dart';
import 'package:moodiary/components/base/text.dart';
import 'package:moodiary/components/base/tile/qr_tile.dart';
import 'package:moodiary/components/base/tile/setting_tile.dart';
import 'package:moodiary/components/color_sheet/color_sheet_view.dart';
import 'package:moodiary/components/dashboard/dashboard_view.dart';
import 'package:moodiary/components/language_dialog/language_dialog_view.dart';
import 'package:moodiary/components/remove_password/remove_password_view.dart';
import 'package:moodiary/components/set_password/set_password_view.dart';
import 'package:moodiary/components/theme_mode_dialog/theme_mode_dialog_view.dart';
import 'package:moodiary/l10n/l10n.dart';
import 'package:moodiary/persistence/pref.dart';
import 'package:moodiary/utils/notice_util.dart';

import 'setting_logic.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(SettingLogic());
    final state = Bind.find<SettingLogic>().state;

    final size = MediaQuery.sizeOf(context);

    Widget buildDashboard() {
      return Column(
        children: [
          AdaptiveTitleTile(title: context.l10n.settingDashboard),
          const DashboardComponent(),
        ],
      );
    }

    Widget buildAFeatureButton({
      required Widget icon,
      required String text,
      required Function() onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.mediumBorderRadius,
        child: Card.outlined(
          color: context.theme.colorScheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                icon,
                AdaptiveText(
                  text,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildFeature() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdaptiveTitleTile(title: context.l10n.settingFunction),
          GridView(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100,
              childAspectRatio: 1.0,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              buildAFeatureButton(
                icon: Icon(
                  Icons.category_rounded,
                  color: context.theme.colorScheme.secondary,
                ),
                text: context.l10n.settingFunctionCategoryManage,
                onTap: logic.toCategoryManager,
              ),

              buildAFeatureButton(
                icon: FaIcon(
                  FontAwesomeIcons.solidMap,
                  color: context.theme.colorScheme.secondary,
                ),
                text: context.l10n.settingFunctionTrailMap,
                onTap: logic.toMap,
              ),
              buildAFeatureButton(
                icon: FaIcon(
                  FontAwesomeIcons.solidCommentDots,
                  color: context.theme.colorScheme.secondary,
                ),
                text: context.l10n.settingFunctionAIAssistant,
                onTap: logic.toAi,
              ),
            ],
          ),
        ],
      );
    }

    Widget buildData() {
      return Column(
        children: [
          AdaptiveTitleTile(title: context.l10n.settingData),
          Card.filled(
            color: context.theme.colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                AdaptiveListTile(
                  title: Text(context.l10n.settingRecycle),
                  isFirst: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    logic.toRecyclePage();
                  },
                  leading: const Icon(Icons.delete_rounded),
                ),
                AdaptiveListTile(
                  title: Text(context.l10n.settingDataSyncAndBackup),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    logic.toBackupAndSyncPage();
                  },
                  leading: const Icon(Icons.sync_rounded),
                ),
                AdaptiveListTile(
                  title: Text(context.l10n.settingClean),
                  leading: const Icon(Icons.cleaning_services_rounded),
                  isLast: true,
                  trailing: GetBuilder<SettingLogic>(
                    id: 'DataUsage',
                    builder: (_) {
                      return Text(
                        state.dataUsage,
                        style: context.textTheme.bodySmall!.copyWith(
                          color: context.theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    logic.deleteCache();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget buildDisplay() {
      return Column(
        children: [
          AdaptiveTitleTile(title: context.l10n.settingDisplay),
          Card.filled(
            color: context.theme.colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                AdaptiveListTile(
                  title: Text(context.l10n.settingDiary),
                  leading: const Icon(Icons.article_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  isFirst: true,
                  onTap: () {
                    logic.toDiarySettingPage();
                  },
                ),
                AdaptiveListTile(
                  title: Text(context.l10n.settingThemeMode),
                  leading: const Icon(Icons.invert_colors_rounded),
                  trailing: Text(
                    switch (state.themeMode) {
                      0 => context.l10n.themeModeSystem,
                      1 => context.l10n.themeModeLight,
                      2 => context.l10n.themeModeDark,
                      int() => throw UnimplementedError(),
                    },
                    style: context.textTheme.bodySmall!.copyWith(
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const ThemeModeDialogComponent();
                      },
                    );
                  },
                ),
                AdaptiveListTile(
                  title: Text(context.l10n.settingColor),
                  leading: const Icon(Icons.color_lens_rounded),
                  trailing: Text(
                    AppColor.colorName(state.color, context),
                    style: context.textTheme.bodySmall!.copyWith(
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                  onTap: () {
                    showFloatingModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return const ColorSheetComponent();
                      },
                    );
                  },
                ),
                AdaptiveListTile(
                  title: Text(context.l10n.settingFontStyle),
                  leading: const Icon(Icons.format_size_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    logic.toFontSizePage();
                  },
                ),
                AdaptiveListTile(
                  title: Text(context.l10n.settingHomepageName),
                  leading: const Icon(Icons.drive_file_rename_outline_rounded),
                  isLast: true,
                  trailing: GetBuilder<SettingLogic>(
                    id: 'CustomTitle',
                    builder: (_) {
                      return Text(
                        state.customTitle,
                        style: context.textTheme.bodySmall!.copyWith(
                          color: context.theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                  onTap: () async {
                    final res = await showTextInputDialog(
                      context: context,
                      textFields: [
                        DialogTextField(initialText: state.customTitle),
                      ],
                      title: context.l10n.settingHomepageName,
                    );
                    if (res != null) {
                      logic.setCustomTitle(title: res.first);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget buildPrivacy() {
      return Column(
        children: [
          AdaptiveTitleTile(title: context.l10n.settingPrivacy),
          Card.filled(
            color: context.theme.colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                // GetBuilder<SettingLogic>(
                //     id: 'Local',
                //     builder: (_) {
                //       return AdaptiveSwitchListTile(
                //         value: state.local,
                //         onChanged: null,
                //         title: Text(context.l10n.settingLocal),
                //         subtitle: Text(context.l10n.settingLocalDes),
                //         secondary: const Icon(Icons.cloud_off_rounded),
                //       );
                //     }),
                GetBuilder<SettingLogic>(
                  id: 'Lock',
                  builder: (_) {
                    return AdaptiveListTile(
                      trailing: Text(
                        state.lock
                            ? context.l10n.settingLockOpen
                            : context.l10n.settingLockNotOpen,
                        style: context.textTheme.bodySmall!.copyWith(
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                      isFirst: true,
                      onTap: () async {
                        final res = await showOkCancelAlertDialog(
                          context: context,
                          title: context.l10n.settingLock,
                          message: state.lock
                              ? context.l10n.settingLockResetLock
                              : context.l10n.settingLockChooseLockType,
                          okLabel: state.lock
                              ? context.l10n.settingLockClose
                              : context.l10n.settingLockTypeNumber,
                        );
                        if (res == OkCancelResult.ok && context.mounted) {
                          showFloatingModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return state.lock
                                  ? const RemovePasswordComponent()
                                  : const SetPasswordComponent();
                            },
                          );
                        }
                      },
                      title: Text(context.l10n.settingLock),
                      leading: const Icon(Icons.lock_rounded),
                    );
                  },
                ),
                Obx(() {
                  return QrInputTile(
                    title: context.l10n.settingUserKey,
                    value: state.userKey.value,
                    prefix: 'userKey',
                    onValue: (value) async {
                      final res = await logic.setUserKey(key: value);
                      if (res) {
                        toast.success();
                      } else {
                        toast.error();
                      }
                    },
                    onInput: () async {
                      if (state.userKey.value.isNotNullOrBlank) {
                        final res = await showOkCancelAlertDialog(
                          context: context,
                          title: context.l10n.settingUserKeyReset,
                          message: context.l10n.settingUserKeyResetDes,
                        );
                        if (res == OkCancelResult.ok) {
                          final res_ = await logic.removeUserKey();
                          if (res_) {
                            toast.success();
                          } else {
                            toast.error();
                          }
                        }
                        return;
                      } else {
                        final res = await showTextInputDialog(
                          title: context.l10n.settingUserKeySet,
                          message: context.l10n.settingUserKeySetDes,
                          context: context,
                          textFields: [const DialogTextField()],
                        );
                        if (res != null) {
                          final res_ = await logic.setUserKey(key: res.first);
                          if (res_) {
                            toast.success();
                          } else {
                            toast.error();
                          }
                        }
                      }
                    },
                    leading: const Icon(Icons.key_rounded),
                  );
                }),
                GetBuilder<SettingLogic>(
                  id: 'Lock',
                  builder: (_) {
                    return AdaptiveSwitchListTile(
                      value: state.lockNow,
                      onChanged: state.lock
                          ? (value) {
                              logic.lockNow(value);
                            }
                          : null,
                      title: Text(context.l10n.settingLockNow),
                      subtitle: context.l10n.settingLockNowDes,
                      secondary: const Icon(Icons.lock_clock_rounded),
                    );
                  },
                ),
                Obx(() {
                  return AdaptiveSwitchListTile(
                    value: state.backendPrivacy.value,
                    onChanged: logic.changeBackendPrivacy,
                    title: context.l10n.settingBackendPrivacyProtection,
                    subtitle: context.l10n.settingBackendPrivacyProtectionDes,
                    secondary: const Icon(Icons.remove_red_eye_rounded),
                    isLast: true,
                  );
                }),
              ],
            ),
          ),
        ],
      );
    }

    Widget buildMore() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdaptiveTitleTile(title: context.l10n.settingMore),
          Card.filled(
            color: context.theme.colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  AdaptiveListTile(
                    title: Text(context.l10n.settingLanguage),
                    leading: const Icon(Icons.language_rounded),
                    isFirst: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const LanguageDialogComponent();
                        },
                      );
                    },
                    trailing: Obx(() {
                      return Text(
                        state.language.value.l10nText(context),
                        style: context.textTheme.bodySmall!.copyWith(
                          color: context.theme.colorScheme.primary,
                        ),
                      );
                    }),
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '普通版示例：https://ark.cn-beijing.volces.com/api/v3\nCoding Plan示例：https://ark.cn-beijing.volces.com/api/coding/v3',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GetBuilder<SettingLogic>(
                    id: 'ArkApiType',
                    builder: (_) {
                      return ListTile(
                        title: const Text('API类型'),
                        subtitle: Text(
                          switch (PrefUtil.getValue<int>('arkApiType') ?? 1) {
                            0 => '普通版',
                            1 => 'Coding Plan',
                            _ => 'Coding Plan',
                          },
                        ),
                        trailing: const Icon(Icons.arrow_right_rounded),
                        onTap: () async {
                          final result = await showModalActionSheet<int>(
                            context: context,
                            actions: [
                              SheetAction(key: 0, label: '普通版'),
                              SheetAction(key: 1, label: 'Coding Plan'),
                            ],
                          );
                          if (result != null) {
                            final res = await logic.setArkApiType(type: result);
                            if (res) {
                              toast.success();
                              logic.update(['ArkApiType']);
                            } else {
                              toast.error();
                            }
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  GetBuilder<SettingLogic>(
                    id: 'MoodPaletteStyle',
                    builder: (_) {
                      return ListTile(
                        title: const Text('调色盘样式'),
                        subtitle: Text(switch (PrefUtil.getValue<int>(
                              'moodPaletteStyle',
                            ) ??
                            0) {
                          0 => '默认样式',
                          1 => '简约样式',
                          _ => '默认样式',
                        }),
                        trailing: const Icon(Icons.arrow_right_rounded),
                        onTap: () async {
                          final result = await showModalActionSheet<int>(
                            context: context,
                            actions: [
                              SheetAction(key: 0, label: '默认样式'),
                              SheetAction(key: 1, label: '简约样式'),
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
                  GetBuilder<SettingLogic>(
                    id: 'AiMoodRecommend',
                    builder: (_) {
                      return SwitchListTile(
                        title: const Text('启用AI情绪推荐'),
                        value:
                            PrefUtil.getValue<bool>('aiMoodRecommend') ?? true,
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
                  GetBuilder<SettingLogic>(
                    id: 'MoodTrendChart',
                    builder: (_) {
                      return SwitchListTile(
                        title: const Text('启用情绪趋势图'),
                        value:
                            PrefUtil.getValue<bool>('moodTrendChart') ?? true,
                        onChanged: (value) async {
                          final res = await logic.setMoodTrendChart(
                            enabled: value,
                          );
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
              ),
            ),
          ),
        ],
      );
    }

    return GetBuilder<SettingLogic>(
      assignId: true,
      builder: (_) {
        return PageClipper(
          child: ListView(
            cacheExtent: size.height * 2,
            children: [
              buildDashboard(),
              buildFeature(),
              buildData(),
              buildDisplay(),
              buildPrivacy(),
              buildMore(),
            ],
          ),
        );
      },
    );
  }
}
