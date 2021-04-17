import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'manga_floor.dart';

part 'db_floor.g.dart'; // the generated code will be there

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}

@TypeConverters([DateTimeConverter])
@Database(version: 3, entities: [Manga])
abstract class Db extends FloorDatabase {
  MangaDao get mangaDao;
}

Db? _db;
Future<Db> getDb() async {
  if (_db == null) {
    _db = await $FloorDb
        .databaseBuilder('app.db')
        .addMigrations([migration1to2, migration2to3]).build();
  }
  return _db!;
}

final migration1to2 = Migration(1, 2, (database) async {
  await database
      .execute('ALTER TABLE Manga ADD COLUMN `readAt` INTEGER');
});

final migration2to3 = Migration(2, 3, (database) async {
  await database.execute('ALTER TABLE Manga DROP COLUMN `readAt`');
  await database.execute(
      'ALTER TABLE Manga ADD COLUMN `readAt` INTEGER NOT NULL DEFAULT 0');
});
