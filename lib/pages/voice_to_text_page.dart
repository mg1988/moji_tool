import 'package:flutter/material.dart';
import '../components/colors.dart';
import '../components/custom_button.dart';
// 需要导入的Timer类
import 'dart:async';
// 语音转文字页面
class VoiceToTextPage extends StatefulWidget {
  const VoiceToTextPage({super.key});

  @override
  State<VoiceToTextPage> createState() => _VoiceToTextPageState();
}

class _VoiceToTextPageState extends State<VoiceToTextPage> {
  // 录音状态
  bool _isRecording = false;
  // 录音时长（秒）
  int _recordingDuration = 0;
  // 识别结果
  String _recognizedText = '';
  // 定时器
  late Timer _timer;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_isRecording) {
      _stopRecording();
    }
    super.dispose();
  }

  // 开始录音
  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
      _recognizedText = '';
    });

    // 启动定时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });

    // 这里应该添加实际的语音识别逻辑
    // 模拟识别过程
    Future.delayed(const Duration(seconds: 2), () {
      if (_isRecording) {
        setState(() {
          _recognizedText = '正在识别...';
        });
      }
    });
  }

  // 停止录音
  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
    _timer.cancel();

    // 这里应该添加停止录音和处理识别结果的逻辑
    // 模拟识别完成
    setState(() {
      _recognizedText = '这是一段语音识别的示例文本。';
    });
  }

  // 格式化时间显示
  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('语音转文字'),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.pageTitle.copyWith(
          color: AppColors.primaryBtn,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primaryBtn,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 计时区
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Text(
                _formatDuration(_recordingDuration),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // 识别结果区
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: AppCardStyles.basicCard,
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Text(
                      _recognizedText.isEmpty
                          ? '点击下方按钮开始录音' : _recognizedText,
                      style: AppTextStyles.body,
                    ),
                  ),
                ),
              ),
            ),

            // 控制区
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 录音按钮
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    onTapDown: (_) {
                      // 按钮按下效果
                      setState(() {});
                    },
                    onTapUp: (_) {
                      // 按钮释放效果
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? AppColors.textHint : AppColors.accent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isRecording
                            ? const Icon(Icons.stop, color: Colors.white, size: 40)
                            : const Icon(Icons.mic, color: Colors.white, size: 40),
                      ),
                    ),
                  ),

                  // 取消按钮
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: CustomButton.text(
                      text: '取消',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

