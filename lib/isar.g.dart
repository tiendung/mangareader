// ignore_for_file: unused_import, implementation_imports

import 'dart:ffi';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:isar/src/isar_native.dart';
import 'package:isar/src/isar_interface.dart';
import 'package:isar/src/query_builder.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'chapter_data.dart';
import 'manga_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';

export 'package:isar/isar.dart';

final _isar = <String, Isar>{};
const _utf8Encoder = Utf8Encoder();

final _schema =
    '[{"name":"Chapter","idProperty":"id","properties":[{"name":"id","type":3},{"name":"title","type":5},{"name":"visited","type":0},{"name":"viewingImageIndex","type":3},{"name":"imageUrls","type":11}],"indexes":[],"links":[{"name":"manga","collection":"Manga"}]},{"name":"Manga","idProperty":"id","properties":[{"name":"id","type":3},{"name":"title","type":5},{"name":"description","type":5}],"indexes":[{"unique":false,"replace":false,"properties":[{"name":"title","indexType":2,"caseSensitive":true}]}],"links":[]}]';

final _chapterCollection = <String, IsarCollection<Chapter>>{};
final _mangaCollection = <String, IsarCollection<Manga>>{};

Future<Isar> openIsar(
    {String name = 'isar',
    String? directory,
    int maxSize = 1000000000,
    Uint8List? encryptionKey}) async {
  assert(name.isNotEmpty);
  final path = await _preparePath(directory);
  if (_isar[name] != null) {
    return _isar[name]!;
  }
  await Directory(p.join(path, name)).create(recursive: true);
  initializeIsarCore();
  IC.isar_connect_dart_api(NativeApi.postCObject);

  final isarPtrPtr = malloc<Pointer>();
  final namePtr = name.toNativeUtf8();
  final pathPtr = path.toNativeUtf8();
  IC.isar_get_instance(isarPtrPtr, namePtr.cast());
  if (isarPtrPtr.value.address == 0) {
    final schemaPtr = _schema.toNativeUtf8();
    var encKeyPtr = Pointer<Uint8>.fromAddress(0);
    if (encryptionKey != null) {
      assert(encryptionKey.length == 32,
          'Encryption keys need to contain 32 byte (256bit).');
      encKeyPtr = malloc(32);
      encKeyPtr.asTypedList(32).setAll(0, encryptionKey);
    }
    final receivePort = ReceivePort();
    final nativePort = receivePort.sendPort.nativePort;
    final stream = wrapIsarPort(receivePort);
    IC.isar_create_instance(isarPtrPtr, namePtr.cast(), pathPtr.cast(), maxSize,
        schemaPtr.cast(), encKeyPtr, nativePort);
    await stream.first;
    malloc.free(schemaPtr);
    if (encryptionKey != null) {
      malloc.free(encKeyPtr);
    }
  }
  malloc.free(namePtr);
  malloc.free(pathPtr);

  final isarPtr = isarPtrPtr.value;
  malloc.free(isarPtrPtr);

  final isar = IsarImpl(name, isarPtr);
  _isar[name] = isar;

  final collectionPtrPtr = malloc<Pointer>();
  {
    nCall(IC.isar_get_collection(isarPtr, collectionPtrPtr, 0));
    final propertyOffsetsPtr = malloc<Uint32>(5);
    IC.isar_get_property_offsets(collectionPtrPtr.value, propertyOffsetsPtr);
    final propertyOffsets = propertyOffsetsPtr.asTypedList(5).toList();
    malloc.free(propertyOffsetsPtr);
    _chapterCollection[name] = IsarCollectionImpl(
      isar,
      _ChapterAdapter(),
      collectionPtrPtr.value,
      propertyOffsets,
      (obj) => obj.id,
      (obj, id) => obj.id = id,
    );
  }
  {
    nCall(IC.isar_get_collection(isarPtr, collectionPtrPtr, 1));
    final propertyOffsetsPtr = malloc<Uint32>(3);
    IC.isar_get_property_offsets(collectionPtrPtr.value, propertyOffsetsPtr);
    final propertyOffsets = propertyOffsetsPtr.asTypedList(3).toList();
    malloc.free(propertyOffsetsPtr);
    _mangaCollection[name] = IsarCollectionImpl(
      isar,
      _MangaAdapter(),
      collectionPtrPtr.value,
      propertyOffsets,
      (obj) => obj.id,
      (obj, id) => obj.id = id,
    );
  }
  malloc.free(collectionPtrPtr);

  IsarInterface.initialize(_GeneratedIsarInterface());
  Isar.addCloseListener(_onClose);

  return isar;
}

