// ignore_for_file: unused_import, implementation_imports

import 'dart:ffi';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:isar/src/isar_native.dart';
import 'package:isar/src/query_builder.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'manga_isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';

const _utf8Encoder = Utf8Encoder();

final _schema =
    '[{"name":"Manga","idProperty":"id","properties":[{"name":"id","type":3},{"name":"title","type":5},{"name":"coverImageUrl","type":5},{"name":"url","type":5},{"name":"rate","type":4},{"name":"viewsCount","type":3},{"name":"lastChapterUrl","type":5},{"name":"currentChapterUrl","type":5},{"name":"readCount","type":3},{"name":"createdAt","type":3},{"name":"updatedAt","type":3},{"name":"order","type":4},{"name":"currentScrollY","type":3}],"indexes":[{"unique":false,"replace":false,"properties":[{"name":"title","indexType":2,"caseSensitive":true}]},{"unique":false,"replace":false,"properties":[{"name":"url","indexType":0,"caseSensitive":true}]},{"unique":false,"replace":false,"properties":[{"name":"order","indexType":0,"caseSensitive":null}]}],"links":[]}]';

Future<Isar> openIsar(
    {String name = 'isar',
    String? directory,
    int maxSize = 1000000000,
    Uint8List? encryptionKey}) async {
  final path = await _preparePath(directory);
  return openIsarInternal(
      name: name,
      directory: path,
      maxSize: maxSize,
      encryptionKey: encryptionKey,
      schema: _schema,
      getCollections: (isar) {
        final collectionPtrPtr = malloc<Pointer>();
        final propertyOffsetsPtr = malloc<Uint32>(13);
        final propertyOffsets = propertyOffsetsPtr.asTypedList(13);
        final collections = <String, IsarCollection>{};
        nCall(IC.isar_get_collection(isar.ptr, collectionPtrPtr, 0));
        IC.isar_get_property_offsets(
            collectionPtrPtr.value, propertyOffsetsPtr);
        collections['Manga'] = IsarCollectionImpl<Manga>(
          isar: isar,
          adapter: _MangaAdapter(),
          ptr: collectionPtrPtr.value,
          propertyOffsets: propertyOffsets.sublist(0, 13),
          propertyIds: {
            'id': 0,
            'title': 1,
            'coverImageUrl': 2,
            'url': 3,
            'rate': 4,
            'viewsCount': 5,
            'lastChapterUrl': 6,
            'currentChapterUrl': 7,
            'readCount': 8,
            'createdAt': 9,
            'updatedAt': 10,
            'order': 11,
            'currentScrollY': 12
          },
          indexIds: {'title': 0, 'url': 1, 'order': 2},
          linkIds: {},
          backlinkIds: {},
          getId: (obj) => obj.id,
          setId: (obj, id) => obj.id = id,
        );
        malloc.free(propertyOffsetsPtr);
        malloc.free(collectionPtrPtr);

        return collections;
      });
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
    final value11 = object.order;
    final _order = value11;
    final value12 = object.currentScrollY;
    final _currentScrollY = value12;
    final size = dynamicSize + 106;

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
    final writer = BinaryWriter(buffer, 106);
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
    writer.writeDouble(offsets[11], _order);
    writer.writeLong(offsets[12], _currentScrollY);
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
    object.order = reader.readDouble(offsets[11]);
    object.currentScrollY = reader.readLong(offsets[12]);
    return object;
  }

  @override
  P deserializeProperty<P>(BinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case 0:
        return (reader.readLongOrNull(offset)) as P;
      case 1:
        return (reader.readString(offset)) as P;
      case 2:
        return (reader.readString(offset)) as P;
      case 3:
        return (reader.readString(offset)) as P;
      case 4:
        return (reader.readDouble(offset)) as P;
      case 5:
        return (reader.readLong(offset)) as P;
      case 6:
        return (reader.readString(offset)) as P;
      case 7:
        return (reader.readString(offset)) as P;
      case 8:
        return (reader.readLong(offset)) as P;
      case 9:
        return (reader.readDateTime(offset)) as P;
      case 10:
        return (reader.readDateTime(offset)) as P;
      case 11:
        return (reader.readDouble(offset)) as P;
      case 12:
        return (reader.readLong(offset)) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }
}

