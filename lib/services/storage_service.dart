import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';
import '../models/record.dart';

class StorageService {
  static const _articlesKey = 'articles';
  static const _recordsKey = 'records';

  static Future<List<Article>> loadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_articlesKey);
    if (str == null || str.isEmpty) return _demoArticles();
    try {
      return Article.listFromJson(str);
    } catch (_) {
      return _demoArticles();
    }
  }

  static Future<void> saveArticles(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_articlesKey, Article.listToJson(articles));
  }

  static Future<List<PracticeRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_recordsKey);
    if (str == null || str.isEmpty) return [];
    try {
      return PracticeRecord.listFromJson(str);
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveRecords(List<PracticeRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recordsKey, PracticeRecord.listToJson(records));
  }

  static List<Article> _demoArticles() => [
        Article(
          id: 'demo1',
          title: '《荷塘月色》节选',
          content:
              '这几天心里颇不宁静。今晚在院子里坐着乘凉，忽然想起日日走过的荷塘，在这满月的光里，总该另有一番样子吧。月亮渐渐地升高了，墙外马路上孩子们的欢笑，已经听不见了；妻在屋里拍着闰儿，迷迷糊糊地哼着眠歌。我悄悄地披了大衫，带上门出去。',
          tag: '语文课文',
          icon: '🌸',
          createdAt: DateTime.now(),
        ),
        Article(
          id: 'demo2',
          title: '《静夜思》',
          content: '床前明月光，疑是地上霜。举头望明月，低头思故乡。',
          tag: '古诗词',
          icon: '🌙',
          createdAt: DateTime.now(),
        ),
      ];
}