void _onClose(String name) {
  _isar.remove(name);
}

Future<String> _preparePath(String? path) async {
  if (path == null || p.isRelative(path)) {
    WidgetsFlutterBinding.ensureInitialized();
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, path ?? 'isar');
  } else {
    return path;
  }
}

extension GetChapterCollection on Isar {
  IsarCollection<Chapter> get chapters {
    return _chapterCollection[name]!;
  }
}

extension GetMangaCollection on Isar {
  IsarCollection<Manga> get mangas {
    return _mangaCollection[name]!;
  }
}

class _ChapterAdapter extends TypeAdapter<Chapter> {
  @override
  int serialize(IsarCollectionImpl<Chapter> collection, RawObject rawObj,
      Chapter object, List<int> offsets,
      [int? existingBufferSize]) {
    var dynamicSize = 0;
    final value0 = object.id;
    final _id = value0;
    final value1 = object.title;
    final _title = _utf8Encoder.convert(value1);
    dynamicSize += _title.length;
    final value2 = object.visited;
    final _visited = value2;
    final value3 = object.viewingImageIndex;
    final _viewingImageIndex = value3;
    final value4 = object.imageUrls;
    dynamicSize += (value4.length) * 8;
    List<Uint8List?>? bytesList4;
    for (var str in value4) {
      final bytes = _utf8Encoder.convert(str);
      bytesList4?.add(bytes);
      dynamicSize += bytes.length;
    }
    final _imageUrls = bytesList4;
    final size = dynamicSize + 35;

    late int bufferSize;
    if (existingBufferSize != null) {
      if (existingBufferSize < size) {
        malloc.free(rawObj.buffer);
        rawObj.buffer = malloc(size);
        bufferSize = size;
      } else {
        bufferSize = existingBufferSize;
      }
    } else {
      rawObj.buffer = malloc(size);
      bufferSize = size;
    }
    rawObj.buffer_length = size;
    final buffer = rawObj.buffer.asTypedList(size);
    final writer = BinaryWriter(buffer, 35);
    writer.writeLong(offsets[0], _id);
    writer.writeBytes(offsets[1], _title);
    writer.writeBool(offsets[2], _visited);
    writer.writeLong(offsets[3], _viewingImageIndex);
    writer.writeStringList(offsets[4], _imageUrls);
    if (!(object.manga as IsarLinkImpl).attached) {
      (object.manga as IsarLinkImpl).attach(
        collection,
        collection.isar.mangas as IsarCollectionImpl<Manga>,
        object,
        0,
        false,
      );
    }
    return bufferSize;
  }

  @override
  Chapter deserialize(IsarCollectionImpl<Chapter> collection,
      BinaryReader reader, List<int> offsets) {
    final object = Chapter();
    object.id = reader.readLongOrNull(offsets[0]);
    object.title = reader.readString(offsets[1]);
    object.visited = reader.readBool(offsets[2]);
    object.viewingImageIndex = reader.readLong(offsets[3]);
    object.imageUrls = reader.readStringList(offsets[4]) ?? [];
    object.manga = IsarLinkImpl()
      ..attach(
        collection,
        collection.isar.mangas as IsarCollectionImpl<Manga>,
        object,
        0,
        false,
      );

    return object;
  }
}

class _MangaAdapter extends TypeAdapter<Manga> {
  @override
  int serialize(IsarCollectionImpl<Manga> collection, RawObject rawObj,
      Manga object, List<int> offsets,
      [int? existingBufferSize]) {
    var dynamicSize = 0;
    final value0 = object.id;
    final _id = value0;
    final value1 = object.title;
    final _title = _utf8Encoder.convert(value1);
    dynamicSize += _title.length;
    final value2 = object.description;
    final _description = _utf8Encoder.convert(value2);
    dynamicSize += _description.length;
    final size = dynamicSize + 26;

    late int bufferSize;
    if (existingBufferSize != null) {
      if (existingBufferSize < size) {
        malloc.free(rawObj.buffer);
        rawObj.buffer = malloc(size);
        bufferSize = size;
      } else {
        bufferSize = existingBufferSize;
      }
    } else {
      rawObj.buffer = malloc(size);
      bufferSize = size;
    }
    rawObj.buffer_length = size;
    final buffer = rawObj.buffer.asTypedList(size);
    final writer = BinaryWriter(buffer, 26);
    writer.writeLong(offsets[0], _id);
    writer.writeBytes(offsets[1], _title);
    writer.writeBytes(offsets[2], _description);
    if (!(object.chapters as IsarLinksImpl).attached) {
      (object.chapters as IsarLinksImpl).attach(
        collection,
        collection.isar.chapters as IsarCollectionImpl<Chapter>,
        object,
        0,
        true,
      );
    }
    return bufferSize;
  }

