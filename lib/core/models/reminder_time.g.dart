// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_time.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReminderTimeCollection on Isar {
  IsarCollection<ReminderTime> get reminderTimes => this.collection();
}

const ReminderTimeSchema = CollectionSchema(
  name: r'ReminderTime',
  id: -2850666418744187622,
  properties: {
    r'hour': PropertySchema(
      id: 0,
      name: r'hour',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 1,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isVibrationEnabled': PropertySchema(
      id: 2,
      name: r'isVibrationEnabled',
      type: IsarType.bool,
    ),
    r'lastTriggeredAt': PropertySchema(
      id: 3,
      name: r'lastTriggeredAt',
      type: IsarType.dateTime,
    ),
    r'minute': PropertySchema(
      id: 4,
      name: r'minute',
      type: IsarType.long,
    ),
    r'soundRingtone': PropertySchema(
      id: 5,
      name: r'soundRingtone',
      type: IsarType.string,
    )
  },
  estimateSize: _reminderTimeEstimateSize,
  serialize: _reminderTimeSerialize,
  deserialize: _reminderTimeDeserialize,
  deserializeProp: _reminderTimeDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'medicine': LinkSchema(
      id: -8999006426910551535,
      name: r'medicine',
      target: r'Medicine',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _reminderTimeGetId,
  getLinks: _reminderTimeGetLinks,
  attach: _reminderTimeAttach,
  version: '3.1.0+1',
);

int _reminderTimeEstimateSize(
  ReminderTime object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.soundRingtone.length * 3;
  return bytesCount;
}

void _reminderTimeSerialize(
  ReminderTime object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hour);
  writer.writeBool(offsets[1], object.isActive);
  writer.writeBool(offsets[2], object.isVibrationEnabled);
  writer.writeDateTime(offsets[3], object.lastTriggeredAt);
  writer.writeLong(offsets[4], object.minute);
  writer.writeString(offsets[5], object.soundRingtone);
}

ReminderTime _reminderTimeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReminderTime();
  object.hour = reader.readLong(offsets[0]);
  object.id = id;
  object.isActive = reader.readBool(offsets[1]);
  object.isVibrationEnabled = reader.readBool(offsets[2]);
  object.lastTriggeredAt = reader.readDateTimeOrNull(offsets[3]);
  object.minute = reader.readLong(offsets[4]);
  object.soundRingtone = reader.readString(offsets[5]);
  return object;
}

P _reminderTimeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reminderTimeGetId(ReminderTime object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reminderTimeGetLinks(ReminderTime object) {
  return [object.medicine];
}

void _reminderTimeAttach(
    IsarCollection<dynamic> col, Id id, ReminderTime object) {
  object.id = id;
  object.medicine.attach(col, col.isar.collection<Medicine>(), r'medicine', id);
}

extension ReminderTimeQueryWhereSort
    on QueryBuilder<ReminderTime, ReminderTime, QWhere> {
  QueryBuilder<ReminderTime, ReminderTime, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReminderTimeQueryWhere
    on QueryBuilder<ReminderTime, ReminderTime, QWhereClause> {
  QueryBuilder<ReminderTime, ReminderTime, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReminderTimeQueryFilter
    on QueryBuilder<ReminderTime, ReminderTime, QFilterCondition> {
  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> hourEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hour',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      hourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hour',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> hourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hour',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> hourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      isVibrationEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isVibrationEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      lastTriggeredAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastTriggeredAt',
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      lastTriggeredAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastTriggeredAt',
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      lastTriggeredAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastTriggeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      lastTriggeredAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastTriggeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      lastTriggeredAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastTriggeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      lastTriggeredAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastTriggeredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> minuteEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minute',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      minuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minute',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      minuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minute',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> minuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      soundRingtoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'soundRingtone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      soundRingtoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'soundRingtone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      soundRingtoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'soundRingtone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      soundRingtoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'soundRingtone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      soundRingtoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'soundRingtone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      soundRingtoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'soundRingtone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      soundRingtoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'soundRingtone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      soundRingtoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'soundRingtone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      soundRingtoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'soundRingtone',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      soundRingtoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'soundRingtone',
        value: '',
      ));
    });
  }
}

extension ReminderTimeQueryObject
    on QueryBuilder<ReminderTime, ReminderTime, QFilterCondition> {}

extension ReminderTimeQueryLinks
    on QueryBuilder<ReminderTime, ReminderTime, QFilterCondition> {
  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition> medicine(
      FilterQuery<Medicine> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'medicine');
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterFilterCondition>
      medicineIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'medicine', 0, true, 0, true);
    });
  }
}

extension ReminderTimeQuerySortBy
    on QueryBuilder<ReminderTime, ReminderTime, QSortBy> {
  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> sortByHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hour', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> sortByHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hour', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy>
      sortByIsVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVibrationEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy>
      sortByIsVibrationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVibrationEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy>
      sortByLastTriggeredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggeredAt', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy>
      sortByLastTriggeredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggeredAt', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> sortByMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minute', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> sortByMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minute', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> sortBySoundRingtone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundRingtone', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy>
      sortBySoundRingtoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundRingtone', Sort.desc);
    });
  }
}

extension ReminderTimeQuerySortThenBy
    on QueryBuilder<ReminderTime, ReminderTime, QSortThenBy> {
  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> thenByHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hour', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> thenByHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hour', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy>
      thenByIsVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVibrationEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy>
      thenByIsVibrationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVibrationEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy>
      thenByLastTriggeredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggeredAt', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy>
      thenByLastTriggeredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggeredAt', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> thenByMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minute', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> thenByMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minute', Sort.desc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy> thenBySoundRingtone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundRingtone', Sort.asc);
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QAfterSortBy>
      thenBySoundRingtoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundRingtone', Sort.desc);
    });
  }
}

extension ReminderTimeQueryWhereDistinct
    on QueryBuilder<ReminderTime, ReminderTime, QDistinct> {
  QueryBuilder<ReminderTime, ReminderTime, QDistinct> distinctByHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hour');
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QDistinct>
      distinctByIsVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isVibrationEnabled');
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QDistinct>
      distinctByLastTriggeredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastTriggeredAt');
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QDistinct> distinctByMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minute');
    });
  }

  QueryBuilder<ReminderTime, ReminderTime, QDistinct> distinctBySoundRingtone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'soundRingtone',
          caseSensitive: caseSensitive);
    });
  }
}

extension ReminderTimeQueryProperty
    on QueryBuilder<ReminderTime, ReminderTime, QQueryProperty> {
  QueryBuilder<ReminderTime, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReminderTime, int, QQueryOperations> hourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hour');
    });
  }

  QueryBuilder<ReminderTime, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<ReminderTime, bool, QQueryOperations>
      isVibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isVibrationEnabled');
    });
  }

  QueryBuilder<ReminderTime, DateTime?, QQueryOperations>
      lastTriggeredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastTriggeredAt');
    });
  }

  QueryBuilder<ReminderTime, int, QQueryOperations> minuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minute');
    });
  }

  QueryBuilder<ReminderTime, String, QQueryOperations> soundRingtoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'soundRingtone');
    });
  }
}
