import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';

class ImageProcessor {
  /// 九宫格切图 - 精确切割确保可完美还原
  static Future<List<Uint8List>> gridCut(XFile imageFile, int rows, int columns) async {
    try {
      // 读取图片
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('无法解码图片');
      }
      
      final width = image.width;
      final height = image.height;
      
      final List<Uint8List> gridImages = [];
      
      // 精确切割图片，确保可以完美还原
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          // 计算每个单元格的精确位置和尺寸
          final x = (col * width / columns).round();
          final y = (row * height / rows).round();
          final right = ((col + 1) * width / columns).round();
          final bottom = ((row + 1) * height / rows).round();
          
          final cellWidth = right - x;
          final cellHeight = bottom - y;
          
          // 确保不会超出图片边界
          final actualWidth = x + cellWidth > width ? width - x : cellWidth;
          final actualHeight = y + cellHeight > height ? height - y : cellHeight;
          
          // 裁剪图片
          final cropped = img.copyCrop(
            image,
            x: x,
            y: y,
            width: actualWidth,
            height: actualHeight,
          );
          
          // 编码为JPEG格式
          final encoded = img.encodeJpg(cropped);
          gridImages.add(Uint8List.fromList(encoded));
        }
      }
      
      return gridImages;
    } catch (e) {
      throw Exception('九宫格切图失败: $e');
    }
  }
  
  /// 图片拼接
  static Future<Uint8List> mergeImages(List<XFile> imageFiles, bool isVertical, {int spacing = 0}) async {
    try {
      if (imageFiles.isEmpty) {
        throw Exception('没有图片需要拼接');
      }
      
      // 读取所有图片
      final List<img.Image> images = [];
      for (final file in imageFiles) {
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image != null) {
          images.add(image);
        }
      }
      
      if (images.isEmpty) {
        throw Exception('无法解码任何图片');
      }
      
      // 计算拼接后的尺寸（考虑间距）
      int totalWidth, totalHeight;
      if (isVertical) {
        // 垂直拼接
        totalWidth = images.map((img) => img.width).reduce((a, b) => a > b ? a : b);
        totalHeight = images.map((img) => img.height).reduce((a, b) => a + b);
        // 添加间距（n-1个间距）
        if (images.length > 1) {
          totalHeight += spacing * (images.length - 1);
        }
      } else {
        // 水平拼接
        totalWidth = images.map((img) => img.width).reduce((a, b) => a + b);
        totalHeight = images.map((img) => img.height).reduce((a, b) => a > b ? a : b);
        // 添加间距（n-1个间距）
        if (images.length > 1) {
          totalWidth += spacing * (images.length - 1);
        }
      }
      
      // 创建新图片
      final mergedImage = img.Image(width: totalWidth, height: totalHeight);
      
      // 如果有间距，先填充白色背景
      if (spacing > 0) {
        // 填充整个图像为白色
        img.fill(mergedImage, color: img.ColorUint8.rgb(255, 255, 255));
      }
      
      // 拼接图片（考虑间距）
      int offsetX = 0, offsetY = 0;
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        img.compositeImage(mergedImage, image, dstX: offsetX, dstY: offsetY);
        
        if (isVertical) {
          offsetY += image.height + spacing;
        } else {
          offsetX += image.width + spacing;
        }
      }
      
      // 编码为JPEG格式
      final encoded = img.encodeJpg(mergedImage);
      return Uint8List.fromList(encoded);
    } catch (e) {
      throw Exception('图片拼接失败: $e');
    }
  }
  
  /// 格式转换
  static Future<Uint8List> convertFormat(XFile imageFile, String targetFormat, {int quality = 90}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('无法解码图片');
      }
      
      late List<int> encoded;
      switch (targetFormat.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
          encoded = img.encodeJpg(image, quality: quality);
          break;
        case 'png':
          encoded = img.encodePng(image);
          break;
        case 'bmp':
          encoded = img.encodeBmp(image);
          break;
        case 'webp':
          // 对于WebP格式，如果image库支持则使用，否则回退到JPG
          encoded = img.encodeJpg(image, quality: quality);
          break;
        default:
          throw Exception('不支持的格式: $targetFormat');
      }
      
      return Uint8List.fromList(encoded);
    } catch (e) {
      throw Exception('格式转换失败: $e');
    }
  }
  
  /// 添加水印
  static Future<Uint8List> addWatermark(
    XFile imageFile,
    String text,
    double opacity,
    double fontSize,
    Alignment position,
    Color? textColor, // 添加文字颜色参数
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('无法解码图片');
      }
      
      // 创建水印图片
      final watermark = img.Image(width: image.width, height: image.height);
      
      // 填充透明背景
      img.fill(watermark, color: img.ColorUint8.rgba(0, 0, 0, 0));
      
      // 计算水印位置
      final textWidth = text.length * fontSize * 0.6;
      final textHeight = fontSize;
      
      int x, y;
      if (position == Alignment.topLeft) {
        x = 10;
        y = 10;
      } else if (position == Alignment.topCenter) {
        x = (image.width - textWidth) ~/ 2;
        y = 10;
      } else if (position == Alignment.topRight) {
        x = image.width - textWidth.toInt() - 10;
        y = 10;
      } else if (position == Alignment.centerLeft) {
        x = 10;
        y = (image.height - textHeight) ~/ 2;
      } else if (position == Alignment.center) {
        x = (image.width - textWidth) ~/ 2;
        y = (image.height - textHeight) ~/ 2;
      } else if (position == Alignment.centerRight) {
        x = image.width - textWidth.toInt() - 10;
        y = (image.height - textHeight) ~/ 2;
      } else if (position == Alignment.bottomLeft) {
        x = 10;
        y = image.height - textHeight.toInt() - 10;
      } else if (position == Alignment.bottomCenter) {
        x = (image.width - textWidth) ~/ 2;
        y = image.height - textHeight.toInt() - 10;
      } else { // Alignment.bottomRight
        x = image.width - textWidth.toInt() - 10;
        y = image.height - textHeight.toInt() - 10;
      }
      
      // 添加文字水印
      img.drawString(
        watermark,
        text,
        x: x.toInt(),
        y: y.toInt(),
        color: textColor != null
            ? img.ColorUint8.rgb(
                (textColor.red * 255).toInt(),
                (textColor.green * 255).toInt(),
                (textColor.blue * 255).toInt(),
              )
            : img.ColorUint8.rgb(255, 255, 255), // 默认白色文字
        font: img.arial24,
      );
      
      // 合并图片
      img.compositeImage(image, watermark);
      
      // 编码为JPEG格式
      final encoded = img.encodeJpg(image);
      return Uint8List.fromList(encoded);
    } catch (e) {
      throw Exception('添加水印失败: $e');
    }
  }
  
  /// 修改尺寸
  static Future<Uint8List> resizeImage(
    XFile imageFile,
    double width,
    double height,
    bool maintainAspectRatio,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('无法解码图片');
      }
      
      img.Image resizedImage;
      if (maintainAspectRatio) {
        resizedImage = img.copyResize(image, width: width.toInt());
      } else {
        resizedImage = img.copyResize(image, width: width.toInt(), height: height.toInt());
      }
      
      // 编码为JPEG格式
      final encoded = img.encodeJpg(resizedImage);
      return Uint8List.fromList(encoded);
    } catch (e) {
      throw Exception('修改尺寸失败: $e');
    }
  }
  
  /// 应用滤镜
  static Future<Uint8List> applyFilter(XFile imageFile, String filter) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('无法解码图片');
      }
      
      img.Image filteredImage = image;
      
      switch (filter) {
        case '黑白':
          filteredImage = img.grayscale(image);
          break;
        case '复古':
          // 简单的复古效果实现
          filteredImage = img.sepia(image);
          break;
        case '鲜艳':
          // 增加饱和度
          filteredImage = img.adjustColor(image, saturation: 1.5);
          break;
        case '柔和':
          // 降低对比度
          filteredImage = img.adjustColor(image, contrast: 0.8);
          break;
        case '冷色调':
          // 添加冷色调效果 - 通过调整蓝色通道
          filteredImage = img.adjustColor(image, brightness: 1.1);
          // 手动增加蓝色通道值
          for (final pixel in filteredImage) {
            pixel.b = (pixel.b * 1.2).clamp(0, pixel.maxChannelValue);
          }
          break;
        case '暖色调':
          // 添加暖色调效果 - 通过调整红色和绿色通道
          filteredImage = img.adjustColor(image, brightness: 1.1);
          // 手动增加红色和绿色通道值
          for (final pixel in filteredImage) {
            pixel.r = (pixel.r * 1.2).clamp(0, pixel.maxChannelValue);
            pixel.g = (pixel.g * 1.1).clamp(0, pixel.maxChannelValue);
          }
          break;
        case '模糊':
          // 应用高斯模糊
          filteredImage = img.gaussianBlur(image, radius: 3);
          break;
        case '锐化':
          // 使用边缘增强来模拟锐化效果
          filteredImage = img.convolution(image, filter: const [
            0, -1, 0,
            -1, 5, -1,
            0, -1, 0,
          ]);
          break;
        case '亮度+':
          // 增加亮度
          filteredImage = img.adjustColor(image, brightness: 1.2);
          break;
        case '亮度-':
          // 降低亮度
          filteredImage = img.adjustColor(image, brightness: 0.8);
          break;
        case '对比度+':
          // 增加对比度
          filteredImage = img.adjustColor(image, contrast: 1.2);
          break;
        case '对比度-':
          // 降低对比度
          filteredImage = img.adjustColor(image, contrast: 0.8);
          break;
        default:
          // 原图
          filteredImage = image;
      }
      
      // 编码为JPEG格式
      final encoded = img.encodeJpg(filteredImage);
      return Uint8List.fromList(encoded);
    } catch (e) {
      throw Exception('应用滤镜失败: $e');
    }
  }
  
  /// 生成开发图
  static Future<Map<String, Uint8List>> generateDevImages(
    XFile imageFile,
    String platform,
    List<String> sizes,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('无法解码图片');
      }
      
      final Map<String, Uint8List> devImages = {};
      
      // 定义不同分辨率的缩放比例
      final Map<String, double> scaleFactors = {
        'mdpi': 1.0,
        'hdpi': 1.5,
        'xhdpi': 2.0,
        'xxhdpi': 3.0,
        'xxxhdpi': 4.0,
      };
      
      for (final size in sizes) {
        if (scaleFactors.containsKey(size)) {
          final scaleFactor = scaleFactors[size]!;
          final scaledWidth = (image.width * scaleFactor).toInt();
          final scaledHeight = (image.height * scaleFactor).toInt();
          
          final scaledImage = img.copyResize(image, width: scaledWidth, height: scaledHeight);
          final encoded = img.encodePng(scaledImage);
          devImages[size] = Uint8List.fromList(encoded);
        }
      }
      
      return devImages;
    } catch (e) {
      throw Exception('生成开发图失败: $e');
    }
  }
}