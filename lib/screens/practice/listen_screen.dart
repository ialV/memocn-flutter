import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/article.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'result_screen.dart';
import 'recite_screen.dart' show calcSimilarity;

class ListenScreen extends StatefulWidget {
  final Article article;
  const ListenScreen({super.key, required this.article});

  @override
  State<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends State<ListenScreen> {
  final _ctrl = TextEditingController();
  final _tts = FlutterTts();
  bool _playing = false;
  String _statusText = '点击播放按钮开始';
  final _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('zh-CN');
    await _tts.awaitSpeakCompletion(true);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() { _playing = false; _statusText = '✓ 播放完毕，开始写吧'; });
    });
    _tts.setErrorHandler((msg) {
      if (mounted) setState(() { _playing = false; _statusText = '⚠ 朗读失败，请检查设备 TTS 设置'; });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tts.stop();
    super.dispose();
  }

  void _play(double rate) async {
    if (_playing) {
      await _tts.stop();
      setState(() { _playing = false; _statusText = '已停止'; });
      return;
    }
    await _tts.setSpeechRate(rate);
    setState(() { _playing = true; _statusText = '🔊 正在播放……'; });
    await _tts.speak(widget.article.content);
  }

  void _submit() {
    final input = _ctrl.text;
    final original = widget.article.content;
    final score = calcSimilarity(input, original);
    final dur = DateTime.now().difference(_startTime).inSeconds;
    _tts.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          article: widget.article,
          score: score,
          modeName: '听写模式',
          durationSeconds: dur,
          onRetry: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ListenScreen(article: widget.article)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.article.title} · 听写模式')),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              AppCard(
                child: Column(children: [
                  const Text(
                    '播放音频，边听边默写全文',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _PlayBtn(
                      icon: _playing ? Icons.stop_circle : Icons.play_circle_filled,
                      label: _playing ? '停止' : '正常语速',
                      color: AppTheme.primary,
                      onTap: () => _play(0.45),
                    ),
                    const SizedBox(width: 16),
                    _PlayBtn(
                      icon: Icons.slow_motion_video,
                      label: '慢速',
                      color: AppTheme.warn,
                      onTap: () => _play(0.28),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_statusText,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  ),
                ]),
              ),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('听写内容', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrl,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: '边听边写……',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _submit, child: const Text('提交对比 ✓')),
            ),
          ),
        ),
      ]),
    );
  }
}

class _PlayBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PlayBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
          child: Icon(icon, color: color, size: 36),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