  @override
  Manga deserialize(IsarCollectionImpl<Manga> collection, BinaryReader reader,
      List<int> offsets) {
    final object = Manga();
    object.id = reader.readLongOrNull(offsets[0]);
    object.title = reader.readString(offsets[1]);
    object.description = reader.readString(offsets[2]);
    object.chapters = IsarLinksImpl()
      ..attach(
        collection,
        collection.isar.chapters as IsarCollectionImpl<Chapter>,
        object,
        0,
        true,
      );

    return object;
  }
}

extension ChapterQueryWhereSort on QueryBuilder<Chapter, QWhere> {
  QueryBuilder<Chapter, QAfterWhere> anyId() {
    return addWhereClause(WhereClause(-1, []));
  }
}

extension ChapterQueryWhere on QueryBuilder<Chapter, QWhereClause> {
  QueryBuilder<Chapter, QAfterWhereClause> idEqualTo(int? id) {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      upper: [id],
      includeUpper: true,
      lower: [id],
      includeLower: true,
    ));
  }

  QueryBuilder<Chapter, QAfterWhereClause> idNotEqualTo(int? id) {
    final cloned = addWhereClause(WhereClause(
      -1,
      ['Long'],
      upper: [id],
      includeUpper: false,
    ));
    return cloned.addWhereClause(WhereClause(
      -1,
      ['Long'],
      lower: [id],
      includeLower: false,
    ));
  }

  QueryBuilder<Chapter, QAfterWhereClause> idBetween(int? lower, int? upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      upper: [upper],
      includeUpper: includeUpper,
      lower: [lower],
      includeLower: includeLower,
    ));
  }

  QueryBuilder<Chapter, QAfterWhereClause> idIn(List<int?> values) {
    var q = this;
    for (var i = 0; i < values.length; i++) {
      if (i == values.length - 1) {
        return q.idEqualTo(values[i]);
      } else {
        q = q.idEqualTo(values[i]).or();
      }
    }
    throw 'Empty values is unsupported.';
  }

  QueryBuilder<Chapter, QAfterWhereClause> idGreaterThan(int? value,
      {bool include = false}) {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      lower: [value],
      includeLower: include,
    ));
  }

  QueryBuilder<Chapter, QAfterWhereClause> idLessThan(int? value,
      {bool include = false}) {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      upper: [value],
      includeUpper: include,
    ));
  }

  QueryBuilder<Chapter, QAfterWhereClause> idIsNull() {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      upper: [null],
      includeUpper: true,
      lower: [null],
      includeLower: true,
    ));
  }

  QueryBuilder<Chapter, QAfterWhereClause> idIsNotNull() {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      lower: [null],
      includeLower: false,
    ));
  }
}

extension MangaQueryWhereSort on QueryBuilder<Manga, QWhere> {
  QueryBuilder<Manga, QAfterWhere> anyId() {
    return addWhereClause(WhereClause(-1, []));
  }
}

