import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'manga_data.dart';
import 'manga_isar.dart';

final mangasProvider =
    StateNotifierProvider<MangasNotifier, SplayTreeSet<Manga>>(
        (ref) => MangasNotifier()..update());

var mangasCrawling = false;

class MangasNotifier extends StateNotifier<SplayTreeSet<Manga>> {
  MangasNotifier()
      : super(SplayTreeSet<Manga>(MangaHelpers.sortByUpdatedDateDesc));

  Future<void> update() async {
    await updateNewest();
    mangasCrawling = true;
    for (var i = 1; i <= MangaConstants.TOP_MAX_PAGE; i++) {
      await crawl(
          'https://manganelo.com/advanced_search?s=all&orby=topview&page=$i',
          // 'https://manganelo.com/advanced_search?s=all&sts=completed&orby=topview&page=$i',
          false);
    }
    await load();
    mangasCrawling = false;
  }

  Future<void> updateNewest() async {
    if (mangasCrawling) return;
    mangasCrawling = true;
    await load();
    for (var i = 1; i <= MangaConstants.MAX_PAGE; i++) {
      await crawl('https://manganelo.com/genre-all/$i', true);
      await load();
    }
    mangasCrawling = false;
  }

  Future<void> crawl(String pageUrl, bool isNewest) async {
    final now = DateTime.now();

    final res = await Dio().get(pageUrl);
    final splits = res.data.toString().split('class="content-genres-item"');
    final List<Manga> mangas = [];

    final minRate =
        isNewest ? MangaConstants.MIN_RATE : MangaConstants.TOP_MIN_RATE;

    final minViews =
        isNewest ? MangaConstants.MIN_VIEWS : MangaConstants.TOP_MIN_VIEWS;

    splits.forEach((s) async {
      var urlAndTitleMatch =
          RegExp(r'class="genres-item-name .+?" href="(.+?)" title="(.+?)"')
              .firstMatch(s);
      if (urlAndTitleMatch == null) return;

      final lastChapMatch =
          RegExp(r'class="genres-item-chap .+?" href="(.+?)"').firstMatch(s);
      if (lastChapMatch == null) return;

      final url = urlAndTitleMatch[1]!.trim().toLowerCase();
      // final manga = await Manga.findByUrl(url);
      // final isNewManga = manga.id == null;
      var isNewManga = false;
      final manga = state.firstWhere((x) => x.url == url, orElse: () {
        isNewManga = true;
        return Manga();
      });

      final viewsMatch =
          RegExp(r'class="genres-item-view">(.+?)<').firstMatch(s);
      final viewsCount = int.parse(viewsMatch![1]!.replaceAll(",", ""));
      if (isNewManga && viewsCount < minViews) return;

      final rateMatch =
          RegExp(r'<em class="genres-item-rate">(.+?)</em>').firstMatch(s);
      final rate = rateMatch != null ? double.parse(rateMatch[1]!) : 4.6;
      if (isNewManga && rate < minRate) return;

      final updatedAtStr =
          RegExp(r'class="genres-item-time">(.+?)<').firstMatch(s)![1]!;
      final updatedAt = DateFormat('MMM d,yy', 'en_US').parse(updatedAtStr);
      if (isNewManga &&
          isNewest &&
          now.difference(updatedAt).inDays > MangaConstants.MAX_UPDATED_DAYS)
        return;

      final coverImageMatch =
          RegExp(r'<img class="img-loading" src="(.+?jpg)"').firstMatch(s);

      manga
        ..url = url
        ..title = urlAndTitleMatch[2]!
        ..lastChapterUrl = lastChapMatch[1]!
        ..coverImageUrl = coverImageMatch![1]!
        ..viewsCount = viewsCount
        ..updatedAt = updatedAt
        ..rate = rate <= MangaConstants.MAX_RATE ? rate : minRate;

      mangas.add(manga);
      // if (manga.url == MangaConstants.TRACK_URL)
      //   print('\n- - - - \nFOUND @ crawl: ${manga.toStr()}\n');
      // print('\n- - - - - - - - - -\n$url, $isNewManga, ${manga.toStr()}\n\n');
    });

    Manga.saveAll(mangas);
    state.addAll(mangas);
  }

  Future<void> load() async {
    final sortedMangas =
        SplayTreeSet<Manga>(MangaHelpers.sortByUpdatedDateDesc);
    for (var manga in await Manga.loadAll())
      if (manga.rate >= MangaConstants.MIN_RATE) sortedMangas.add(manga);
    state = sortedMangas;
  }
}
