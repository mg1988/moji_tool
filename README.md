# Moji Toolbox (默记工具箱)

<p align="center">
  <img src="images/banner1.png" alt="Moji Toolbox Banner" width="100%">
</p>

<p align="center">
  <a href="https://github.com/mg1988/moji_tool/stargazers">
    <img src="https://img.shields.io/github/stars/mg1988/moji_tool" alt="GitHub stars">
  </a>
  <a href="https://github.com/mg1988/moji_tool/issues">
    <img src="https://img.shields.io/github/issues/mg1988/moji_tool" alt="GitHub issues">
  </a>
  <a href="https://github.com/your-username/moji_tool/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/mg1988/moji_tool" alt="GitHub">
  </a>
</p>

一款功能丰富的Flutter跨平台工具应用，支持Android、iOS、Web、Windows、macOS、Linux和OpenHarmony。包含了超过50种实用工具，涵盖开发、文本处理、图片处理、设备检测等多个领域。

## 🌟 功能特性

### 📱 常用工具
- **时间屏幕** - 在手机屏幕上显示当前时间
- **手持弹幕** - 创建个性化的滚动弹幕
- **全屏时钟** - 多种样式的全屏时钟
- **今天吃点啥** - 随机食物选择器
- **做个决定** - 帮助做决策的轮盘
- **敲木鱼** - 有趣的计数器
- **指尖轮盘** - 互动式旋转轮盘
- **名片二维码** - 基于vCard标准生成商务名片二维码
- **世界时钟** - 查看全球主要城市时间
- **文件快传** - 局域网内手机与电脑快速互传文件

### 🖼️ 图片工具
- **九宫格切图** - 将图片分割成九宫格
- **图片拼接** - 将多张图片拼接成一张
- **格式转换** - JPG、PNG、BMP、WEBP等多种格式相互转换
- **图片水印** - 为图片添加文字或图片水印
- **修改尺寸** - 调整图片尺寸
- **图片滤镜** - 为图片应用不同滤镜效果

### 📝 文本处理
- **文本大小写转换** - 大小写格式转换
- **文本字数统计** - 统计文本字符数、单词数等
- **文本去重** - 去除重复的文本行
- **文本替换** - 批量替换文本内容
- **文本加密解密** - 多种加密算法支持
- **文本排序** - 对文本行进行排序
- **文本分割/连接** - 文本分割与合并
- **文本提取** - 从文本中提取特定内容
- **数字转中文** - 阿拉伯数字转中文数字
- **中文转拼音** - 中文文本转拼音
- **繁简转换** - 简体与繁体中文互转

### 💻 开发工具
- **JSON格式化** - JSON数据格式化与校验
- **颜色选择器** - 可视化颜色选择与转换
- **正则测试** - 正则表达式测试工具
- **二维码生成** - 自定义二维码生成
- **时间戳转换** - 时间与时间戳互转
- **Base64转换** - 文本与Base64编码互转
- **Hash计算** - 多种哈希算法计算
- **文本对比** - 文本差异对比
- **单位转换** - 常用单位换算
- **ASCII码表** - ASCII字符对照表
- **UUID生成器** - UUID字符串生成
- **随机数生成器** - 自定义范围随机数生成

### 📱 设备工具
- **设备信息** - 查看设备详细信息
- **屏幕坏点检测** - 检测屏幕坏点
- **触摸检测** - 屏幕触摸功能测试

## 🚀 技术栈
- [Flutter框架](https://flutter.dev/) (Dart语言)
- 支持多平台构建：Android、iOS、Web、OpenHarmony
- 丰富的第三方插件支持

## 📋 开发环境要求
- Flutter SDK 3.4+
- Android Studio / VS Code
- 对应平台的构建工具（Android SDK、Xcode等）

## 🛠️ 安装与运行

```bash
# 克隆项目
git clone https://github.com/mg1988/moji_tool.git

cd moji_tool

# 获取依赖
flutter pub get

# 运行应用
flutter run

# 构建各平台应用
flutter build android    # Android
flutter build ios        # iOS
flutter build macos      # macOS
flutter build linux      # Linux
```

## 📁 项目结构

```
lib/
├── components/     # 通用UI组件
├── data/           # 数据源
├── models/         # 数据模型
├── pages/          # 页面组件
├── utils/          # 工具类
└── main.dart       # 应用入口
```

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目。

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个Pull Request

## 📄 许可证

本项目采用MIT许可证，详情请见 [LICENSE](LICENSE) 文件。

## 👤 作者

Genwei Mi - migenwei@163.com

项目链接: [https://github.com/your-username/moji_tool](https://github.com/your-username/moji_tool)
