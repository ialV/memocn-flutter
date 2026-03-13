import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/article.dart';
import '../models/record.dart';
import 'storage_service.dart';

class AppState extends ChangeNotifier {
  List<Article> articles = [];
  List<PracticeRecord> records = [];
  bool loaded = false;
  static const _uuid = Uuid();

  Future<void> init() async {
    articles = await StorageService.loadArticles();
    records = await StorageService.loadRecords();
    loaded = true;
    notifyListeners();
  }

  Future<void> addArticle(Article a) async {
    articles.add(a);
    await StorageService.saveArticles(articles);
    notifyListeners();
  }

  Future<void> deleteArticle(String id) async {
    articles.removeWhere((a) => a.id == id);
    records.removeWhere((r) => r.articleId == id);
    await StorageService.saveArticles(articles);
    await StorageService.saveRecords(records);
    notifyListeners();
  }

  Future<void> addRecord(PracticeRecord r) async {
    records.add(r);
    // 更新文章掌握度
    final article = articles.firstWhere((a) => a.id == r.articleId, orElse: () => articles.first);
    final articleRecords = records.where((rec) => rec.articleId == r.articleId).toList();
    article.masteryScore = articleRecords.map((rec) => rec.score).reduce((a, b) => a > b ? a : b);
    await StorageService.saveRecords(records);
    await StorageService.saveArticles(articles);
    notifyListeners();
  }

  String newId() => _uuid.v4();

  List<PracticeRecord> recordsFor(String articleId) =>
      records.where((r) => r.articleId == articleId).toList();

  int practiceCountToday() {
    final today = DateTime.now();
    return records
        .where((r) =>
            r.time.year == today.year &&
            r.time.month == today.month &&
            r.time.day == today.day)
        .length;
  }
}
