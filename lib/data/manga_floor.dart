import 'package:floor/floor.dart';
import 'db_floor.dart';
import 'manga_data.dart';

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
  DateTime readAt;

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
    this.updatedAt,
    this.readAt,
  );

  static Manga newManga() {
    return Manga("", "", "", 0, 0, "", "", 0, 0, DateTime.now(), DateTime.now(),
        DateTime.utc(1900, 1, 1));
  }

  void save({bool isNew = true}) async {
    final mangaDao = (await getDb()).mangaDao;
    if (isNew)
      mangaDao.saveAll([this]);
    else
      mangaDao.updateAll([this]);
  }

  static Future<Manga?> findByUrl(String url) async {
    return (await getDb()).mangaDao.findByUrl(url);
  }

  static Future<List<Manga>> loadAll({int daysAgo = MangaConstants.MAX_DAYS_AGO}) async {
    int nowInMs = DateTime.now().millisecondsSinceEpoch;
    int daysAgoInMs = Duration(days: daysAgo).inMilliseconds;
    return (await getDb()).mangaDao.loadAll(nowInMs - daysAgoInMs);
  }
}

@dao
abstract class MangaDao {
  @Query('SELECT * FROM Manga WHERE `updatedAt` >= :minUpdatedAt')
  Future<List<Manga>> loadAll(int minUpdatedAt);

  @Query('SELECT * FROM Manga WHERE url = :url')
  Future<Manga?> findByUrl(String url);

  @insert
  Future<List<int>> saveAll(List<Manga> mangas);

  @update
  Future<int> updateAll(List<Manga> mangas);
}
