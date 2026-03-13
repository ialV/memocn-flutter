import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final records = state.records;
      final articles = state.articles;
      final total = records.length;
      final totalChars = records.fold<int>(
        0,
        (sum, r) {
          final a = articles.where((a) => a.id == r.articleId).firstOrNull;
          return sum + (a?.charCount ?? 0);
        },
      );
      final avgScore = total == 0
          ? 0
          : (records.fold<int>(0, (s, r) => s + r.score) / total).round();

      // 近30天打卡
      final now = DateTime.now();
      final heatmapData = List.generate(30, (i) {
        final d = now.subtract(Duration(days: 29 - i));
        final count = records
            .where((r) =>
                r.time.year == d.year &&
                r.time.month == d.month &&
                r.time.day == d.day)
            .length;
        return count;
      });

      return Scaffold(
        appBar: AppBar(title: const Text('练习统计')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // 总览统计
            Row(children: [
              _StatCard(value: '$total', label: '练习次数', icon: '🎯'),
              const SizedBox(width: 10),
              _StatCard(value: '$totalChars', label: '练习字数', icon: '✍️'),
              const SizedBox(width: 10),
              _StatCard(value: '$avgScore%', label: '平均得分', icon: '📊'),
            ]),

            // 热力图
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('近 30 天练习记录',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: heatmapData.map((count) {
                    Color color;
                    if (count == 0) color = const Color(0xFFF3F4F6);
                    else if (count == 1) color = const Color(0xFFC7D2FE);
                    else if (count <= 3) color = const Color(0xFF818CF8);
                    else color = AppTheme.primary;
                    return Tooltip(
                      message: '$count 次',
                      child: Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('少', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  const SizedBox(width: 4),
                  ...[ Color(0xFFF3F4F6), Color(0xFFC7D2FE), Color(0xFF818CF8), AppTheme.primary].map((c) =>
                    Container(
                      width: 12, height: 12,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
                    )
                  ),
                  const Text('多', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                ]),
              ]),
            ),

            // 各文章掌握情况
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('各文章掌握情况',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                const SizedBox(height: 12),
                if (articles.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('暂无文章', style: TextStyle(color: Color(0xFF9CA3AF))),
                    ),
                  )
                else
                  ...articles.map((a) {
                    final recs = state.recordsFor(a.id);
                    final best = recs.isEmpty ? 0 : recs.map((r) => r.score).reduce((a, b) => a > b ? a : b);
                    final count = recs.length;
                    final color = best >= 80 ? AppTheme.success : best >= 50 ? AppTheme.warn : AppTheme.danger;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(a.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(a.title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                          Text('练 $count 次',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                          const SizedBox(width: 8),
                          Text('$best%',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                        ]),
                        const SizedBox(height: 5),
                        MasteryBar(score: best),
                      ]),
                    );
                  }),
              ]),
            ),

            // 最近练习记录
            if (records.isNotEmpty)
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('最近练习',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                  const SizedBox(height: 10),
                  ...records.reversed.take(10).map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          AppTag(
                            text: r.mode,
                            color: AppTheme.primaryLight,
                            textColor: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(r.articleTitle,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            '${r.score}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: r.score >= 80
                                  ? AppTheme.success
                                  : r.score >= 50
                                      ? AppTheme.warn
                                      : AppTheme.danger,
                            ),
                          ),
                        ]),
                      )),
                ]),
              ),
          ]),
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String value, label, icon;
  const _StatCard({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        ]),
      ),
    );
  }
}
