import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'manga_data.dart';
import 'helpers.dart';
import 'isar.g.dart';

final mangasProvider = StateNotifierProvider<MangasNotifier, List<Manga>>(
    (ref) => MangasNotifier()..update());

class MangasNotifier extends StateNotifier<List<Manga>> {
  MangasNotifier() : super([]);

  void update() async {
    await load();
    for (var i = 1; i <= MAX_PAGE; i++) {
      await crawl('https://manganelo.com/genre-all/$i');
      await crawl('https://manganelo.com/genre-all/$i?type=topview');
    }
    await load();
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

      final url = urlAndTitleMatch[1]!.trim().toLowerCase();
      var isNewManga = false;
      final manga = state.firstWhere((x) => x.url == url, orElse: () {
        isNewManga = true;
        return Manga();
      });

      final viewsMatch =
          RegExp(r'class="genres-item-view">(.+?)<').firstMatch(s);
      final viewsCount = int.parse(viewsMatch![1]!.replaceAll(",", ""));
      if (isNewManga && viewsCount < MIN_VIEWS) return;

      final rateMatch =
          RegExp(r'<em class="genres-item-rate">(.+?)</em>').firstMatch(s);
      final rate = rateMatch != null ? double.parse(rateMatch[1]!) : 4.6;
      if (isNewManga && rate < MIN_RATE) return;

      final updatedAtStr =
          RegExp(r'class="genres-item-time">(.+?)<').firstMatch(s)![1]!;
      final updatedAt = DateFormat('MMM d,yy', 'en_US').parse(updatedAtStr);
      if (isNewManga && now.difference(updatedAt).inDays > MAX_UPDATED_DAYS)
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
        ..rate = rate <= 5.0 ? rate : 4.6;

      mangas.add(manga);
      // print('\n- - - - - - - - - -\n$url, $isNewManga, ${manga.toStr()}\n\n');
    });

    isar.writeTxn((isar) async {
      await isar.mangas.putAll(mangas);
      state.addAll(mangas);
      state.sort((a, b) => -a.updatedAt.compareTo(b.updatedAt));
    });
  }

  Future<void> load() async {
    final isar = await openIsar();
    // await isar.writeTxn((isar) async => await isar.mangas.where().deleteAll());
    final mangas = await isar.mangas.where().findAll();
    mangas.sort((a, b) => -a.updatedAt.compareTo(b.updatedAt));
    state = mangas;
  }
}
