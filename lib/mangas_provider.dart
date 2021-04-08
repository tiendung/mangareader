import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'manga_data.dart';
import 'isar.g.dart';

final mangasProvider = StateNotifierProvider<MangasNotifier, List<Manga>>(
    (ref) => MangasNotifier()..update());

class MangasNotifier extends StateNotifier<List<Manga>> {
  MangasNotifier() : super([]);

  void update() async {
    load();
    for (var i = 1; i <= 60; i++) {
      crawl('https://manganelo.com/genre-all/$i');
      load();
    }
  }

  Future<void> crawl(String url) async {
    final isar = await openIsar();
    var response = await Dio().get(url);
    final str = response.data.toString();
    final splits = str.split('<div class="content-genres-item"');
    final now = DateTime.now();

    splits.forEach((s) async {
      var match =
          RegExp(r'class="genres-item-name .+?" href="(.+?)" title="(.+?)"')
              .firstMatch(s);

      if (match != null) {
        final manga = Manga()
          ..url = match[1]!
          ..title = match[2]!
          ..coverImageUrl = RegExp(r'<img class="img-loading" src="(.+?jpg)"')
              .firstMatch(s)![1]!;

        final lastChapMatch =
            RegExp(r'class="genres-item-chap .+?" href="(.+?)"').firstMatch(s);
        if (lastChapMatch == null) {
          return;
        }
        manga.lastChapterUrl = lastChapMatch[1]!;

        final rMatch =
            RegExp(r'<em class="genres-item-rate">(.+?)</em>').firstMatch(s);
        if (rMatch != null && rMatch[1] != null) {
          final r = double.parse(rMatch[1]!);
          if (r > 0 && r <= 5.0) {
            manga.rate = r;
          }
        }

        final viewsMatch =
            RegExp(r'class="genres-item-view">(.+?)<').firstMatch(s);
        if (viewsMatch != null && viewsMatch[1] != null) {
          manga.viewsCount = int.parse(viewsMatch[1]!.replaceAll(",", ""));
        }

        final updatedAtStr =
            RegExp(r'class="genres-item-time">(.+?)<').firstMatch(s)![1]!;
        manga.updatedAt = DateFormat('MMM d,yy', 'en_US').parse(updatedAtStr);
        // print('''\n------------------------------------------$manga''');
        if (manga.rate < 4.5 ||
            manga.viewsCount < 300000 ||
            now.difference(manga.updatedAt).inDays > 30) {
          return;
        }

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
