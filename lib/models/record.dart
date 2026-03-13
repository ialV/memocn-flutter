import 'dart:convert';

class PracticeRecord {
  final String id;
  final String articleId;
  final String articleTitle;
  final String mode;
  final int score;
  final int durationSeconds;
  final DateTime time;

  PracticeRecord({
    required this.id,
    required this.articleId,
    required this.articleTitle,
    required this.mode,
    required this.score,
    required this.durationSeconds,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'articleId': articleId,
        'articleTitle': articleTitle,
        'mode': mode,
        'score': score,
        'durationSeconds': durationSeconds,
        'time': time.toIso8601String(),
      };

  factory PracticeRecord.fromJson(Map<String, dynamic> json) => PracticeRecord(
        id: json['id'],
        articleId: json['articleId'],
        articleTitle: json['articleTitle'] ?? '',
        mode: json['mode'],
        score: json['score'],
        durationSeconds: json['durationSeconds'] ?? 0,
        time: DateTime.parse(json['time']),
      );

  static List<PracticeRecord> listFromJson(String jsonStr) {
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => PracticeRecord.fromJson(e)).toList();
  }

  static String listToJson(List<PracticeRecord> records) {
    return jsonEncode(records.map((r) => r.toJson()).toList());
  }
}
