import 'dart:collection';
import 'dart:io' show Platform;
import 'manga_isar.dart';

extension MangaConstants on Manga {
  static const TRACK_URL = 'https://manganelo.com/manga/tm923455';
  static const MIN_RATE = 4.6;
  static const MAX_RATE = 5.0;
  static const MIN_VIEWS = 300000;
  static const MAX_UPDATED_DAYS = 30;
  // ignore: non_constant_identifier_names
  static final MAX_PAGE = Platform.isAndroid ? 65 : 5;
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
    return '$t (${currentChap()}/${lastChap()})';
  }

  String toStr() {
    return 'Manga(#$id, $url, $rate, $updatedAt, $viewsCount, $order)\n';
  }

  void updateCurrentReading(String chapterUrl) async {
    currentChapterUrl = chapterUrl;
    readCount++;
    save();
  }
}

extension MangaHelpers on Manga {
  static int compare(a, b) {
    final c = b.updatedAt.compareTo(a.updatedAt);
    if (c != 0) return c;
    if (a.readCount > b.readCount) return -1;
    if (a.readCount < b.readCount) return 1;
    if (a.rate < b.rate) return -1;
    if (a.rate > b.rate) return 1;
    if (a.viewsCount < b.viewsCount) return -1;
    return 1;
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

  static groupMangasByUpdatedAt(
      SplayTreeSet<Manga> mangas, Map<String, SplayTreeSet<Manga>> map) {
    final now = DateTime.now();
    for (var manga in mangas) {
      final title = dayDiffToStr(now.difference(manga.updatedAt).inDays);
      if (title != "" && manga.rate >= MangaConstants.MIN_RATE) {
        (map[title] ??= SplayTreeSet<Manga>(MangaHelpers.compare)).add(manga);
        if (manga.url == MangaConstants.TRACK_URL) {
          print('\n- - - - \nFOUND@groupMangasByUpdatedAt: ${manga.toStr()}\n');
        }
      }
    }
  }
}