extension GetCollection on Isar {
  IsarCollection<Manga> get mangas {
    return getCollection('Manga');
  }
}

extension MangaQueryWhereSort on QueryBuilder<Manga, QWhere> {
  QueryBuilder<Manga, QAfterWhere> anyId() {
    return addWhereClause(WhereClause(indexName: 'id'));
  }

  QueryBuilder<Manga, QAfterWhere> anyUrl() {
    return addWhereClause(WhereClause(indexName: 'url'));
  }

  QueryBuilder<Manga, QAfterWhere> anyOrder() {
    return addWhereClause(WhereClause(indexName: 'order'));
  }
}

extension MangaQueryWhere on QueryBuilder<Manga, QWhereClause> {
  QueryBuilder<Manga, QAfterWhereClause> titleWordEqualTo(String title) {
    return addWhereClause(WhereClause(
      indexName: 'title',
      upper: [title],
      includeUpper: true,
      lower: [title],
      includeLower: true,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> titleWordStartsWith(String value) {
    final convertedValue = value;
    return addWhereClause(WhereClause(
      indexName: 'title',
      lower: [convertedValue],
      upper: ['$convertedValue\u{FFFFF}'],
      includeLower: true,
      includeUpper: true,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> urlEqualTo(String url) {
    return addWhereClause(WhereClause(
      indexName: 'url',
      upper: [url],
      includeUpper: true,
      lower: [url],
      includeLower: true,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> urlNotEqualTo(String url) {
    return addWhereClause(WhereClause(
      indexName: 'url',
      upper: [url],
      includeUpper: false,
    )).addWhereClause(WhereClause(
      indexName: 'url',
      lower: [url],
      includeLower: false,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> urlStartsWith(String value) {
    final convertedValue = value;
    return addWhereClause(WhereClause(
      indexName: 'url',
      lower: [convertedValue],
      upper: ['$convertedValue\u{FFFFF}'],
      includeLower: true,
      includeUpper: true,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> orderBetween(
      double lower, double upper,
      {bool includeLower = true, bool includeUpper = true}) {
    return addWhereClause(WhereClause(
      indexName: 'order',
      upper: [upper],
      includeUpper: includeUpper,
      lower: [lower],
      includeLower: includeLower,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> orderGreaterThan(double value,
      {bool include = false}) {
    return addWhereClause(WhereClause(
      indexName: 'order',
      lower: [value],
      includeLower: include,
    ));
  }

  QueryBuilder<Manga, QAfterWhereClause> orderLessThan(double value,
      {bool include = false}) {
    return addWhereClause(WhereClause(
      indexName: 'order',
      upper: [value],
      includeUpper: include,
    ));
  }
}

extension MangaQueryFilter on QueryBuilder<Manga, QFilterCondition> {
  QueryBuilder<Manga, QAfterFilterCondition> idIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> idGreaterThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> idLessThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> idBetween(int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'id',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'title',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'title',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'title',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'title',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'title',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'coverImageUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlStartsWith(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'coverImageUrl',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'coverImageUrl',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'coverImageUrl',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> coverImageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'coverImageUrl',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'url',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'url',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'url',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'url',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> urlMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'url',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> rateGreaterThan(double value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'rate',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> rateLessThan(double value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'rate',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> rateBetween(
      double lower, double upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'rate',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> viewsCountEqualTo(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'viewsCount',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> viewsCountGreaterThan(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'viewsCount',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> viewsCountLessThan(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'viewsCount',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> viewsCountBetween(
      int lower, int upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'viewsCount',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'lastChapterUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlStartsWith(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'lastChapterUrl',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlEndsWith(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'lastChapterUrl',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlContains(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'lastChapterUrl',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> lastChapterUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'lastChapterUrl',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlEqualTo(
      String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'currentChapterUrl',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlStartsWith(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'currentChapterUrl',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlEndsWith(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'currentChapterUrl',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlContains(
      String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'currentChapterUrl',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentChapterUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'currentChapterUrl',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> readCountEqualTo(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'readCount',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> readCountGreaterThan(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'readCount',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> readCountLessThan(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'readCount',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> readCountBetween(
      int lower, int upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'readCount',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'createdAt',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> createdAtGreaterThan(
      DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'createdAt',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> createdAtLessThan(DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'createdAt',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> createdAtBetween(
      DateTime lower, DateTime upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'createdAt',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'updatedAt',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> updatedAtGreaterThan(
      DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'updatedAt',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> updatedAtLessThan(DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'updatedAt',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> updatedAtBetween(
      DateTime lower, DateTime upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'updatedAt',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> orderGreaterThan(double value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'order',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> orderLessThan(double value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'order',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> orderBetween(
      double lower, double upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'order',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentScrollYEqualTo(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'currentScrollY',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentScrollYGreaterThan(
      int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'currentScrollY',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentScrollYLessThan(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'currentScrollY',
      value: value,
    ));
  }

  QueryBuilder<Manga, QAfterFilterCondition> currentScrollYBetween(
      int lower, int upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'currentScrollY',
      lower: lower,
      upper: upper,
    ));
  }
}

extension MangaQueryLinks on QueryBuilder<Manga, QFilterCondition> {}

extension MangaQueryWhereSortBy on QueryBuilder<Manga, QSortBy> {
  QueryBuilder<Manga, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByTitle() {
    return addSortByInternal('title', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByTitleDesc() {
    return addSortByInternal('title', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByCoverImageUrl() {
    return addSortByInternal('coverImageUrl', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByCoverImageUrlDesc() {
    return addSortByInternal('coverImageUrl', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByUrl() {
    return addSortByInternal('url', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByUrlDesc() {
    return addSortByInternal('url', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByRate() {
    return addSortByInternal('rate', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByRateDesc() {
    return addSortByInternal('rate', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByViewsCount() {
    return addSortByInternal('viewsCount', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByViewsCountDesc() {
    return addSortByInternal('viewsCount', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByLastChapterUrl() {
    return addSortByInternal('lastChapterUrl', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByLastChapterUrlDesc() {
    return addSortByInternal('lastChapterUrl', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByCurrentChapterUrl() {
    return addSortByInternal('currentChapterUrl', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByCurrentChapterUrlDesc() {
    return addSortByInternal('currentChapterUrl', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByReadCount() {
    return addSortByInternal('readCount', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByReadCountDesc() {
    return addSortByInternal('readCount', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByCreatedAt() {
    return addSortByInternal('createdAt', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByCreatedAtDesc() {
    return addSortByInternal('createdAt', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByUpdatedAt() {
    return addSortByInternal('updatedAt', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByUpdatedAtDesc() {
    return addSortByInternal('updatedAt', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByOrder() {
    return addSortByInternal('order', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByOrderDesc() {
    return addSortByInternal('order', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByCurrentScrollY() {
    return addSortByInternal('currentScrollY', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> sortByCurrentScrollYDesc() {
    return addSortByInternal('currentScrollY', Sort.Desc);
  }
}

extension MangaQueryWhereSortThenBy on QueryBuilder<Manga, QSortThenBy> {
  QueryBuilder<Manga, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByTitle() {
    return addSortByInternal('title', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByTitleDesc() {
    return addSortByInternal('title', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByCoverImageUrl() {
    return addSortByInternal('coverImageUrl', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByCoverImageUrlDesc() {
    return addSortByInternal('coverImageUrl', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByUrl() {
    return addSortByInternal('url', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByUrlDesc() {
    return addSortByInternal('url', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByRate() {
    return addSortByInternal('rate', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByRateDesc() {
    return addSortByInternal('rate', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByViewsCount() {
    return addSortByInternal('viewsCount', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByViewsCountDesc() {
    return addSortByInternal('viewsCount', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByLastChapterUrl() {
    return addSortByInternal('lastChapterUrl', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByLastChapterUrlDesc() {
    return addSortByInternal('lastChapterUrl', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByCurrentChapterUrl() {
    return addSortByInternal('currentChapterUrl', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByCurrentChapterUrlDesc() {
    return addSortByInternal('currentChapterUrl', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByReadCount() {
    return addSortByInternal('readCount', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByReadCountDesc() {
    return addSortByInternal('readCount', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByCreatedAt() {
    return addSortByInternal('createdAt', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByCreatedAtDesc() {
    return addSortByInternal('createdAt', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByUpdatedAt() {
    return addSortByInternal('updatedAt', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByUpdatedAtDesc() {
    return addSortByInternal('updatedAt', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByOrder() {
    return addSortByInternal('order', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByOrderDesc() {
    return addSortByInternal('order', Sort.Desc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByCurrentScrollY() {
    return addSortByInternal('currentScrollY', Sort.Asc);
  }

  QueryBuilder<Manga, QAfterSortBy> thenByCurrentScrollYDesc() {
    return addSortByInternal('currentScrollY', Sort.Desc);
  }
}

extension MangaQueryWhereDistinct on QueryBuilder<Manga, QDistinct> {
  QueryBuilder<Manga, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<Manga, QDistinct> distinctByTitle({bool caseSensitive = true}) {
    return addDistinctByInternal('title', caseSensitive: caseSensitive);
  }

  QueryBuilder<Manga, QDistinct> distinctByCoverImageUrl(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('coverImageUrl', caseSensitive: caseSensitive);
  }

  QueryBuilder<Manga, QDistinct> distinctByUrl({bool caseSensitive = true}) {
    return addDistinctByInternal('url', caseSensitive: caseSensitive);
  }

  QueryBuilder<Manga, QDistinct> distinctByRate() {
    return addDistinctByInternal('rate');
  }

  QueryBuilder<Manga, QDistinct> distinctByViewsCount() {
    return addDistinctByInternal('viewsCount');
  }

  QueryBuilder<Manga, QDistinct> distinctByLastChapterUrl(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('lastChapterUrl',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<Manga, QDistinct> distinctByCurrentChapterUrl(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('currentChapterUrl',
        caseSensitive: caseSensitive);
  }

  QueryBuilder<Manga, QDistinct> distinctByReadCount() {
    return addDistinctByInternal('readCount');
  }

  QueryBuilder<Manga, QDistinct> distinctByCreatedAt() {
    return addDistinctByInternal('createdAt');
  }

  QueryBuilder<Manga, QDistinct> distinctByUpdatedAt() {
    return addDistinctByInternal('updatedAt');
  }

  QueryBuilder<Manga, QDistinct> distinctByOrder() {
    return addDistinctByInternal('order');
  }

  QueryBuilder<Manga, QDistinct> distinctByCurrentScrollY() {
    return addDistinctByInternal('currentScrollY');
  }
}

extension MangaQueryProperty on QueryBuilder<Manga, QQueryProperty> {
  QueryBuilder<int?, QQueryOperations> idProperty() {
    return addPropertyName('id');
  }

  QueryBuilder<String, QQueryOperations> titleProperty() {
    return addPropertyName('title');
  }

  QueryBuilder<String, QQueryOperations> coverImageUrlProperty() {
    return addPropertyName('coverImageUrl');
  }

  QueryBuilder<String, QQueryOperations> urlProperty() {
    return addPropertyName('url');
  }

  QueryBuilder<double, QQueryOperations> rateProperty() {
    return addPropertyName('rate');
  }

  QueryBuilder<int, QQueryOperations> viewsCountProperty() {
    return addPropertyName('viewsCount');
  }

  QueryBuilder<String, QQueryOperations> lastChapterUrlProperty() {
    return addPropertyName('lastChapterUrl');
  }

  QueryBuilder<String, QQueryOperations> currentChapterUrlProperty() {
    return addPropertyName('currentChapterUrl');
  }

  QueryBuilder<int, QQueryOperations> readCountProperty() {
    return addPropertyName('readCount');
  }

  QueryBuilder<DateTime, QQueryOperations> createdAtProperty() {
    return addPropertyName('createdAt');
  }

  QueryBuilder<DateTime, QQueryOperations> updatedAtProperty() {
    return addPropertyName('updatedAt');
  }

  QueryBuilder<double, QQueryOperations> orderProperty() {
    return addPropertyName('order');
  }

  QueryBuilder<int, QQueryOperations> currentScrollYProperty() {
    return addPropertyName('currentScrollY');
  }
}
