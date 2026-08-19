// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDoseLogCollection on Isar {
  IsarCollection<DoseLog> get doseLogs => this.collection();
}

const DoseLogSchema = CollectionSchema(
  name: r'DoseLog',
  id: -6875638677250359335,
  properties: {
    r'actualTakenDateTime': PropertySchema(
      id: 0,
      name: r'actualTakenDateTime',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 2,
      name: r'notes',
      type: IsarType.string,
    ),
    r'scheduledDateTime': PropertySchema(
      id: 3,
      name: r'scheduledDateTime',
      type: IsarType.dateTime,
    ),
    r'skipReason': PropertySchema(
      id: 4,
      name: r'skipReason',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.byte,
      enumMap: _DoseLogstatusEnumValueMap,
    )
  },
  estimateSize: _doseLogEstimateSize,
  serialize: _doseLogSerialize,
  deserialize: _doseLogDeserialize,
  deserializeProp: _doseLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'scheduledDateTime': IndexSchema(
      id: -6448396088416458812,
      name: r'scheduledDateTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'scheduledDateTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'medicine': LinkSchema(
      id: 4104484421502400464,
      name: r'medicine',
      target: r'Medicine',
      single: true,
    ),
    r'reminderTime': LinkSchema(
      id: -3041645148186599188,
      name: r'reminderTime',
      target: r'ReminderTime',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _doseLogGetId,
  getLinks: _doseLogGetLinks,
  attach: _doseLogAttach,
  version: '3.1.0+1',
);

int _doseLogEstimateSize(
  DoseLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.skipReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _doseLogSerialize(
  DoseLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.actualTakenDateTime);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.notes);
  writer.writeDateTime(offsets[3], object.scheduledDateTime);
  writer.writeString(offsets[4], object.skipReason);
  writer.writeByte(offsets[5], object.status.index);
}

DoseLog _doseLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DoseLog();
  object.actualTakenDateTime = reader.readDateTimeOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.notes = reader.readStringOrNull(offsets[2]);
  object.scheduledDateTime = reader.readDateTime(offsets[3]);
  object.skipReason = reader.readStringOrNull(offsets[4]);
  object.status =
      _DoseLogstatusValueEnumMap[reader.readByteOrNull(offsets[5])] ??
          MedicineStatus.taken;
  return object;
}

P _doseLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (_DoseLogstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          MedicineStatus.taken) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DoseLogstatusEnumValueMap = {
  'taken': 0,
  'skipped': 1,
  'missed': 2,
  'pending': 3,
};
const _DoseLogstatusValueEnumMap = {
  0: MedicineStatus.taken,
  1: MedicineStatus.skipped,
  2: MedicineStatus.missed,
  3: MedicineStatus.pending,
};

Id _doseLogGetId(DoseLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _doseLogGetLinks(DoseLog object) {
  return [object.medicine, object.reminderTime];
}

void _doseLogAttach(IsarCollection<dynamic> col, Id id, DoseLog object) {
  object.id = id;
  object.medicine.attach(col, col.isar.collection<Medicine>(), r'medicine', id);
  object.reminderTime
      .attach(col, col.isar.collection<ReminderTime>(), r'reminderTime', id);
}

extension DoseLogQueryWhereSort on QueryBuilder<DoseLog, DoseLog, QWhere> {
  QueryBuilder<DoseLog, DoseLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhere> anyScheduledDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'scheduledDateTime'),
      );
    });
  }
}

