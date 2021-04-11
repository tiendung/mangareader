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

  double rate = 0;

  int viewsCount = 0;

  String lastChapterUrl = "";

  String currentChapterUrl = "";

  int readCount = 0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  @Index(indexType: IndexType.value)
  double order = 0;

  int currentScrollY = 0;

  void save() async {
    Manga.saveAll([this]);
  }

// Class methods
  static Future<List<Manga>> loadAll() async {
    final isar = await openIsar();
    // await isar.writeTxn((isar) async => await isar.mangas.where().deleteAll());
    return await isar.mangas.where().findAll();
  }

  static saveAll(List<Manga> mangas) async {
    final isar = await openIsar();
    isar.writeTxn((isar) async {
      await isar.mangas.putAll(mangas);
    });
  }
}
