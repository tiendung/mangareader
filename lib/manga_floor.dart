import 'package:floor/floor.dart';
import 'db_floor.dart';

@entity
class Manga {
  @primaryKey
  String url;

  String title;
  String coverImageUrl;

  double rate;
  int viewsCount;

  String lastChapterUrl;
  String currentChapterUrl;
  int currentScrollY;
  int readCount;

  DateTime createdAt;
  DateTime updatedAt;

  Manga(
      this.url,
      this.title,
      this.coverImageUrl,
      this.rate,
      this.viewsCount,
      this.lastChapterUrl,
      this.currentChapterUrl,
      this.currentScrollY,
      this.readCount,
      this.createdAt,
      this.updatedAt);

  static Manga newManga() {
    return Manga(
        "", "", "", 0, 0, "", "", 0, 0, DateTime.now(), DateTime.now());
  }

  void save({bool isNew = true}) async {
    final mangaDao = (await Db.get()).mangaDao;
    if (isNew)
      mangaDao.saveAll([this]);
    else
      mangaDao.updateAll([this]);
  }

  static Future<Manga?> findByUrl(String url) async {
    return (await Db.get()).mangaDao.findByUrl(url);
  }

  static Future<List<Manga>> loadAll() async {
    return (await Db.get()).mangaDao.loadAll();
  }
}

@dao
abstract class MangaDao {
  @Query('SELECT * FROM Manga')
  Future<List<Manga>> loadAll();

  @Query('SELECT * FROM Manga WHERE url = :url')
  Future<Manga?> findByUrl(String url);

  @insert
  Future<List<int>> saveAll(List<Manga> mangas);

  @update
  Future<int> updateAll(List<Manga> mangas);
}
