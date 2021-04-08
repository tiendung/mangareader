import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manga_data.dart';
import 'isar.g.dart';
import 'package:dio/dio.dart';

final mangasProvider = StateNotifierProvider<MangasNotifier, List<Manga>>(
    (ref) => MangasNotifier()..load());

class MangasNotifier extends StateNotifier<List<Manga>> {
  MangasNotifier() : super([Manga()..title = "Loading mangas ..."]);

  Future<void> update(int page) async {
    final isar = await openIsar();
    var response =
        await Dio().get('https://manganelo.com/genre-all/$page?type=topview');
    final str = response.data.toString();
    final splits = str.split('<div class="content-genres-item"');
    splits.forEach((s) async {
      var match =
          RegExp(r'class="genres-item-name .+?" href="(.+?)" title="(.+?)"')
              .firstMatch(s);
      if (match != null) {
        final manga = Manga()
          ..url = match[1]!
          ..title = match[2]!;
        manga.coverImageUrl = RegExp(r'<img class="img-loading" src="(.+?jpg)"')
            .firstMatch(s)![1]!;
        final r = RegExp(r'<em class="genres-item-rate">(.+?)</em>')
            .firstMatch(s)![1]!;
        manga.rate = double.parse(r);
        final lastChapterUrl =
            RegExp(r'class="genres-item-chap .+?" href="(.+?)"')
                .firstMatch(s)![1]!;
        manga.chapterUrls.add(lastChapterUrl);

        final myManga = state.firstWhere((x) => x.url == manga.url, orElse: () {
          return manga;
        });
        if (myManga != manga) {
          if (myManga.lastChapterUrl() != manga.lastChapterUrl()) {
            isar.writeTxn((isar) async {
              myManga.chapterUrls.insert(0, manga.lastChapterUrl());
              isar.mangas.put(myManga);
            });
          }
        } else {
          isar.writeTxn((isar) async {
            isar.mangas.put(manga);
          });
        }
      }
    });
  }

  Future<void> load() async {
    final isar = await openIsar();
    final mangas = await isar.mangas.where().findAll();
    mangas.sort((a, b) => -a.rate.compareTo(b.rate));
    state = mangas;
  }

  Future<void> add() async {
    final mangaUrls = [
      'https://manganelo.com/manga/gc923951',
      'https://manganelo.com/manga/go922760',
      'https://manganelo.com/manga/pn918005',
      'https://manganelo.com/manga/ijhr296321559609648',
      'https://manganelo.com/manga/zu917722',
      'https://manganelo.com/manga/lg924896',
      'https://manganelo.com/manga/pe922986',
      'https://manganelo.com/manga/vf922819',
    ];
    if (state.length > mangaUrls.length) {
      final isar = await openIsar();
      await isar.writeTxn((isar) async {
        await isar.mangas.where().deleteAll();
      });
      state = [];
      return;
    }
    final manga = Manga();
    manga.url = mangaUrls[state.length % mangaUrls.length];
    await manga.crawl();
    final isar = await openIsar();
    await isar.writeTxn((isar) async {
      manga.updatedAt = DateTime.now();
      await isar.mangas.put(manga);
    });
    state = [...state, manga];
  }
}
