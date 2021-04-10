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
import 'manga_isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';

export 'package:isar/isar.dart';

final _isar = <String, Isar>{};
const _utf8Encoder = Utf8Encoder();

final _schema =
    '[{"name":"Manga","idProperty":"id","properties":[{"name":"id","type":3},{"name":"title","type":5},{"name":"coverImageUrl","type":5},{"name":"url","type":5},{"name":"rate","type":4},{"name":"viewsCount","type":3},{"name":"lastChapterUrl","type":5},{"name":"currentChapterUrl","type":5},{"name":"readCount","type":3},{"name":"createdAt","type":3},{"name":"updatedAt","type":3}],"indexes":[{"unique":false,"replace":false,"properties":[{"name":"title","indexType":2,"caseSensitive":true}]}],"links":[]}]';

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
    final propertyOffsetsPtr = malloc<Uint32>(11);
    IC.isar_get_property_offsets(collectionPtrPtr.value, propertyOffsetsPtr);
    final propertyOffsets = propertyOffsetsPtr.asTypedList(11).toList();
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

extension GetMangaCollection on Isar {
  IsarCollection<Manga> get mangas {
    return _mangaCollection[name]!;
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
    final value2 = object.coverImageUrl;
    final _coverImageUrl = _utf8Encoder.convert(value2);
    dynamicSize += _coverImageUrl.length;
    final value3 = object.url;
    final _url = _utf8Encoder.convert(value3);
    dynamicSize += _url.length;
    final value4 = object.rate;
    final _rate = value4;
    final value5 = object.viewsCount;
    final _viewsCount = value5;
    final value6 = object.lastChapterUrl;
    final _lastChapterUrl = _utf8Encoder.convert(value6);
    dynamicSize += _lastChapterUrl.length;
    final value7 = object.currentChapterUrl;
    final _currentChapterUrl = _utf8Encoder.convert(value7);
    dynamicSize += _currentChapterUrl.length;
    final value8 = object.readCount;
    final _readCount = value8;
    final value9 = object.createdAt;
    final _createdAt = value9;
    final value10 = object.updatedAt;
    final _updatedAt = value10;
    final size = dynamicSize + 90;

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
    final writer = BinaryWriter(buffer, 90);
    writer.writeLong(offsets[0], _id);
    writer.writeBytes(offsets[1], _title);
    writer.writeBytes(offsets[2], _coverImageUrl);
    writer.writeBytes(offsets[3], _url);
    writer.writeDouble(offsets[4], _rate);
    writer.writeLong(offsets[5], _viewsCount);
    writer.writeBytes(offsets[6], _lastChapterUrl);
    writer.writeBytes(offsets[7], _currentChapterUrl);
    writer.writeLong(offsets[8], _readCount);
    writer.writeDateTime(offsets[9], _createdAt);
    writer.writeDateTime(offsets[10], _updatedAt);
    return bufferSize;
  }

