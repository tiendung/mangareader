import 'package:isar/isar.dart';
import 'isar.g.dart';

@Collection()
class Manga {
  @Id()
  int? id;

  @Index(indexType: IndexType.words) // Search index
  String title = "";

  String coverImageUrl = "";

  String url = "";

  double rate = 4.5;

  int viewsCount = 0;

  String lastChapterUrl = "";

  String currentChapterUrl = "";

  int readCount = 0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  String firstChapterUrl() {
    return lastChapterUrl.split('chapter_').first + 'chapter_1';
  }

  String fullTitle() {
    return '$title (${lastChapterUrl.split('chapter_').last})'; //\n\n$rate* ${(viewsCount / 100000).round() / 10.0}m';
  }

  double compareValue() {
    return readCount + (viewsCount / 999999999999.9);
  }

  void updateCurrentReading(String chapterUrl) async {
    currentChapterUrl = chapterUrl;
    readCount++;
    save();
  }

  String defaultChapterUrl() {
    if (currentChapterUrl == "") {
      return lastChapterUrl;
    } else {
      return currentChapterUrl;
    }
  }

  void save() async {
    final isar = await openIsar();
    isar.writeTxn((isar) async {
      await isar.mangas.put(this);
    });
  }
}
