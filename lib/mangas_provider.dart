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
    await load();
    for (var i = 1; i <= 60; i++) {
      await crawl('https://manganelo.com/genre-all/$i');
      await load();
    }
  }

  Future<void> crawl(String url) async {
    final isar = await openIsar();
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

      final coverImageMatch =
          RegExp(r'<img class="img-loading" src="(.+?jpg)"').firstMatch(s);

      final url = urlAndTitleMatch[1]!;
      var isNewManga = false;
      final manga = state.firstWhere((x) => x.url == url, orElse: () {
        isNewManga = true;
        return Manga();
      });

      final viewsMatch =
          RegExp(r'class="genres-item-view">(.+?)<').firstMatch(s);
      final viewsCount = int.parse(viewsMatch![1]!.replaceAll(",", ""));
      if (isNewManga && viewsCount < 300000) return;

      // print('\n- - - - - - - - - - - - -\n$url, $isNewManga, ${manga.rate}, ${manga.updatedAt}, ${manga.viewsCount}\n\n');

      final rateMatch =
          RegExp(r'<em class="genres-item-rate">(.+?)</em>').firstMatch(s);
      final rate = rateMatch != null ? double.parse(rateMatch[1]!) : 4.5;
      if (isNewManga && rate < 4.5) return;

      final updatedAtStr =
          RegExp(r'class="genres-item-time">(.+?)<').firstMatch(s)![1]!;
      final updatedAt = DateFormat('MMM d,yy', 'en_US').parse(updatedAtStr);
      if (isNewManga && now.difference(updatedAt).inDays > 30) return;

      manga
        ..url = url
        ..title = urlAndTitleMatch[2]!
        ..lastChapterUrl = lastChapMatch[1]!
        ..coverImageUrl = coverImageMatch![1]!
        ..viewsCount = viewsCount
        ..rate = rate <= 5.0 ? rate : 4.5;
      mangas.add(manga);
    });

    isar.writeTxn((isar) async {
      await isar.mangas.putAll(mangas);
    });
  }

  Future<void> load() async {
    final isar = await openIsar();
    final mangas = await isar.mangas.where().findAll();
    mangas.sort((a, b) => -a.updatedAt.compareTo(b.updatedAt));
    state = mangas;
  }
}
