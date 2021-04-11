import 'dart:math';
import 'dart:collection';
import 'dart:io' show Platform;
import 'manga_isar.dart';

extension MangaConstants on Manga {
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

  // ignore: non_constant_identifier_names
  static DateTime _BEGIN_DATE = DateTime.utc(2020, 1, 1);
  double computeOrder({cached = true}) {
    if (!cached || order == 0) {
      order = updatedAt.difference(_BEGIN_DATE).inDays * 10000000 +
          readCount.abs() * 100 +
          (rate * 10).abs() +
          viewsCount.abs() / 1000000000000 +
          Random().nextInt(999999) / 1000000000000000000;
    }
    return order;
  }

  String toStr() {
    return 'Manga(#$id, $url, $rate, $updatedAt, $viewsCount)\n';
  }

  void updateCurrentReading(String chapterUrl) async {
    currentChapterUrl = chapterUrl;
    readCount++;
    save();
  }
}

extension MangaHelpers on Manga {
  static int compare(a, b) => -a.order.compareTo(b.order);

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
      final k = dayDiffToStr(now.difference(manga.updatedAt).inDays);
      if (k != "" && manga.rate >= MangaConstants.MIN_RATE) {
        (map[k] ??= SplayTreeSet<Manga>(MangaHelpers.compare)).add(manga);
      }
    }
  }
}
