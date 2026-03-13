import 'package:flutter/material.dart';
import '../../models/article.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'result_screen.dart';

class CoverScreen extends StatefulWidget {
  final Article article;
  const CoverScreen({super.key, required this.article});

  @override
  State<CoverScreen> createState() => _CoverScreenState();
}

enum SentenceState { normal, covered, revealed }

class _CoverScreenState extends State<CoverScreen> {
  late List<SentenceState> _states;
  final _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _states = List.filled(widget.article.sentences.length, SentenceState.normal);
  }

  void _tap(int i) {
    setState(() {
      if (_states[i] == SentenceState.covered) {
        _states[i] = SentenceState.revealed;
      } else {
        _states[i] = SentenceState.covered;
      }
    });
  }

  void _coverAll() => setState(() {
        _states = List.filled(_states.length, SentenceState.covered);
      });

  void _revealAll() => setState(() {
        _states = List.filled(_states.length, SentenceState.normal);
      });

  void _finish() {
    final revealed = _states.where((s) => s == SentenceState.revealed).length;
    final score = (_states.isEmpty) ? 0 : (revealed / _states.length * 100).round();
    final dur = DateTime.now().difference(_startTime).inSeconds;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          article: widget.article,
          score: score,
          modeName: '遮盖练习',
          durationSeconds: dur,
          onRetry: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CoverScreen(article: widget.article)),
          ),
        ),
      ),
    );
  }

  double get _progress {
    if (_states.isEmpty) return 0;
    return _states.where((s) => s == SentenceState.revealed).length / _states.length;
  }

  @override
  Widget build(BuildContext context) {
    final sentences = widget.article.sentences;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.article.title} · 遮盖练习'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  '点击句子 → 遮盖，再次点击 → 揭示',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  runSpacing: 4,
                  children: List.generate(sentences.length, (i) {
                    final state = _states[i];
                    Color bg;
                    Color fg;
                    switch (state) {
                      case SentenceState.normal:
                        bg = Colors.transparent;
                        fg = const Color(0xFF1F2937);
                      case SentenceState.covered:
                        bg = const Color(0xFF1F2937);
                        fg = const Color(0xFF1F2937);
                      case SentenceState.revealed:
                        bg = AppTheme.successLight;
                        fg = const Color(0xFF1F2937);
                    }
                    return GestureDetector(
                      onTap: () => _tap(i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 2, bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          sentences[i],
                          style: TextStyle(fontSize: 17, height: 1.8, color: fg),
                        ),
                      ),
                    );
                  }),
                ),
              ]),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _coverAll,
                  child: const Text('全部遮盖'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _revealAll,
                  child: const Text('全部揭示'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _finish,
                  child: const Text('完成 ✓'),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
