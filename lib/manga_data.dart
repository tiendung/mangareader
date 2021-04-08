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

  String lastChapterUrl = "";

  String currentChapterUrl = "";

  int readCount = 0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  String firstChapterUrl() {
    return lastChapterUrl.split('chapter_').first + 'chapter_1';
  }

  String fullTitle() {
    return '$title (${lastChapterUrl.split('chapter_').last})';
  }

  void updateCurrentReading(String chapterUrl) async {
    // print(chapterUrl);
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
