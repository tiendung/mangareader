import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'manga_data.dart';
import 'manga_isar.dart';

final mangasProvider =
    StateNotifierProvider<MangasNotifier, SplayTreeSet<Manga>>(
        (ref) => MangasNotifier()..update());

class MangasNotifier extends StateNotifier<SplayTreeSet<Manga>> {
  MangasNotifier() : super(SplayTreeSet<Manga>(MangaHelpers.compare));

  Future<void> update() async {
    await load();
    for (var i = 1; i <= MangaConstants.MAX_PAGE; i++) {
      await crawl('https://manganelo.com/genre-all/$i');
      await crawl('https://manganelo.com/genre-all/$i?type=topview');
      await load();
    }
  }

  Future<void> crawl(String url) async {
    final now = DateTime.now();

    final res = await Dio().get(url);
    final splits = res.data.toString().split('class="content-genres-item"');
    final List<Manga> mangas = [];

    splits.forEach((s) async {
      var urlAndTitleMatch =
          RegExp(r'class="genres-item-name .+?" href="(.+?)" title="(.+?)"')
              .firstMatch(s);
      if (urlAndTitleMatch == null) return;

      final lastChapMatch =
          RegExp(r'class="genres-item-chap .+?" href="(.+?)"').firstMatch(s);
      if (lastChapMatch == null) return;

      final url = urlAndTitleMatch[1]!.trim().toLowerCase();
      var isNewManga = false;
      final manga = state.firstWhere((x) => x.url == url, orElse: () {
        isNewManga = true;
        return Manga();
      });

      final viewsMatch =
          RegExp(r'class="genres-item-view">(.+?)<').firstMatch(s);
      final viewsCount = int.parse(viewsMatch![1]!.replaceAll(",", ""));
      if (isNewManga && viewsCount < MangaConstants.MIN_VIEWS) return;

      final rateMatch =
          RegExp(r'<em class="genres-item-rate">(.+?)</em>').firstMatch(s);
      final rate = rateMatch != null ? double.parse(rateMatch[1]!) : 4.6;
      if (isNewManga && rate < MangaConstants.MIN_RATE) return;

      final updatedAtStr =
          RegExp(r'class="genres-item-time">(.+?)<').firstMatch(s)![1]!;
      final updatedAt = DateFormat('MMM d,yy', 'en_US').parse(updatedAtStr);
      if (isNewManga &&
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
        ..rate =
            rate <= MangaConstants.MAX_RATE ? rate : MangaConstants.MIN_RATE;

      mangas.add(manga);
      if (manga.url == MangaConstants.TRACK_URL) {
        print('\n- - - - \nFOUND @ crawl: ${manga.toStr()}\n');
      }
      // print('\n- - - - - - - - - -\n$url, $isNewManga, ${manga.toStr()}\n\n');
    });

    Manga.saveAll(mangas);
    state.addAll(mangas);
  }

  Future<void> load() async {
    final sortedMangas = SplayTreeSet<Manga>(MangaHelpers.compare);
    for (var manga in await Manga.loadAll())
      if (manga.rate >= MangaConstants.MIN_RATE) sortedMangas.add(manga);
    state = sortedMangas;
  }
}
