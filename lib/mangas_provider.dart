import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'manga_data.dart';
import 'isar.g.dart';

final mangasProvider = StateNotifierProvider<MangasNotifier, List<Manga>>(
    (ref) => MangasNotifier()..refresh(20));

class MangasNotifier extends StateNotifier<List<Manga>> {
  MangasNotifier() : super([Manga()..title = "Loading mangas ..."]);

  void refresh(int maxPage) async {
    load();
    for (var i = 1; i <= maxPage; i++) {
      await update(i);
      load();
    }
  }

  Future<void> update(int page) async {
    final isar = await openIsar();
    var response = await Dio().get(
        'https://manganelo.com/advanced_search?s=all&orby=topview&page=$page');
    final str = response.data.toString();
    final splits = str.split('<div class="content-genres-item"');

    splits.forEach((s) async {
      var match =
          RegExp(r'class="genres-item-name .+?" href="(.+?)" title="(.+?)"')
              .firstMatch(s);

      if (match != null) {
        final manga = Manga()
          ..url = match[1]!
          ..title = match[2]!
          ..coverImageUrl = RegExp(r'<img class="img-loading" src="(.+?jpg)"')
              .firstMatch(s)![1]!
          ..lastChapterUrl =
              RegExp(r'class="genres-item-chap .+?" href="(.+?)"')
                  .firstMatch(s)![1]!;

        final rStr = RegExp(r'<em class="genres-item-rate">(.+?)</em>')
            .firstMatch(s)![1]!;
        final r = double.parse(rStr);
        if (r > 0 && r <= 5.0) {
          manga.rate = r;
        }

        final updatedAtStr =
            RegExp(r'class="genres-item-time">(.+?)<').firstMatch(s)![1]!;
        manga.updatedAt = DateFormat('MMM d,yy', 'en_US').parse(updatedAtStr);

        final myManga = state.firstWhere((x) => x.url == manga.url, orElse: () {
          return manga;
        });

        if (myManga != manga) {
          if (myManga.lastChapterUrl != manga.lastChapterUrl) {
            isar.writeTxn((isar) async {
              myManga.lastChapterUrl = manga.lastChapterUrl;
              myManga.updatedAt = manga.updatedAt;
              await isar.mangas.put(myManga);
            });
          }
        } else {
          isar.writeTxn((isar) async {
            await isar.mangas.put(manga);
          });
        }
      }
    });
  }

  Future<void> load() async {
    final isar = await openIsar();
    final mangas = await isar.mangas.where().findAll();
    mangas.sort((a, b) => -a.updatedAt.compareTo(b.updatedAt));
    state = mangas;
  }
}
