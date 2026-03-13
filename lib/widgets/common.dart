import 'package:flutter/material.dart';
import '../theme.dart';

// 卡片容器
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// 进度条
class MasteryBar extends StatelessWidget {
  final int score;
  const MasteryBar({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? AppTheme.success
        : score >= 50
            ? AppTheme.warn
            : AppTheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: score / 100,
        backgroundColor: const Color(0xFFE5E7EB),
        valueColor: AlwaysStoppedAnimation(color),
        minHeight: 5,
      ),
    );
  }
}

// 标签
class AppTag extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;

  const AppTag({super.key, required this.text, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppTheme.primary,
        ),
      ),
    );
  }
}

// 分数圈
class ScoreCircle extends StatelessWidget {
  final int score;
  const ScoreCircle({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? AppTheme.success
        : score >= 50
            ? AppTheme.warn
            : AppTheme.danger;
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 5),
      ),
      child: Center(
        child: Text(
          '$score%',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: color),
        ),
      ),
    );
  }
}

// 难度选择器
class DifficultySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const DifficultySelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final levels = [
      ('easy', '初级'),
      ('medium', '中级'),
      ('hard', '高级'),
      ('extreme', '地狱'),
    ];
    return Row(
      children: levels
          .map((l) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => onChanged(l.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: selected == l.$1 ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: selected == l.$1 ? AppTheme.primary : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      l.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selected == l.$1 ? Colors.white : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
