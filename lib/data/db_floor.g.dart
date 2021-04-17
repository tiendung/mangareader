// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_floor.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorDb {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$DbBuilder databaseBuilder(String name) => _$DbBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$DbBuilder inMemoryDatabaseBuilder() => _$DbBuilder(null);
}

class _$DbBuilder {
  _$DbBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$DbBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$DbBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<Db> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$Db();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$Db extends Db {
  _$Db([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MangaDao? _mangaDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 3,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Manga` (`url` TEXT NOT NULL, `title` TEXT NOT NULL, `coverImageUrl` TEXT NOT NULL, `rate` REAL NOT NULL, `viewsCount` INTEGER NOT NULL, `lastChapterUrl` TEXT NOT NULL, `currentChapterUrl` TEXT NOT NULL, `currentScrollY` INTEGER NOT NULL, `readCount` INTEGER NOT NULL, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, `readAt` INTEGER NOT NULL, PRIMARY KEY (`url`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MangaDao get mangaDao {
    return _mangaDaoInstance ??= _$MangaDao(database, changeListener);
  }
}

class _$MangaDao extends MangaDao {
  _$MangaDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _mangaInsertionAdapter = InsertionAdapter(
            database,
            'Manga',
            (Manga item) => <String, Object?>{
                  'url': item.url,
                  'title': item.title,
                  'coverImageUrl': item.coverImageUrl,
                  'rate': item.rate,
                  'viewsCount': item.viewsCount,
                  'lastChapterUrl': item.lastChapterUrl,
                  'currentChapterUrl': item.currentChapterUrl,
                  'currentScrollY': item.currentScrollY,
                  'readCount': item.readCount,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt),
                  'readAt': _dateTimeConverter.encode(item.readAt)
                }),
        _mangaUpdateAdapter = UpdateAdapter(
            database,
            'Manga',
            ['url'],
            (Manga item) => <String, Object?>{
                  'url': item.url,
                  'title': item.title,
                  'coverImageUrl': item.coverImageUrl,
                  'rate': item.rate,
                  'viewsCount': item.viewsCount,
                  'lastChapterUrl': item.lastChapterUrl,
                  'currentChapterUrl': item.currentChapterUrl,
                  'currentScrollY': item.currentScrollY,
                  'readCount': item.readCount,
                  'createdAt': _dateTimeConverter.encode(item.createdAt),
                  'updatedAt': _dateTimeConverter.encode(item.updatedAt),
                  'readAt': _dateTimeConverter.encode(item.readAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Manga> _mangaInsertionAdapter;

  final UpdateAdapter<Manga> _mangaUpdateAdapter;

  @override
  Future<List<Manga>> loadAll() async {
    return _queryAdapter.queryList('SELECT * FROM Manga',
        mapper: (Map<String, Object?> row) => Manga(
            row['url'] as String,
            row['title'] as String,
            row['coverImageUrl'] as String,
            row['rate'] as double,
            row['viewsCount'] as int,
            row['lastChapterUrl'] as String,
            row['currentChapterUrl'] as String,
            row['currentScrollY'] as int,
            row['readCount'] as int,
            _dateTimeConverter.decode(row['createdAt'] as int),
            _dateTimeConverter.decode(row['updatedAt'] as int),
            _dateTimeConverter.decode(row['readAt'] as int)));
  }

  @override
  Future<Manga?> findByUrl(String url) async {
    return _queryAdapter.query('SELECT * FROM Manga WHERE url = ?1',
        mapper: (Map<String, Object?> row) => Manga(
            row['url'] as String,
            row['title'] as String,
            row['coverImageUrl'] as String,
            row['rate'] as double,
            row['viewsCount'] as int,
            row['lastChapterUrl'] as String,
            row['currentChapterUrl'] as String,
            row['currentScrollY'] as int,
            row['readCount'] as int,
            _dateTimeConverter.decode(row['createdAt'] as int),
            _dateTimeConverter.decode(row['updatedAt'] as int),
            _dateTimeConverter.decode(row['readAt'] as int)),
        arguments: [url]);
  }

  @override
  Future<List<int>> saveAll(List<Manga> mangas) {
    return _mangaInsertionAdapter.insertListAndReturnIds(
        mangas, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateAll(List<Manga> mangas) {
    return _mangaUpdateAdapter.updateListAndReturnChangedRows(
        mangas, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
