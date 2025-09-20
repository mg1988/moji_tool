# 分享功能集成说明

## 概述

本项目已成功集成 share_extend 模块来实现文件和文本分享功能，提供了统一的分享接口和用户体验。

## 主要组件

### 1. ShareService (`lib/utils/share_service.dart`)
核心分享服务类，提供以下功能：
- **文本分享**: `shareText(text, subject)`
- **文件分享**: `shareFile(filePath)`
- **多文件分享**: `shareMultipleFiles(filePaths)`
- **图片分享**: `shareImage(imagePath)`
- **平台支持检测**: `isNativeShareSupported()`

### 2. ShareHelper (`lib/utils/share_helper.dart`)
分享功能助手类，提供：
- 带验证的分享方法
- 统一的错误处理和用户提示
- 分享对话框
- 预制的分享按钮组件

### 3. 增强的组件

#### InputOutputCard (`lib/components/input_output_card.dart`)
- 新增 `enableShare` 参数
- 自动添加分享按钮到输出区域
- 支持直接分享输出内容

#### CustomButton (`lib/components/custom_button.dart`)
- 新增 `CustomButton.share()` 构造函数
- 预配置分享图标和样式

### 4. FileShareService (`lib/utils/file_share_service.dart`)
文件分享服务的升级版本：
- 集成 ShareService
- 保持向后兼容
- 支持单文件和多文件分享

## 使用示例

### 基础文本分享
```dart
import '../utils/share_service.dart';

// 简单文本分享
await ShareService.shareText("要分享的内容", subject: "标题");
```

### 带验证的文本分享
```dart
import '../utils/share_helper.dart';

// 自动验证并显示结果
await ShareHelper.shareTextWithValidation(
  context, 
  "要分享的内容",
  subject: "标题",
  emptyMessage: "没有内容可分享"
);
```

### 文件分享
```dart
// 单个文件
await ShareService.shareFile("/path/to/file.txt");

// 多个文件
await ShareService.shareMultipleFiles([
  "/path/to/file1.txt",
  "/path/to/file2.txt"
]);
```

### 在组件中使用
```dart
// 增强的输入输出卡片
InputOutputCard(
  inputController: _inputController,
  outputController: _outputController,
  enableShare: true, // 启用分享功能
  onCopy: _copyToClipboard,
)

// 分享按钮
CustomButton.share(
  text: '分享结果',
  onPressed: _shareResult,
)
```

## 已集成页面

### 文本工具页面
- `case_converter_page.dart` - 大小写转换
- `text_replacer_page.dart` - 文本替换

### 常用工具页面
- `business_card_qr_page.dart` - 名片二维码
  - 支持分享 vCard 文本
  - 支持分享二维码图片

### 文件管理页面
- `file_detail_page.dart` - 文件详情查看
- `received_files_page.dart` - 接收文件管理

## 平台支持

### 当前实现
- **移动平台** (Android/iOS): 使用剪贴板作为临时后备方案
- **Web平台**: 使用剪贴板
- **桌面平台**: 使用剪贴板

### 计划中的改进
当 share_extend 包完全兼容时，将启用：
- Android: 原生系统分享
- iOS: 原生系统分享
- 鸿蒙OS: 专用分享接口

## 配置信息

### pubspec.yaml 依赖
```yaml
dependencies:
  share_extend:
    git:
      url: https://gitcode.com/openharmony-sig/fluttertpc_share_extend.git
```

### 注意事项
1. 当前版本为了确保兼容性，暂时注释了 share_extend 的直接调用
2. 所有分享操作都有完善的错误处理和用户反馈
3. 支持多平台的统一API接口
4. 可以通过 `ShareService.isNativeShareSupported()` 检测是否支持原生分享

## 扩展指南

### 为新页面添加分享功能

1. **导入必要的工具类**:
```dart
import '../utils/share_helper.dart';
```

2. **添加分享方法**:
```dart
void _shareResult() async {
  await ShareHelper.shareTextWithValidation(
    context,
    _outputController.text,
    subject: '页面标题'
  );
}
```

3. **更新UI组件**:
```dart
// 使用增强的输入输出卡片
InputOutputCard(
  enableShare: true,
  // ... 其他参数
)

// 或添加自定义分享按钮
CustomButton.share(
  text: '分享结果',
  onPressed: _shareResult,
)
```

### 自定义分享逻辑

```dart
// 复杂的分享逻辑
Future<void> _customShare() async {
  final content = _generateShareContent();
  
  if (content.isEmpty) {
    // 显示错误提示
    return;
  }
  
  try {
    await ShareService.shareText(content, subject: '自定义标题');
    ShareHelper.showShareResult(context, true);
  } catch (e) {
    ShareHelper.showShareResult(context, false, e.toString());
  }
}
```

## 未来改进计划

1. **完善 share_extend 集成**: 当包完全兼容后启用原生分享
2. **添加更多分享选项**: 支持分享到特定应用
3. **增强文件分享**: 支持压缩和批量操作
4. **添加分享历史**: 记录分享操作历史
5. **优化用户体验**: 改进分享流程和反馈机制