import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/article.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'result_screen.dart';

// 工具函数（供其他文件引用）
int calcSimilarity(String input, String original) {
  final orig = original.replaceAll(RegExp(r'\s'), '');
  final inp = input.replaceAll(RegExp(r'\s'), '');
  if (orig.isEmpty) return 100;
  int correct = 0;
  for (int i = 0; i < orig.length; i++) {
    if (i < inp.length && inp[i] == orig[i]) correct++;
  }
  return (correct / orig.length * 100).round();
}

class ReciteScreen extends StatefulWidget {
  final Article article;
  const ReciteScreen({super.key, required this.article});

  @override
  State<ReciteScreen> createState() => _ReciteScreenState();
}

class _ReciteScreenState extends State<ReciteScreen> {
  final _ctrl = TextEditingController();
  final _tts = FlutterTts();
  bool _playing = false;
  final _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.42);
    _tts.setOnCompletionHandler(() => setState(() => _playing = false));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tts.stop();
    super.dispose();
  }

  void _listen() async {
    if (_playing) {
      await _tts.stop();
      setState(() => _playing = false);
    } else {
      setState(() => _playing = true);
      await _tts.speak(widget.article.content);
    }
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
          modeName: '默写模式',
          durationSeconds: dur,
          onRetry: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ReciteScreen(article: widget.article)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.article.title} · 默写模式')),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  '凭记忆默写全文，完成后自动对比原文',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  OutlinedButton.icon(
                    onPressed: _listen,
                    icon: Icon(_playing ? Icons.stop : Icons.volume_up),
                    label: Text(_playing ? '停止' : '先听一遍'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
                  ),
                ]),
                const SizedBox(height: 14),
                TextField(
                  controller: _ctrl,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: '开始默写……',
                    border: OutlineInputBorder(),
                  ),
                ),
              ]),
            ),
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