  @override
  Manga deserialize(IsarCollectionImpl<Manga> collection, BinaryReader reader,
      List<int> offsets) {
    final object = Manga();
    object.id = reader.readLongOrNull(offsets[0]);
    object.title = reader.readString(offsets[1]);
    object.coverImageUrl = reader.readString(offsets[2]);
    object.url = reader.readString(offsets[3]);
    object.rate = reader.readDouble(offsets[4]);
    object.viewsCount = reader.readLong(offsets[5]);
    object.lastChapterUrl = reader.readString(offsets[6]);
    object.currentChapterUrl = reader.readString(offsets[7]);
    object.readCount = reader.readLong(offsets[8]);
    object.createdAt = reader.readDateTime(offsets[9]);
    object.updatedAt = reader.readDateTime(offsets[10]);
    return object;
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

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlEqualTo(String value,
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

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlIn(
      List<String> values,
      {bool caseSensitive = true}) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.coverImageUrlEqualTo(values[i],
              caseSensitive: caseSensitive);
        } else {
          q = q
              .coverImageUrlEqualTo(values[i], caseSensitive: caseSensitive)
              .or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlStartsWith(
      String value,
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

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlEndsWith(String value,
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

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlContains(String value,
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

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Matches,
      2,
      'String',
      lower: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      3,
      'String',
      lower: value,
      upper: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlIn(List<String> values,
      {bool caseSensitive = true}) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.urlEqualTo(values[i], caseSensitive: caseSensitive);
        } else {
          q = q.urlEqualTo(values[i], caseSensitive: caseSensitive).or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.StartsWith,
      3,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.EndsWith,
      3,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.Contains,
      3,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Matches,
      3,
      'String',
      lower: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> rateGreaterThan(double value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Gt,
      4,
      'Double',
      lower: value,
      includeLower: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> rateLessThan(double value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Lt,
      4,
      'Double',
      upper: value,
      includeUpper: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> rateBetween(
      double lower, double upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Between,
      4,
      'Double',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> viewsCountEqualTo(int value) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      5,
      'Long',
      lower: value,
      upper: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> viewsCountIn(List<int> values) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.viewsCountEqualTo(values[i]);
        } else {
          q = q.viewsCountEqualTo(values[i]).or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> viewsCountGreaterThan(int value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Gt,
      5,
      'Long',
      lower: value,
      includeLower: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> viewsCountLessThan(int value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Lt,
      5,
      'Long',
      upper: value,
      includeUpper: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> viewsCountBetween(
      int lower, int upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Between,
      5,
      'Long',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      6,
      'String',
      lower: value,
      upper: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlIn(
      List<String> values,
      {bool caseSensitive = true}) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.lastChapterUrlEqualTo(values[i],
              caseSensitive: caseSensitive);
        } else {
          q = q
              .lastChapterUrlEqualTo(values[i], caseSensitive: caseSensitive)
              .or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlStartsWith(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.StartsWith,
      6,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlEndsWith(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.EndsWith,
      6,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlContains(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.Contains,
      6,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Matches,
      6,
      'String',
      lower: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlEqualTo(
      String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      7,
      'String',
      lower: value,
      upper: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlIn(
      List<String> values,
      {bool caseSensitive = true}) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.currentChapterUrlEqualTo(values[i],
              caseSensitive: caseSensitive);
        } else {
          q = q
              .currentChapterUrlEqualTo(values[i], caseSensitive: caseSensitive)
              .or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlStartsWith(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.StartsWith,
      7,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlEndsWith(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.EndsWith,
      7,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlContains(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(QueryCondition(
      ConditionType.Contains,
      7,
      'String',
      lower: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Matches,
      7,
      'String',
      lower: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> readCountEqualTo(int value) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      8,
      'Long',
      lower: value,
      upper: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> readCountIn(List<int> values) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.readCountEqualTo(values[i]);
        } else {
          q = q.readCountEqualTo(values[i]).or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> readCountGreaterThan(int value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Gt,
      8,
      'Long',
      lower: value,
      includeLower: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> readCountLessThan(int value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Lt,
      8,
      'Long',
      upper: value,
      includeUpper: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> readCountBetween(
      int lower, int upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Between,
      8,
      'Long',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      9,
      'DateTime',
      lower: value,
      upper: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> createdAtIn(
      List<DateTime> values) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.createdAtEqualTo(values[i]);
        } else {
          q = q.createdAtEqualTo(values[i]).or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> createdAtGreaterThan(
      DateTime value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Gt,
      9,
      'DateTime',
      lower: value,
      includeLower: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> createdAtLessThan(DateTime value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Lt,
      9,
      'DateTime',
      upper: value,
      includeUpper: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> createdAtBetween(
      DateTime lower, DateTime upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Between,
      9,
      'DateTime',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return addFilterCondition(QueryCondition(
      ConditionType.Eq,
      10,
      'DateTime',
      lower: value,
      upper: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> updatedAtIn(
      List<DateTime> values) {
    return group((q) {
      for (var i = 0; i < values.length; i++) {
        if (i == values.length - 1) {
          return q.updatedAtEqualTo(values[i]);
        } else {
          q = q.updatedAtEqualTo(values[i]).or();
        }
      }
      throw 'Empty values is unsupported.';
    });
  }

  QueryBuilder<Manga, QAfterFilterCondition> updatedAtGreaterThan(
      DateTime value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Gt,
      10,
      'DateTime',
      lower: value,
      includeLower: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> updatedAtLessThan(DateTime value,
      {bool include = false}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Lt,
      10,
      'DateTime',
      upper: value,
      includeUpper: include,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> updatedAtBetween(
      DateTime lower, DateTime upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addFilterCondition(QueryCondition(
      ConditionType.Between,
      10,
      'DateTime',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }
}

extension MangaQueryLinks on QueryBuilder<Manga, QFilterCondition> {}

extension MangaQueryWhereSortBy on QueryBuilder<Manga, QSortBy> {}

extension MangaQueryWhereSortThenBy on QueryBuilder<Manga, QSortThenBy> {}

extension MangaQueryWhereDistinct on QueryBuilder<Manga, QDistinct> {
  QueryBuilder<Manga, QDistinct> distinctById() {
    return addDistinctByInternal(0);
  }

  QueryBuilder<Manga, QDistinct> distinctByTitle() {
    return addDistinctByInternal(1);
  }

  QueryBuilder<Manga, QDistinct> distinctByCoverImageUrl() {
    return addDistinctByInternal(2);
  }

  QueryBuilder<Manga, QDistinct> distinctByUrl() {
    return addDistinctByInternal(3);
  }

  QueryBuilder<Manga, QDistinct> distinctByRate() {
    return addDistinctByInternal(4);
  }

  QueryBuilder<Manga, QDistinct> distinctByViewsCount() {
    return addDistinctByInternal(5);
  }

  QueryBuilder<Manga, QDistinct> distinctByLastChapterUrl() {
    return addDistinctByInternal(6);
  }

  QueryBuilder<Manga, QDistinct> distinctByCurrentChapterUrl() {
    return addDistinctByInternal(7);
  }

  QueryBuilder<Manga, QDistinct> distinctByReadCount() {
    return addDistinctByInternal(8);
  }

  QueryBuilder<Manga, QDistinct> distinctByCreatedAt() {
    return addDistinctByInternal(9);
  }

  QueryBuilder<Manga, QDistinct> distinctByUpdatedAt() {
    return addDistinctByInternal(10);
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
      case 'Manga':
        return _mangaCollection[instanceName]!;
      default:
        throw 'Unknown collection';
    }
  }

  @override
  Map<String, dynamic> objectToJson(dynamic object) {
    if (object is Manga) {
      return {
        'id': object.id,
        'title': object.title,
        'coverImageUrl': object.coverImageUrl,
        'url': object.url,
        'rate': object.rate,
        'viewsCount': object.viewsCount,
        'lastChapterUrl': object.lastChapterUrl,
        'currentChapterUrl': object.currentChapterUrl,
        'readCount': object.readCount,
        'createdAt': object.createdAt,
        'updatedAt': object.updatedAt,
      };
    }
    throw 'Unknown object type';
  }
}
