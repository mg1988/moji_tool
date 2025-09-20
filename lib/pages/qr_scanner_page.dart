import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../components/colors.dart';
import '../utils/qr_result_handler.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController controller = MobileScannerController();
  bool _isFlashOn = false;
  bool _isScanning = true;
  String _scanResult = '';

  // 为了在热重载时重新组装扫描器，我们需要暂停摄像头
  @override
  void reassemble() {
    super.reassemble();
    controller.stop();
    controller.start();
  }

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  // 检查摄像头权限
  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isDenied) {
        Navigator.pop(context);
        _showPermissionDeniedDialog();
      }
    }
  }

  // 显示权限被拒绝的对话框
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要摄像头权限'),
        content: const Text('扫码功能需要访问摄像头，请在设置中开启权限。'),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('扫一扫'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            // 扫描区域
            child: Stack(
              children: [
                // 扫描器
                MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                ),
                // 扫描框叠加层
                if (_isScanning)
                  Positioned.fill(
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: _QrScannerOverlayShape(
                          borderColor: AppColors.primary,
                          borderRadius: 10,
                          borderLength: 30,
                          borderWidth: 8,
                          cutOutSize: 250,
                        ),
                      ),
                    ),
                  ),
                // 扫描线动画
                if (_isScanning)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        child:  _ScanLineAnimation(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 底部提示区域
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '将二维码放入扫描框内',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '支持扫描通讯录、网址、文本、WiFi密码等',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanning && capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
          _scanResult = barcode.rawValue!;
        });
        
        // 处理扫描结果
        _handleScanResult(barcode.rawValue!);
      }
    }
  }

  // 处理扫描结果
  void _handleScanResult(String result) {
    controller.stop();
    
    // 使用结果处理器处理扫描结果
    QRResultHandler.handleResult(context, result).then((_) {
      // 处理完成后返回上一页
      Navigator.pop(context);
    }).catchError((error) {
      // 如果处理失败，显示原始结果并允许继续扫描
      _showResultDialog(result);
    });
  }

  // 显示扫描结果对话框
  void _showResultDialog(String result) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBtn.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBtn,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '扫码结果',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // 内容区域
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.2,
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: SelectableText(
                        result,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 分割线
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: AppColors.border,
              ),
              // 按钮区域
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resumeScanning();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryBtn, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            foregroundColor: AppColors.primaryBtn,
                          ),
                          child: const Text(
                            '继续扫码',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBtn,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '完成',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 恢复扫描
  void _resumeScanning() {
    setState(() {
      _isScanning = true;
      _scanResult = '';
    });
    controller.start();
  }

  // 切换闪光灯
  void _toggleFlash() async {
    await controller.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// 扫描线动画组件
class _ScanLineAnimation extends StatefulWidget {
  @override
  _ScanLineAnimationState createState() => _ScanLineAnimationState();
}

class _ScanLineAnimationState extends State<_ScanLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ScanLinePainter(_animation.value),
          size: Size.infinite,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// 扫描线画笔
class ScanLinePainter extends CustomPainter {
  final double progress;

  ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final y = size.height * progress;
    
    // 绘制扫描线
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
    
    // 绘制渐变效果
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary.withOpacity(0.0),
        AppColors.primary.withOpacity(0.5),
        AppColors.primary.withOpacity(0.0),
      ],
    );
    
    final rect = Rect.fromLTWH(0, y - 10, size.width, 20);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect);
    
    canvas.drawRect(rect, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// 扫描框形状
class _QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  const _QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.borderLength = 40.0,
    this.borderRadius = 0.0,
    this.cutOutSize = 250.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final innerRect = _getCutOutRect(rect);
    return Path()..addRRect(RRect.fromRectAndRadius(innerRect, Radius.circular(borderRadius)));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = _getCutOutRect(rect);
    
    // 绘制遮罩
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final overlayPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(overlayPath, overlayPaint);
    
    // 绘制边框
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    
    // 绘制四个角落
    _drawCorner(canvas, cutOutRect.topLeft, borderPaint, 0); // 左上
    _drawCorner(canvas, cutOutRect.topRight, borderPaint, 1); // 右上
    _drawCorner(canvas, cutOutRect.bottomLeft, borderPaint, 2); // 左下
    _drawCorner(canvas, cutOutRect.bottomRight, borderPaint, 3); // 右下
  }

  void _drawCorner(Canvas canvas, Offset corner, Paint paint, int cornerIndex) {
    final path = Path();
    
    switch (cornerIndex) {
      case 0: // 左上角
        path
          ..moveTo(corner.dx, corner.dy + borderLength)
          ..lineTo(corner.dx, corner.dy + borderRadius)
          ..arcToPoint(
            Offset(corner.dx + borderRadius, corner.dy),
            radius: Radius.circular(borderRadius),
          )
          ..lineTo(corner.dx + borderLength, corner.dy);
        break;
      case 1: // 右上角
        path
          ..moveTo(corner.dx - borderLength, corner.dy)
          ..lineTo(corner.dx - borderRadius, corner.dy)
          ..arcToPoint(
            Offset(corner.dx, corner.dy + borderRadius),
            radius: Radius.circular(borderRadius),
          )
          ..lineTo(corner.dx, corner.dy + borderLength);
        break;
      case 2: // 左下角
        path
          ..moveTo(corner.dx, corner.dy - borderLength)
          ..lineTo(corner.dx, corner.dy - borderRadius)
          ..arcToPoint(
            Offset(corner.dx + borderRadius, corner.dy),
            radius: Radius.circular(borderRadius),
          )
          ..lineTo(corner.dx + borderLength, corner.dy);
        break;
      case 3: // 右下角
        path
          ..moveTo(corner.dx - borderLength, corner.dy)
          ..lineTo(corner.dx - borderRadius, corner.dy)
          ..arcToPoint(
            Offset(corner.dx, corner.dy - borderRadius),
            radius: Radius.circular(borderRadius),
          )
          ..lineTo(corner.dx, corner.dy - borderLength);
        break;
    }
    
    canvas.drawPath(path, paint);
  }

  Rect _getCutOutRect(Rect rect) {
    final center = rect.center;
    final left = center.dx - cutOutSize / 2;
    final top = center.dy - cutOutSize / 2;
    return Rect.fromLTWH(left, top, cutOutSize, cutOutSize);
  }

  @override
  ShapeBorder scale(double t) {
    return _QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      borderLength: borderLength * t,
      borderRadius: borderRadius * t,
      cutOutSize: cutOutSize * t,
    );
  }
}