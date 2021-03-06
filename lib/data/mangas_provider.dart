import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'package:mangareader/data/manga_data.dart';
import 'package:mangareader/data/manga_floor.dart';

final mangasProvider =
    StateNotifierProvider<MangasNotifier, SplayTreeSet<Manga>>(
        (ref) => MangasNotifier()..totalUpdate());

var mangasCrawling = false;

class MangasNotifier extends StateNotifier<SplayTreeSet<Manga>> {
  MangasNotifier()
      : super(SplayTreeSet<Manga>(MangaHelpers.sortByUpdatedDateDesc));

  Future<void> totalUpdate() async {
    await updateNewest(MangaConstants.MAX_PAGE);
    mangasCrawling = true;
    // Update top view mangas
    for (var i = 1; i <= MangaConstants.TOP_MAX_PAGE; i++) {
      await crawl(
          'https://manganelo.com/advanced_search?s=all&orby=topview&page=$i',
          false);
      await load();
    }
    mangasCrawling = false;
  }

  Future<int> updateNewest(int max) async {
    if (mangasCrawling) return 0;
    mangasCrawling = true;
    await load();
    var total = 0;
    for (var i = 1; i <= max; i++) {
      total += await crawl('https://manganelo.com/genre-all/$i', true);
      await load();
    }
    mangasCrawling = false;
    return total;
  }

  Future<int> crawl(String pageUrl, bool isNewest) async {
    var total = 0;
    final now = DateTime.now();

    final minRate =
        isNewest ? MangaConstants.MIN_RATE : MangaConstants.TOP_MIN_RATE;

    final minViews =
        isNewest ? MangaConstants.MIN_VIEWS : MangaConstants.TOP_MIN_VIEWS;

    final res = await Dio().get(pageUrl);
    final splits = res.data.toString().split('class="content-genres-item"');

    for (var i = 0; i < splits.length; i++) {
      final s = splits.elementAt(i);
      var urlAndTitleMatch =
          RegExp(r'class="genres-item-name .+?" href="(.+?)" title="(.+?)"')
              .firstMatch(s);
      if (urlAndTitleMatch == null) continue;

      final lastChapMatch =
          RegExp(r'class="genres-item-chap .+?" href="(.+?)"').firstMatch(s);
      if (lastChapMatch == null) continue;

      final url = urlAndTitleMatch[1]!.trim().toLowerCase();

      final found = await Manga.findByUrl(url);
      final isNewManga = found == null;
      final manga = isNewManga ? Manga.newManga() : found!;

      final viewsMatch =
          RegExp(r'class="genres-item-view">(.+?)<').firstMatch(s);
      final viewsCount = int.parse(viewsMatch![1]!.replaceAll(",", ""));
      if (isNewManga && viewsCount < minViews) continue;

      final rateMatch =
          RegExp(r'<em class="genres-item-rate">(.+?)</em>').firstMatch(s);
      final rate = rateMatch != null ? double.parse(rateMatch[1]!) : 4.6;
      if (isNewManga && rate < minRate) continue;

      final updatedAtStr =
          RegExp(r'class="genres-item-time">(.+?)<').firstMatch(s)![1]!;
      final updatedAt = DateFormat('MMM d,yy', 'en_US').parse(updatedAtStr);
      if (isNewManga &&
          isNewest &&
          now.difference(updatedAt).inDays > MangaConstants.MAX_UPDATED_DAYS)
        continue;

      final coverImageMatch =
          RegExp(r'<img class="img-loading" src="(.+?jpg)"').firstMatch(s);

      manga
        ..url = url
        ..title = urlAndTitleMatch[2]!
        ..lastChapterUrl = lastChapMatch[1]!
        ..coverImageUrl = coverImageMatch![1]!
        ..viewsCount = viewsCount
        ..updatedAt = updatedAt
        ..rate = rate <= MangaConstants.MAX_RATE ? rate : MangaConstants.MAX_RATE;

      manga.save(isNew: isNewManga);
      total++;
      if (manga.url == MangaConstants.TRACK_URL) print('\n- - - - \nFOUND @ crawl(): ${manga.toStr()} <== $pageUrl\n');
      // print('\n- - - - - - - - - -\n$url, $isNewManga, ${manga.toStr()}\n\n');
    }
    return total;
  }

  Future<void> load() async {
    final sortedMangas =
        SplayTreeSet<Manga>(MangaHelpers.sortByUpdatedDateDesc);
    for (var manga in await Manga.loadAll()) {
      if (manga.rate >= MangaConstants.MIN_RATE) sortedMangas.add(manga);
      // print('\n- - - - - - - - - -\n${manga.toStr()}\n\n');
    }
    state = sortedMangas;
  }
}
