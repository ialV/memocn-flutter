import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/article.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'result_screen.dart';

class _ShuffleItem {
  final String text;
  final int origIndex;
  _ShuffleItem({required this.text, required this.origIndex});
}

class ShuffleScreen extends StatefulWidget {
  final Article article;
  const ShuffleScreen({super.key, required this.article});

  @override
  State<ShuffleScreen> createState() => _ShuffleScreenState();
}

class _ShuffleScreenState extends State<ShuffleScreen> {
  late List<_ShuffleItem> _items;
  bool _checked = false;
  final _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    final sentences = widget.article.sentences;
    _items = List.generate(sentences.length, (i) => _ShuffleItem(text: sentences[i], origIndex: i));
    _items.shuffle(Random());
    _checked = false;
  }

  void _check() => setState(() => _checked = true);

  void _submit() {
    int correct = 0;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].origIndex == i) correct++;
    }
    final score = _items.isEmpty ? 0 : (correct / _items.length * 100).round();
    final dur = DateTime.now().difference(_startTime).inSeconds;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          article: widget.article,
          score: score,
          modeName: '乱序重组',
          detail: '共 ${_items.length} 句，顺序正确 $correct 句',
          durationSeconds: dur,
          onRetry: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ShuffleScreen(article: widget.article)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.article.title} · 乱序重组')),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  '长按拖动句子，排列到正确顺序',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 12),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _items.removeAt(oldIndex);
                      _items.insert(newIndex, item);
                      _checked = false;
                    });
                  },
                  itemBuilder: (ctx, i) {
                    final item = _items[i];
                    Color borderColor = const Color(0xFFE5E7EB);
                    if (_checked) {
                      borderColor = item.origIndex == i ? AppTheme.success : AppTheme.danger;
                    }
                    return Container(
                      key: ValueKey('${item.origIndex}_$i'),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borderColor, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
                      ),
                      child: Row(children: [
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _checked
                                ? (item.origIndex == i ? AppTheme.successLight : AppTheme.dangerLight)
                                : AppTheme.primaryLight,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _checked
                                    ? (item.origIndex == i ? AppTheme.success : AppTheme.danger)
                                    : AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(item.text, style: const TextStyle(fontSize: 15, height: 1.6)),
                        ),
                        const Icon(Icons.drag_handle, color: Color(0xFFD1D5DB)),
                      ]),
                    );
                  },
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
                  onPressed: _check,
                  child: const Text('检查顺序'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(onPressed: _submit, child: const Text('提交 ✓')),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
