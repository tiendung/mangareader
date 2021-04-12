import 'dart:collection';
import 'dart:io' show Platform;
import 'manga_isar.dart';

extension MangaConstants on Manga {
  static const TRACK_URL = 'https://manganelo.com/manga/tm923455';
  static const MIN_RATE = 4.6;
  static const TOP_MIN_RATE = 4.8;
  static const MAX_RATE = 5.0;
  static const MIN_VIEWS = 500000;
  static const TOP_MIN_VIEWS = 10000000;
  static const MAX_UPDATED_DAYS = 30;
  static const MIN_READ_COUNT = 2;
  // ignore: non_constant_identifier_names
  static final MAX_PAGE = Platform.isAndroid ? 65 : 5;
  static const TOP_MAX_PAGE = 23;
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
    return 'Manga(#$id, $url, $rate, $updatedAt, $viewsCount, $order)\n';
  }

  void updateCurrentReading(String chapterUrl) async {
    currentChapterUrl = chapterUrl;
    readCount++;
    save();
  }

  updateCurrentScrollY(String scrollY) {
    currentScrollY = double.parse(scrollY).floor();
    save();
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
      // if (manga.url == MangaConstants.TRACK_URL)
      //   print('\n- - -\nFOUND @ groupMangasByUpdatedAt: ${manga.toStr()}\n');
    }
  }
}
