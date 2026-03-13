import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/article.dart';
import '../services/app_state.dart';
import '../theme.dart';

class AddArticleScreen extends StatefulWidget {
  const AddArticleScreen({super.key});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  String _selectedIcon = '📄';
  bool _saving = false;

  static const _icons = ['📄', '📜', '📝', '🗒️', '📃', '📋', '🌸', '🌙', '🏔️', '🎭'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty) {
      _showSnack('请输入文章标题');
      return;
    }
    if (content.isEmpty) {
      _showSnack('请输入文章内容');
      return;
    }
    setState(() => _saving = true);
    final state = context.read<AppState>();
    await state.addArticle(Article(
      id: const Uuid().v4(),
      title: title,
      content: content,
      tag: _tagCtrl.text.trim(),
      icon: _selectedIcon,
      createdAt: DateTime.now(),
    ));
    if (mounted) Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增文章'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('保存', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // 图标选择
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('选择图标', style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _icons.map((ico) => GestureDetector(
                  onTap: () => setState(() => _selectedIcon = ico),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _selectedIcon == ico ? AppTheme.primaryLight : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedIcon == ico ? AppTheme.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(child: Text(ico, style: const TextStyle(fontSize: 20))),
                  ),
                )).toList(),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          // 标题
          _Field(label: '文章标题', controller: _titleCtrl, hint: '例：《荷塘月色》'),
          const SizedBox(height: 12),
          // 内容
          _Field(
            label: '文章内容',
            controller: _contentCtrl,
            hint: '将文章内容粘贴到这里……',
            maxLines: 8,
          ),
          const SizedBox(height: 12),
          // 标签
          _Field(label: '分组标签（可选）', controller: _tagCtrl, hint: '例：语文课文、古诗词'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _saving ? null : _save, child: const Text('保存文章')),
          ),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint, border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, fillColor: Colors.transparent),
        ),
      ]),
    );
  }
}
