## 软件简介

心色彩记是一款跨平台日记应用，具有以下特点：

- **跨平台支持**：兼容 Android、iOS、Windows、MacOS。
- **Material Design**：界面直观且用户友好，遵循 Material Design 设计规范。
- **多种编辑器**：支持 Markdown 、纯文本、富文本等多种形式的文本编辑。
- **多媒体附件**：可以为你的日记添加图片、音频、视频甚至画一张画。
- **搜索和分类**：轻松通过全文搜索及分类管理你的日记。
- **自定义主题**：支持浅色和深色模式，以及多种配色的主题（默认群青配色）。
- **自定义字体**：支持导入不同的字体，并支持可变字体。
- **数据安全**：通过密码来保障你的日记安全，支持通过生物识别解锁。
- **导出和分享**：支持所有数据的导入/导出，以及单篇日记的分享。
- **备份与同步**：支持局域网同步，快速在设备间同步数据，以及 WebDav 备份。
- **足迹地图**：在地图上查看你足迹，生活中的每一步都值得被记录。
- **情绪调色盘**：12色阶情绪调色盘，支持预设情绪快速选择，以及 AI 推荐情绪。
- **AI 情绪检测**：保存日记时自动检测情绪（火山方舟 API）。
- **分析统计**：情绪趋势折线图，同一天多篇日记取平均值，AI 情绪分析。
- **智能助手**：支持接入火山方舟大模型，提供问答、情绪分析等功能。

## 安装配置说明

### 第三方 SDK

某些能力需要自行申请第三方 SDK，下列服务商均提供免费的版本，获取到的 Key 在设置中配置。

#### 天气服务
- [和风天气](https://dev.qweather.com/docs/api/)

#### 地图服务
- [天地图](http://lbs.tianditu.gov.cn/server/MapService.html)

#### 智能助手
- [火山方舟大模型](https://www.volcengine.com/product/ark)（支持普通版和 Coding Plan）

### 直接安装

通过下载 Release 中已编译好的安装包来使用，如果没有你所需要的平台，请使用手动编译。

### 手动编译

#### 环境要求

- Flutter SDK (>= 3.29.0 Stable)（建议使用 fvm 来管理 flutter 版本）
- Dart (>= 3.7.0)
- Rust 工具链（Nightly）
- Clang/LLVM
- 兼容的 IDE（如 Android Studio、Visual Studio Code）

#### 安装步骤

1. **获取源码**：
   将源代码解压到本地目录。

2. **安装依赖**：
```bash
flutter pub get
```

3. **运行应用**：
```bash
flutter run
```

4. **打包发布**：
- Android: `flutter build apk`
- iOS: `flutter build ipa`
- Windows: `flutter build windows`
- MacOS: `flutter build macos`

&gt; 注意：出于安全考虑，代码库中不包含签名，当您需要手动打包时，需要自己修改对应平台的配置文件。
