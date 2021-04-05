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
    if (mangaUrls.length == 0) return;

    final manga = Manga();
    manga.url = mangaUrls.removeLast();
    await manga.crawl();
    final isar = await openIsar();
    await isar.writeTxn((isar) async {
      manga.updatedAt = DateTime.now();
      await isar.mangas.put(manga);
      await manga.chapters.saveChanges();
    });
  }

  Future<void> refresh() async {
    final isar = await openIsar();
    state = await isar.mangas.where().findAll();
  }
}
