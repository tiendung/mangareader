import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manga_data.dart';
import 'isar.g.dart';

// https://github.com/rrousselGit/river_pod/blob/master/examples/todos/lib/main.dart
final mangasProvider = StateNotifierProvider<MangasNotifier, List<Manga>>(
    (ref) => MangasNotifier()..refresh());

final mangaUrls = [
  'https://manganelo.com/manga/go922760',
  'https://manganelo.com/manga/pn918005',
  'https://manganelo.com/manga/ijhr296321559609648',
  'https://manganelo.com/manga/zu917722',
  'https://manganelo.com/manga/lg924896',
];

// https://github.com/rrousselGit/river_pod/blob/master/examples/todos/lib/todo.dart
class MangasNotifier extends StateNotifier<List<Manga>> {
  MangasNotifier() : super([Manga()..title = "Loading mangas ..."]);

  Future<void> add() async {
    if (state.length >= 6) {
      final isar = await openIsar();
      await isar.writeTxn((isar) async {
        await isar.chapters.where().deleteAll();
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
      await manga.chapters.saveChanges();
    });
    state = [...state, manga];
    manga.chapters.forEach((c) {
      c.crawl();
    });
    isar.writeTxn((isar) async {
      await manga.chapters.saveChanges();
    });
  }

  Future<void> refresh() async {
    final isar = await openIsar();
    final mangas = await isar.mangas.where().findAll();
    mangas.forEach((manga) async {
      await manga.chapters.load();
    });
    state = mangas;
  }
}
