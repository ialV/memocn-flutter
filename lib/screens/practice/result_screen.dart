import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/article.dart';
import '../../models/record.dart';
import '../../services/app_state.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class ResultScreen extends StatefulWidget {
  final Article article;
  final int score;
  final String modeName;
  final String? detail;
  final int durationSeconds;
  final VoidCallback onRetry;

  const ResultScreen({
    super.key,
    required this.article,
    required this.score,
    required this.modeName,
    this.detail,
    required this.durationSeconds,
    required this.onRetry,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveRecord();
  }

  void _saveRecord() async {
    final state = context.read<AppState>();
    await state.addRecord(PracticeRecord(
      id: const Uuid().v4(),
      articleId: widget.article.id,
      articleTitle: widget.article.title,
      mode: widget.modeName,
      score: widget.score,
      durationSeconds: widget.durationSeconds,
      time: DateTime.now(),
    ));
  }

  String get _comment {
    if (widget.score >= 90) return '太厉害了！完全掌握！🎉';
    if (widget.score >= 70) return '不错！再练几遍就完美了 👍';
    if (widget.score >= 50) return '还需要多练练哦 💪';
    return '没关系，多看几遍再来 📖';
  }

  Color get _scoreColor {
    if (widget.score >= 80) return AppTheme.success;
    if (widget.score >= 50) return AppTheme.warn;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('练习结果')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          AppCard(
            child: Column(children: [
              const SizedBox(height: 16),
              ScoreCircle(score: widget.score),
              const SizedBox(height: 16),
              Text(
                '${widget.modeName} · ${widget.score} 分',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(_comment, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              const SizedBox(height: 4),
              Text(
                '用时 ${widget.durationSeconds ~/ 60} 分 ${widget.durationSeconds % 60} 秒',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 16),
            ]),
          ),

          if (widget.detail != null && widget.detail!.isNotEmpty)
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('对比详情', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                const SizedBox(height: 10),
                _DiffView(diffHtml: widget.detail!),
              ]),
            ),

          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onRetry();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('再来一次'),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  // 返回到文章详情
                  Navigator.popUntil(context, (route) => route.isFirst || route.settings.name == '/detail');
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('返回文章'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _DiffView extends StatelessWidget {
  final String diffHtml;
  const _DiffView({required this.diffHtml});

  @override
  Widget build(BuildContext context) {
    // 简单文字展示
    return Text(
      diffHtml,
      style: const TextStyle(fontSize: 15, height: 1.8),
    );
  }
}
