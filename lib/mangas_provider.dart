import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manga_data.dart';
import 'dart:math';
import 'isar.g.dart';

// https://github.com/rrousselGit/river_pod/blob/master/examples/todos/lib/main.dart
final mangasProvider = StateNotifierProvider<MangasNotifier, List<Manga>>(
    (ref) => MangasNotifier()..refresh());

// https://github.com/rrousselGit/river_pod/blob/master/examples/todos/lib/todo.dart
class MangasNotifier extends StateNotifier<List<Manga>> {
  MangasNotifier() : super([Manga()..title = "Loading mangas ..."]);

  Future<void> add() async {
    final isar = await openIsar();
    final m = Manga()..title = "Amazing ${Random().nextInt(1000)}";
    await isar.writeTxn((isar) async {
      await isar.mangas.put(m);
    });
  }

  Future<void> refresh() async {
    final isar = await openIsar();
    state = await isar.mangas.where().findAll();
  }
}
