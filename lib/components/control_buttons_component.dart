import 'package:flutter/material.dart';

// 控制按钮组件
class ControlButtonsComponent extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSave;

  const ControlButtonsComponent({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton.extended(
          onPressed: onPlayPause,
          icon: isPlaying ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
          label: Text(isPlaying ? '停止' : '播放'),
          backgroundColor: isPlaying ? Colors.red : Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        FloatingActionButton.extended(
          onPressed: onSave,
          icon: const Icon(Icons.save),
          label: const Text('保存'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ],
    );
  }
}