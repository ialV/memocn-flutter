import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/article.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'practice/cover_screen.dart';
import 'practice/fillblank_screen.dart';
import 'practice/firstchar_screen.dart';
import 'practice/recite_screen.dart';
import 'practice/shuffle_screen.dart';
import 'practice/listen_screen.dart';

class DetailScreen extends StatefulWidget {
  final String articleId;
  const DetailScreen({super.key, required this.articleId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String _selectedMode = 'cover';
  bool _expanded = false;
  final FlutterTts _tts = FlutterTts();
  bool _playing = false;

  static const _modes = [
    ('cover', '🖐', '遮盖练习', '点击句子遮盖回忆'),
    ('fillblank', '✏️', '填空练习', '挖空关键词填写'),
    ('firstchar', '🔤', '首字提示', '只显示每句首字'),
    ('recite', '📝', '默写模式', '完全默写对比原文'),
    ('shuffle', '🔀', '乱序重组', '拖拽还原句子顺序'),
    ('listen', '👂', '听写模式', '听音频默写全文'),
  ];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.45);
    _tts.setCompletionHandler(() => setState(() => _playing = false));
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Article? get _article {
    final state = context.read<AppState>();
    try {
      return state.articles.firstWhere((a) => a.id == widget.articleId);
    } catch (_) {
      return null;
    }
  }

  void _toggleTts() async {
    final a = _article;
    if (a == null) return;
    if (_playing) {
      await _tts.stop();
      setState(() => _playing = false);
    } else {
      setState(() => _playing = true);
      await _tts.speak(a.content);
    }
  }

  void _startPractice() {
    final a = _article;
    if (a == null) return;
    _tts.stop();
    Widget screen;
    switch (_selectedMode) {
      case 'cover':    screen = CoverScreen(article: a); break;
      case 'fillblank': screen = FillblankScreen(article: a); break;
      case 'firstchar': screen = FirstcharScreen(article: a); break;
      case 'recite':   screen = ReciteScreen(article: a); break;
      case 'shuffle':  screen = ShuffleScreen(article: a); break;
      case 'listen':   screen = ListenScreen(article: a); break;
      default:         screen = CoverScreen(article: a);
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _deleteArticle() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除文章'),
        content: const Text('确定删除这篇文章吗？相关练习记录也会一并删除。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AppState>().deleteArticle(widget.articleId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final article = state.articles.firstWhere(
        (a) => a.id == widget.articleId,
        orElse: () => Article(id: '', title: '', content: '', createdAt: DateTime.now()),
      );
      if (article.id.isEmpty) return const Scaffold(body: Center(child: Text('文章不存在')));

      return Scaffold(
        appBar: AppBar(
          title: Text(article.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              icon: Icon(_playing ? Icons.stop_circle_outlined : Icons.volume_up_outlined),
              tooltip: _playing ? '停止朗读' : '朗读全文',
              color: _playing ? AppTheme.primary : null,
              onPressed: _toggleTts,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '删除文章',
              color: AppTheme.danger,
              onPressed: _deleteArticle,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // 文章预览
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(article.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Row(children: [
                      Text('${article.sentenceCount} 句 · ${article.charCount} 字',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      if (article.tag.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        AppTag(text: article.tag),
                      ],
                    ]),
                  ])),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  const Text('掌握度', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  const SizedBox(width: 8),
                  Expanded(child: MasteryBar(score: article.masteryScore)),
                  const SizedBox(width: 8),
                  Text('${article.masteryScore}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ]),
                const SizedBox(height: 12),
                AnimatedCrossFade(
                  firstChild: Text(
                    article.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, height: 1.8, color: Color(0xFF374151)),
                  ),
                  secondChild: Text(
                    article.content,
                    style: const TextStyle(fontSize: 15, height: 1.8, color: Color(0xFF374151)),
                  ),
                  crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
                TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: Text(_expanded ? '收起 ▲' : '展开全文 ▼',
                      style: const TextStyle(fontSize: 13, color: AppTheme.primary)),
                ),
              ]),
            ),

            // 练习模式选择
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('选择练习模式', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: _modes.map((m) => _ModeCard(
                    emoji: m.$2,
                    title: m.$3,
                    desc: m.$4,
                    selected: _selectedMode == m.$1,
                    onTap: () => setState(() => _selectedMode = m.$1),
                  )).toList(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _startPractice,
                    child: const Text('开始练习 →', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
    });
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji, title, desc;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji, required this.title, required this.desc,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.primary : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