extension DoseLogQueryWhere on QueryBuilder<DoseLog, DoseLog, QWhereClause> {
  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> scheduledDateTimeEqualTo(
      DateTime scheduledDateTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'scheduledDateTime',
        value: [scheduledDateTime],
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> scheduledDateTimeNotEqualTo(
      DateTime scheduledDateTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledDateTime',
              lower: [],
              upper: [scheduledDateTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledDateTime',
              lower: [scheduledDateTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledDateTime',
              lower: [scheduledDateTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledDateTime',
              lower: [],
              upper: [scheduledDateTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause>
      scheduledDateTimeGreaterThan(
    DateTime scheduledDateTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledDateTime',
        lower: [scheduledDateTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> scheduledDateTimeLessThan(
    DateTime scheduledDateTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledDateTime',
        lower: [],
        upper: [scheduledDateTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> scheduledDateTimeBetween(
    DateTime lowerScheduledDateTime,
    DateTime upperScheduledDateTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledDateTime',
        lower: [lowerScheduledDateTime],
        includeLower: includeLower,
        upper: [upperScheduledDateTime],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DoseLogQueryFilter
    on QueryBuilder<DoseLog, DoseLog, QFilterCondition> {
  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition>
      actualTakenDateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actualTakenDateTime',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition>
      actualTakenDateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actualTakenDateTime',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition>
      actualTakenDateTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualTakenDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition>
      actualTakenDateTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualTakenDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition>
      actualTakenDateTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualTakenDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition>
      actualTakenDateTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualTakenDateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition>
      scheduledDateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition>
      scheduledDateTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition>
      scheduledDateTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition>
      scheduledDateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledDateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'skipReason',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'skipReason',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skipReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'skipReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'skipReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'skipReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'skipReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'skipReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'skipReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'skipReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skipReason',
        value: '',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> skipReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'skipReason',
        value: '',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> statusEqualTo(
      MedicineStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> statusGreaterThan(
    MedicineStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> statusLessThan(
    MedicineStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> statusBetween(
    MedicineStatus lower,
    MedicineStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DoseLogQueryObject
    on QueryBuilder<DoseLog, DoseLog, QFilterCondition> {}

extension DoseLogQueryLinks
    on QueryBuilder<DoseLog, DoseLog, QFilterCondition> {
  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> medicine(
      FilterQuery<Medicine> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'medicine');
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> medicineIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'medicine', 0, true, 0, true);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> reminderTime(
      FilterQuery<ReminderTime> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'reminderTime');
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> reminderTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'reminderTime', 0, true, 0, true);
    });
  }
}

extension DoseLogQuerySortBy on QueryBuilder<DoseLog, DoseLog, QSortBy> {
  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByActualTakenDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualTakenDateTime', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByActualTakenDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualTakenDateTime', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByScheduledDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateTime', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByScheduledDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateTime', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortBySkipReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipReason', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortBySkipReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipReason', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension DoseLogQuerySortThenBy
    on QueryBuilder<DoseLog, DoseLog, QSortThenBy> {
  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByActualTakenDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualTakenDateTime', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByActualTakenDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualTakenDateTime', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByScheduledDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateTime', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByScheduledDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDateTime', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenBySkipReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipReason', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenBySkipReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipReason', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension DoseLogQueryWhereDistinct
    on QueryBuilder<DoseLog, DoseLog, QDistinct> {
  QueryBuilder<DoseLog, DoseLog, QDistinct> distinctByActualTakenDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualTakenDateTime');
    });
  }

  QueryBuilder<DoseLog, DoseLog, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DoseLog, DoseLog, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QDistinct> distinctByScheduledDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledDateTime');
    });
  }

  QueryBuilder<DoseLog, DoseLog, QDistinct> distinctBySkipReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }
}

extension DoseLogQueryProperty
    on QueryBuilder<DoseLog, DoseLog, QQueryProperty> {
  QueryBuilder<DoseLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DoseLog, DateTime?, QQueryOperations>
      actualTakenDateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualTakenDateTime');
    });
  }

  QueryBuilder<DoseLog, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DoseLog, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<DoseLog, DateTime, QQueryOperations>
      scheduledDateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledDateTime');
    });
  }

  QueryBuilder<DoseLog, String?, QQueryOperations> skipReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipReason');
    });
  }

  QueryBuilder<DoseLog, MedicineStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
