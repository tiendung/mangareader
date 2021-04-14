import 'package:isar/isar.dart';
import 'isar.g.dart';

@Collection()
class Manga {
  @Id()
  int? id;

  @Index(indexType: IndexType.words) // Search index
  String title = "";

  String coverImageUrl = "";

  @Index(indexType: IndexType.value)
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

  void save({bool isNew = true}) {
    Manga.saveAll([this]);
  }

// Class methods
  static Isar? isar;

  static initIsar() async {
    if (isar == null) {
      isar = await openIsar();
    }
  }

  static Future<Manga> findByUrl(String url) async {
    final mangas = await loadAll();
    return mangas.firstWhere((x) => x.url == url, orElse: () {
      return Manga();
    });
  }

  static Future<List<Manga>> loadAll() async {
    await initIsar();
    // await isar!.writeTxn((isar) async => await isar.mangas.where().deleteAll());
    return await isar!.mangas.where().findAll();
  }

  static saveAll(List<Manga> mangas) async {
    await initIsar();
    isar!.writeTxn((isar) async {
      await isar.mangas.putAll(mangas);
    });
  }
}
