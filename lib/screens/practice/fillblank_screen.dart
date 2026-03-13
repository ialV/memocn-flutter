import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/article.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'result_screen.dart';

class _BlankItem {
  final int index;
  final String answer;
  String input;
  bool? correct;

  _BlankItem({required this.index, required this.answer, this.input = '', this.correct});
}

class FillblankScreen extends StatefulWidget {
  final Article article;
  const FillblankScreen({super.key, required this.article});

  @override
  State<FillblankScreen> createState() => _FillblankScreenState();
}

class _FillblankScreenState extends State<FillblankScreen> {
  String _difficulty = 'medium';
  late List<_BlankItem> _blanks;
  late List<dynamic> _segments; // String or int (blank index)
  final _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _build('medium');
  }

  void _build(String difficulty) {
    final text = widget.article.content;
    final chars = text.split('');
    final chineseIndices = <int>[];
    for (int i = 0; i < chars.length; i++) {
      if (RegExp(r'[\u4e00-\u9fff]').hasMatch(chars[i])) chineseIndices.add(i);
    }
    final ratio = {'easy': 0.15, 'medium': 0.35, 'hard': 0.55, 'extreme': 0.80}[difficulty]!;
    final shuffled = [...chineseIndices]..shuffle(Random());
    final blankCount = (shuffled.length * ratio).round();
    final blankedSet = Set.from(shuffled.take(blankCount));

    _blanks = [];
    _segments = [];
    var buffer = '';
    int blankIdx = 0;

    for (int i = 0; i < chars.length; i++) {
      if (blankedSet.contains(i)) {
        if (buffer.isNotEmpty) {
          _segments.add(buffer);
          buffer = '';
        }
        _blanks.add(_BlankItem(index: blankIdx, answer: chars[i]));
        _segments.add(blankIdx);
        blankIdx++;
      } else {
        buffer += chars[i];
      }
    }
    if (buffer.isNotEmpty) _segments.add(buffer);
  }

  void _changeDifficulty(String d) {
    setState(() {
      _difficulty = d;
      _build(d);
    });
  }

  void _submit() {
    setState(() {
      for (final b in _blanks) {
        b.correct = b.input == b.answer;
      }
    });
    final correct = _blanks.where((b) => b.correct == true).length;
    final score = _blanks.isEmpty ? 0 : (correct / _blanks.length * 100).round();
    final dur = DateTime.now().difference(_startTime).inSeconds;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          article: widget.article,
          score: score,
          modeName: '填空练习',
          detail: '共 ${_blanks.length} 空，答对 $correct 空',
          durationSeconds: dur,
          onRetry: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => FillblankScreen(article: widget.article)),
          ),
        ),
      ),
    );
  }

  void _showAnswers() {
    setState(() {
      for (final b in _blanks) {
        b.input = b.answer;
        b.correct = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.article.title} · 填空练习')),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Text('难度：', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                    Expanded(child: DifficultySelector(selected: _difficulty, onChanged: _changeDifficulty)),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    '共 ${_blanks.length} 个空 · 输入正确字自动变绿',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ]),
              ),
              AppCard(
                child: _FillblankText(
                  segments: _segments,
                  blanks: _blanks,
                  onChanged: (idx, val) => setState(() => _blanks[idx].input = val),
                ),
              ),
            ]),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _showAnswers,
                  child: const Text('显示答案'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(onPressed: _submit, child: const Text('提交检查 ✓')),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _FillblankText extends StatelessWidget {
  final List<dynamic> segments;
  final List<_BlankItem> blanks;
  final Function(int, String) onChanged;

  const _FillblankText({required this.segments, required this.blanks, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 6,
      children: segments.map<Widget>((seg) {
        if (seg is String) {
          return Text(seg.replaceAll('\n', '\n'),
              style: const TextStyle(fontSize: 17, height: 2.0));
        } else {
          final b = blanks[seg as int];
          Color border = AppTheme.primary;
          Color bg = AppTheme.primaryLight;
          if (b.correct == true) { border = AppTheme.success; bg = AppTheme.successLight; }
          if (b.correct == false) { border = AppTheme.danger; bg = AppTheme.dangerLight; }
          return _BlankField(
            value: b.input,
            border: border,
            bg: bg,
            onChanged: (v) {
              onChanged(b.index, v);
            },
          );
        }
      }).toList(),
    );
  }
}

class _BlankField extends StatefulWidget {
  final String value;
  final Color border, bg;
  final ValueChanged<String> onChanged;

  const _BlankField({required this.value, required this.border, required this.bg, required this.onChanged});

  @override
  State<_BlankField> createState() => _BlankFieldState();
}

class _BlankFieldState extends State<_BlankField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_BlankField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _ctrl.text != widget.value) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: widget.bg,
        border: Border(bottom: BorderSide(color: widget.border, width: 2)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: TextField(
        controller: _ctrl,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
