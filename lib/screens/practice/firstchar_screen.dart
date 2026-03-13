import 'package:flutter/material.dart';
import '../../models/article.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'result_screen.dart';
import 'recite_screen.dart' show calcSimilarity;

class FirstcharScreen extends StatefulWidget {
  final Article article;
  const FirstcharScreen({super.key, required this.article});

  @override
  State<FirstcharScreen> createState() => _FirstcharScreenState();
}

class _FirstcharScreenState extends State<FirstcharScreen> {
  final _ctrl = TextEditingController();
  bool _showOriginal = false;
  final _startTime = DateTime.now();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final input = _ctrl.text;
    final original = widget.article.content;
    final score = calcSimilarity(input, original);
    final dur = DateTime.now().difference(_startTime).inSeconds;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          article: widget.article,
          score: score,
          modeName: '首字提示',
          durationSeconds: dur,
          onRetry: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => FirstcharScreen(article: widget.article)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sentences = widget.article.sentences;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.article.title} · 首字提示'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _showOriginal = !_showOriginal),
            child: Text(_showOriginal ? '隐藏原文' : '查看原文',
                style: const TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text(
                    '每句只显示首字，尝试背出完整内容',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 12),
                  if (!_showOriginal)
                    ...sentences.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 17, height: 1.8, color: Color(0xFF1F2937)),
                              children: [
                                TextSpan(
                                  text: s.isNotEmpty ? s[0] : '',
                                  style: const TextStyle(
                                      color: AppTheme.primary, fontWeight: FontWeight.w700),
                                ),
                                if (s.length > 1)
                                  TextSpan(
                                    text: List.generate(
                                      s.substring(1).runes.where((r) => RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf]').hasMatch(String.fromCharCode(r))).length,
                                      (_) => '＿',
                                    ).join(),
                                    style: const TextStyle(color: Color(0xFFD1D5DB), letterSpacing: 2),
                                  ),
                              ],
                            ),
                          ),
                        ))
                  else
                    Text(
                      widget.article.content,
                      style: const TextStyle(fontSize: 16, height: 1.9, color: Color(0xFF374151)),
                    ),
                ]),
              ),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('逐句默写（凭首字提示写出全文）',
                      style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrl,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: '在这里输入全文……',
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
              child: FilledButton(onPressed: _submit, child: const Text('对比原文 ✓')),
            ),
          ),
        ),
      ]),
    );
  }
}