extension MangaQueryWhere on QueryBuilder<Manga, QWhereClause> {
  QueryBuilder<Manga, QAfterWhereClause> idEqualTo(int? id) {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      upper: [id],
      includeUpper: true,
      lower: [id],
      includeLower: true,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> idNotEqualTo(int? id) {
    final cloned = addWhereClause(WhereClause(
      -1,
      ['Long'],
      upper: [id],
      includeUpper: false,
    ));
    return cloned.addWhereClause(WhereClause(
      -1,
      ['Long'],
      lower: [id],
      includeLower: false,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> idBetween(int? lower, int? upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      upper: [upper],
      includeUpper: includeUpper,
      lower: [lower],
      includeLower: includeLower,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> idIn(List<int?> values) {
    var q = this;
    for (var i = 0; i < values.length; i++) {
      if (i == values.length - 1) {
        return q.idEqualTo(values[i]);
      } else {
        q = q.idEqualTo(values[i]).or();
      }
    }
    throw 'Empty values is unsupported.';
  }

  QueryBuilder<Manga, QAfterWhereClause> idGreaterThan(int? value,
      {bool include = false}) {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      lower: [value],
      includeLower: include,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> idLessThan(int? value,
      {bool include = false}) {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      upper: [value],
      includeUpper: include,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> idIsNull() {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      upper: [null],
      includeUpper: true,
      lower: [null],
      includeLower: true,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> idIsNotNull() {
    return addWhereClause(WhereClause(
      -1,
      ['Long'],
      lower: [null],
      includeLower: false,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> titleWordEqualTo(String title) {
    return addWhereClause(WhereClause(
      0,
      ['StringWords'],
      upper: [title],
      includeUpper: true,
      lower: [title],
      includeLower: true,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> titleWordIn(List<String> values) {
    var q = this;
    for (var i = 0; i < values.length; i++) {
      if (i == values.length - 1) {
        return q.titleWordEqualTo(values[i]);
      } else {
        q = q.titleWordEqualTo(values[i]).or();
      }
    }
    throw 'Empty values is unsupported.';
  }

  QueryBuilder<Manga, QAfterWhereClause> titleWordStartsWith(String value) {
    final convertedValue = value;
    return addWhereClause(WhereClause(
      0,
      ['StringWords'],
      lower: [convertedValue],
      upper: ['$convertedValue\u{FFFFF}'],
      includeLower: true,
      includeUpper: true,
    ));
  }
}

extension ChapterQueryFilter on QueryBuilder<Chapter, QFilterCondition> {
  QueryBuilder<Chapter, QAfterFilterCondition> idIsNull() {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      0,
      'Long',
      lower: null,
      upper: null,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      0,
      'Long',
      lower: value,
      upper: value,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> idIn(List<int?> values) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.idEqualTo(values[i]);
        } else {
          q = q.idEqualTo(values[i]).or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Chapter, QAfterFilterCondition> idGreaterThan(int? value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Gt,
      0,
      'Long',
      lower: value,
      includeLower: include,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> idLessThan(int? value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Lt,
      0,
      'Long',
      upper: value,
      includeUpper: include,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> idBetween(int? lower, int? upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Between,
      0,
      'Long',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> titleEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      1,
      'String',
      lower: value,
      upper: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> titleIn(List<String> values,
      {bool caseSensitive = true}) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.titleEqualTo(values[i], caseSensitive: caseSensitive);
        } else {
          q = q.titleEqualTo(values[i], caseSensitive: caseSensitive).or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Chapter, QAfterFilterCondition> titleStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.StartsWith,
      1,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> titleEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.EndsWith,
      1,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.Contains,
      1,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Matches,
      1,
      'String',
      lower: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> visitedEqualTo(bool value) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      2,
      'Bool',
      lower: value,
      upper: value,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> viewingImageIndexEqualTo(
      int value) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      3,
      'Long',
      lower: value,
      upper: value,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> viewingImageIndexIn(
      List<int> values) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.viewingImageIndexEqualTo(values[i]);
        } else {
          q = q.viewingImageIndexEqualTo(values[i]).or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Chapter, QAfterFilterCondition> viewingImageIndexGreaterThan(
      int value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Gt,
      3,
      'Long',
      lower: value,
      includeLower: include,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> viewingImageIndexLessThan(
      int value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Lt,
      3,
      'Long',
      upper: value,
      includeUpper: include,
    ));
  }

  QueryBuilder<Chapter, QAfterFilterCondition> viewingImageIndexBetween(
      int lower, int upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Between,
      3,
      'Long',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }
}

extension MangaQueryFilter on QueryBuilder<Manga, QFilterCondition> {
  QueryBuilder<Manga, QAfterFilterCondition> idIsNull() {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      0,
      'Long',
      lower: null,
      upper: null,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      0,
      'Long',
      lower: value,
      upper: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> idIn(List<int?> values) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.idEqualTo(values[i]);
        } else {
          q = q.idEqualTo(values[i]).or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> idGreaterThan(int? value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Gt,
      0,
      'Long',
      lower: value,
      includeLower: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> idLessThan(int? value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Lt,
      0,
      'Long',
      upper: value,
      includeUpper: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> idBetween(int? lower, int? upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Between,
      0,
      'Long',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      1,
      'String',
      lower: value,
      upper: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleIn(List<String> values,
      {bool caseSensitive = true}) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.titleEqualTo(values[i], caseSensitive: caseSensitive);
        } else {
          q = q.titleEqualTo(values[i], caseSensitive: caseSensitive).or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.StartsWith,
      1,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.EndsWith,
      1,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.Contains,
      1,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Matches,
      1,
      'String',
      lower: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> descriptionEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      2,
      'String',
      lower: value,
      upper: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> descriptionIn(List<String> values,
      {bool caseSensitive = true}) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.descriptionEqualTo(values[i], caseSensitive: caseSensitive);
        } else {
          q = q
              .descriptionEqualTo(values[i], caseSensitive: caseSensitive)
              .or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> descriptionStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.StartsWith,
      2,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> descriptionEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.EndsWith,
      2,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> descriptionContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.Contains,
      2,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> descriptionMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Matches,
      2,
      'String',
      lower: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension ChapterQueryLinks on QueryBuilder<Chapter, QFilterCondition> {
  QueryBuilder<Chapter, QAfterFilterCondition> manga(FilterQuery<Manga> q) {
    return linkInternal(
      isar.mangas,
      q,
      0,
      false,
    );
  }
}

extension MangaQueryLinks on QueryBuilder<Manga, QFilterCondition> {
  QueryBuilder<Manga, QAfterFilterCondition> chapters(FilterQuery<Chapter> q) {
    return linkInternal(
      isar.chapters,
      q,
      0,
      true,
    );
  }
}

extension ChapterQueryWhereSortBy on QueryBuilder<Chapter, QSortBy> {}

extension ChapterQueryWhereSortThenBy on QueryBuilder<Chapter, QSortThenBy> {}

extension MangaQueryWhereSortBy on QueryBuilder<Manga, QSortBy> {}

extension MangaQueryWhereSortThenBy on QueryBuilder<Manga, QSortThenBy> {}

extension ChapterQueryWhereDistinct on QueryBuilder<Chapter, QDistinct> {
  QueryBuilder<Chapter, QDistinct> distinctById() {
    return addDistinctByInternal(0);
  }

  QueryBuilder<Chapter, QDistinct> distinctByTitle() {
    return addDistinctByInternal(1);
  }

  QueryBuilder<Chapter, QDistinct> distinctByVisited() {
    return addDistinctByInternal(2);
  }

  QueryBuilder<Chapter, QDistinct> distinctByViewingImageIndex() {
    return addDistinctByInternal(3);
  }

  QueryBuilder<Chapter, QDistinct> distinctByImageUrls() {
    return addDistinctByInternal(4);
  }
}

extension MangaQueryWhereDistinct on QueryBuilder<Manga, QDistinct> {
  QueryBuilder<Manga, QDistinct> distinctById() {
    return addDistinctByInternal(0);
  }

  QueryBuilder<Manga, QDistinct> distinctByTitle() {
    return addDistinctByInternal(1);
  }

  QueryBuilder<Manga, QDistinct> distinctByDescription() {
    return addDistinctByInternal(2);
  }
}

class _GeneratedIsarInterface implements IsarInterface {
  @override
  String get schemaJson => _schema;

  @override
  List<String> get instanceNames => _isar.keys.toList();

  @override
  IsarCollection getCollection(String instanceName, String collectionName) {
    final instance = _isar[instanceName];
    if (instance == null) throw 'Isar instance $instanceName is not open';
    switch (collectionName) {
      case 'Chapter':
        return _chapterCollection[instanceName]!;
      case 'Manga':
        return _mangaCollection[instanceName]!;
      default:
        throw 'Unknown collection';
    }
  }

  @override
  Map<String, dynamic> objectToJson(dynamic object) {
    if (object is Chapter) {
      return {
        'id': object.id,
        'title': object.title,
        'visited': object.visited,
        'viewingImageIndex': object.viewingImageIndex,
        'imageUrls': object.imageUrls,
      };
    }
    if (object is Manga) {
      return {
        'id': object.id,
        'title': object.title,
        'description': object.description,
      };
    }
    throw 'Unknown object type';
  }
}
