import 'dart:collection';
import 'dart:io';
// import 'manga_isar.dart';
import 'manga_floor.dart';

extension MangaConstants on Manga {
  static final MAX_PAGE = Platform.isAndroid ? 65 : 5;
  static const MIN_RATE = 4.6;
  static const MIN_VIEWS = 300000;

  static final TOP_MAX_PAGE = Platform.isAndroid ? 23 : 5;
  static const TOP_MIN_RATE = 4.8;
  static const TOP_MIN_VIEWS = 8000000;

  static const MAX_UPDATED_DAYS = 30;
  static const MIN_READ_COUNT = 2;
  static const MAX_RATE = 5.0;

  static const TRACK_URL = 'https://manganelo.com/manga/nn922116';
}

extension MangaMethods on Manga {
  String firstChapterUrl() {
    return lastChapterUrl.split('chapter_').first + 'chapter_1';
  }

  String defaultChapterUrl() {
    return currentChapterUrl != "" ? currentChapterUrl : firstChapterUrl();
  }

  String lastChap() {
    return lastChapterUrl.split('chapter_').last;
  }

  String currentChap() {
    return defaultChapterUrl().split('chapter_').last;
  }

  String fullTitle() {
    final t = (title.length <= 40) ? title : title.substring(0, 37) + '...';
    return '[$rate] $t (${readCount == 0 ? 0 : currentChap()}/${lastChap()})';
  }

  String toStr() {
    return 'Manga(#$url, $rate, $updatedAt, $viewsCount)\n';
  }

  void updateCurrentReading(String chapterUrl) async {
    currentChapterUrl = chapterUrl;
    readCount++;
    save(isNew: false);
  }

  updateCurrentScrollY(String scrollY) {
    currentScrollY = double.parse(scrollY).floor();
    save(isNew: false);
  }
}

extension MangaHelpers on Manga {
  static int sortByUpdatedDateDesc(a, b) {
    // if (c == 0) c = b.readCount.compareTo(a.readCount);
    // if (c == 0) c = b.rate.compareTo(a.rate);
    // if (c == 0) c = b.viewsCount.compareTo(a.viewsCount);
    var c = b.updatedAt.compareTo(a.updatedAt);
    if (c == 0) return a.url.compareTo(b.url);
    return c;
  }

  static int sortByReadThenRateDesc(a, b) {
    var c = b.readCount.compareTo(a.readCount);
    if (c == 0) c = b.rate.compareTo(a.rate);
    if (c == 0) c = b.viewsCount.compareTo(a.viewsCount);
    if (c == 0) return a.id.compareTo(b.id);
    return c;
  }

  static int sortBy(a, b) {
    // if (c == 0) c = b.readCount.compareTo(a.readCount);
    // if (c == 0) c = b.rate.compareTo(a.rate);
    // if (c == 0) c = b.viewsCount.compareTo(a.viewsCount);
    var c = b.updatedAt.compareTo(a.updatedAt);
    if (c == 0) return a.id.compareTo(b.id);
    return c;
  }

  static String dayDiffToStr(d) {
    if (d <= 1) {
      return "Today";
    } else if (d <= 3) {
      return "Two Days Ago";
    } else if (d <= 7) {
      return "Last Week";
    } else if (d <= 14) {
      return "Last Two Weeks";
    } else if (d <= 30) {
      return "Last Month";
    } else {
      return "";
    }
  }

  static void groupMangas(
      SplayTreeSet<Manga> mangas, Map<String, SplayTreeSet<Manga>> map) {
    final now = DateTime.now();
    map["Recommend"] = SplayTreeSet<Manga>(MangaHelpers.sortByReadThenRateDesc);
    for (int i = 0; i < mangas.length; i++) {
      final manga = mangas.elementAt(i);
      if (manga.readCount >= MangaConstants.MIN_READ_COUNT) {
        map["Recommend"]!.add(manga);
      } else {
        if (manga.rate >= MangaConstants.TOP_MIN_RATE &&
            manga.viewsCount >= MangaConstants.TOP_MIN_VIEWS) {
          map["Recommend"]!.add(manga);
        }
        final title = dayDiffToStr(now.difference(manga.updatedAt).inDays);
        if (title != "") {
          (map[title] ??=
                  SplayTreeSet<Manga>(MangaHelpers.sortByReadThenRateDesc))
              .add(manga);
        }
      }
      if (manga.url == MangaConstants.TRACK_URL)
        print('\n- - -\nFOUND @ groupMangasByUpdatedAt(): ${manga.toStr()}\n');
    }
  }
}
