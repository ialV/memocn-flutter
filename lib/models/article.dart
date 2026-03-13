import 'dart:convert';

class Article {
  final String id;
  String title;
  String content;
  String tag;
  String icon;
  final DateTime createdAt;
  int masteryScore; // 0-100

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.tag = '',
    this.icon = '📄',
    required this.createdAt,
    this.masteryScore = 0,
  });

  List<String> get sentences {
    final parts = content.split(RegExp(r'(?<=[。！？；…\n])'));
    return parts.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  int get charCount => content.length;
  int get sentenceCount => sentences.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'tag': tag,
        'icon': icon,
        'createdAt': createdAt.toIso8601String(),
        'masteryScore': masteryScore,
      };

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        tag: json['tag'] ?? '',
        icon: json['icon'] ?? '📄',
        createdAt: DateTime.parse(json['createdAt']),
        masteryScore: json['masteryScore'] ?? 0,
      );

  static List<Article> listFromJson(String jsonStr) {
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => Article.fromJson(e)).toList();
  }

  static String listToJson(List<Article> articles) {
    return jsonEncode(articles.map((a) => a.toJson()).toList());
  }
}
