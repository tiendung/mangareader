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

@Database(version: 1, entities: [Manga])
abstract class Db extends FloorDatabase {
  MangaDao get mangaDao;

  static get() async {
    return await $FloorDb.databaseBuilder('app.db').build();
  }
}

