// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicineCollection on Isar {
  IsarCollection<Medicine> get medicines => this.collection();
}

const MedicineSchema = CollectionSchema(
  name: r'Medicine',
  id: 284787057740778982,
  properties: {
    r'colorHex': PropertySchema(
      id: 0,
      name: r'colorHex',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentStock': PropertySchema(
      id: 2,
      name: r'currentStock',
      type: IsarType.long,
    ),
    r'doctorName': PropertySchema(
      id: 3,
      name: r'doctorName',
      type: IsarType.string,
    ),
    r'dosageUnit': PropertySchema(
      id: 4,
      name: r'dosageUnit',
      type: IsarType.string,
    ),
    r'dosageValue': PropertySchema(
      id: 5,
      name: r'dosageValue',
      type: IsarType.double,
    ),
    r'endDate': PropertySchema(
      id: 6,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'formFactor': PropertySchema(
      id: 7,
      name: r'formFactor',
      type: IsarType.string,
    ),
    r'frequency': PropertySchema(
      id: 8,
      name: r'frequency',
      type: IsarType.byte,
      enumMap: _MedicinefrequencyEnumValueMap,
    ),
    r'intervalHours': PropertySchema(
      id: 9,
      name: r'intervalHours',
      type: IsarType.long,
    ),
    r'isOngoing': PropertySchema(
      id: 10,
      name: r'isOngoing',
      type: IsarType.bool,
    ),
    r'isRefillAlertEnabled': PropertySchema(
      id: 11,
      name: r'isRefillAlertEnabled',
      type: IsarType.bool,
    ),
    r'lowStockThreshold': PropertySchema(
      id: 12,
      name: r'lowStockThreshold',
      type: IsarType.long,
    ),
    r'mealType': PropertySchema(
      id: 13,
      name: r'mealType',
      type: IsarType.byte,
      enumMap: _MedicinemealTypeEnumValueMap,
    ),
    r'name': PropertySchema(
      id: 14,
      name: r'name',
      type: IsarType.string,
    ),
    r'pillImageLocalPath': PropertySchema(
      id: 15,
      name: r'pillImageLocalPath',
      type: IsarType.string,
    ),
    r'prescriptionNotes': PropertySchema(
      id: 16,
      name: r'prescriptionNotes',
      type: IsarType.string,
    ),
    r'specificDaysOfWeek': PropertySchema(
      id: 17,
      name: r'specificDaysOfWeek',
      type: IsarType.longList,
    ),
    r'startDate': PropertySchema(
      id: 18,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 19,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _medicineEstimateSize,
  serialize: _medicineSerialize,
  deserialize: _medicineDeserialize,
  deserializeProp: _medicineDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'reminders': LinkSchema(
      id: 3094754629613636918,
      name: r'reminders',
      target: r'ReminderTime',
      single: false,
    ),
    r'doseLogs': LinkSchema(
      id: -8551898922957680750,
      name: r'doseLogs',
      target: r'DoseLog',
      single: false,
      linkName: r'medicine',
    )
  },
  embeddedSchemas: {},
  getId: _medicineGetId,
  getLinks: _medicineGetLinks,
  attach: _medicineAttach,
  version: '3.1.0+1',
);

int _medicineEstimateSize(
  Medicine object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.colorHex.length * 3;
  {
    final value = object.doctorName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.dosageUnit.length * 3;
  bytesCount += 3 + object.formFactor.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.pillImageLocalPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.prescriptionNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.specificDaysOfWeek.length * 8;
  return bytesCount;
}

void _medicineSerialize(
  Medicine object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.colorHex);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.currentStock);
  writer.writeString(offsets[3], object.doctorName);
  writer.writeString(offsets[4], object.dosageUnit);
  writer.writeDouble(offsets[5], object.dosageValue);
  writer.writeDateTime(offsets[6], object.endDate);
  writer.writeString(offsets[7], object.formFactor);
  writer.writeByte(offsets[8], object.frequency.index);
  writer.writeLong(offsets[9], object.intervalHours);
  writer.writeBool(offsets[10], object.isOngoing);
  writer.writeBool(offsets[11], object.isRefillAlertEnabled);
  writer.writeLong(offsets[12], object.lowStockThreshold);
  writer.writeByte(offsets[13], object.mealType.index);
  writer.writeString(offsets[14], object.name);
  writer.writeString(offsets[15], object.pillImageLocalPath);
  writer.writeString(offsets[16], object.prescriptionNotes);
  writer.writeLongList(offsets[17], object.specificDaysOfWeek);
  writer.writeDateTime(offsets[18], object.startDate);
  writer.writeDateTime(offsets[19], object.updatedAt);
}

Medicine _medicineDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Medicine();
  object.colorHex = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.currentStock = reader.readLong(offsets[2]);
  object.doctorName = reader.readStringOrNull(offsets[3]);
  object.dosageUnit = reader.readString(offsets[4]);
  object.dosageValue = reader.readDouble(offsets[5]);
  object.endDate = reader.readDateTimeOrNull(offsets[6]);
  object.formFactor = reader.readString(offsets[7]);
  object.frequency =
      _MedicinefrequencyValueEnumMap[reader.readByteOrNull(offsets[8])] ??
          FrequencyType.daily;
  object.id = id;
  object.intervalHours = reader.readLongOrNull(offsets[9]);
  object.isOngoing = reader.readBool(offsets[10]);
  object.isRefillAlertEnabled = reader.readBool(offsets[11]);
  object.lowStockThreshold = reader.readLong(offsets[12]);
  object.mealType =
      _MedicinemealTypeValueEnumMap[reader.readByteOrNull(offsets[13])] ??
          MealType.beforeMeal;
  object.name = reader.readString(offsets[14]);
  object.pillImageLocalPath = reader.readStringOrNull(offsets[15]);
  object.prescriptionNotes = reader.readStringOrNull(offsets[16]);
  object.specificDaysOfWeek = reader.readLongList(offsets[17]) ?? [];
  object.startDate = reader.readDateTime(offsets[18]);
  object.updatedAt = reader.readDateTime(offsets[19]);
  return object;
}

P _medicineDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (_MedicinefrequencyValueEnumMap[reader.readByteOrNull(offset)] ??
          FrequencyType.daily) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (_MedicinemealTypeValueEnumMap[reader.readByteOrNull(offset)] ??
          MealType.beforeMeal) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readLongList(offset) ?? []) as P;
    case 18:
      return (reader.readDateTime(offset)) as P;
    case 19:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MedicinefrequencyEnumValueMap = {
  'daily': 0,
  'specificDays': 1,
  'interval': 2,
};
const _MedicinefrequencyValueEnumMap = {
  0: FrequencyType.daily,
  1: FrequencyType.specificDays,
  2: FrequencyType.interval,
};
const _MedicinemealTypeEnumValueMap = {
  'beforeMeal': 0,
  'afterMeal': 1,
  'withMeal': 2,
  'noRelation': 3,
};
const _MedicinemealTypeValueEnumMap = {
  0: MealType.beforeMeal,
  1: MealType.afterMeal,
  2: MealType.withMeal,
  3: MealType.noRelation,
};

Id _medicineGetId(Medicine object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicineGetLinks(Medicine object) {
  return [object.reminders, object.doseLogs];
}

void _medicineAttach(IsarCollection<dynamic> col, Id id, Medicine object) {
  object.id = id;
  object.reminders
      .attach(col, col.isar.collection<ReminderTime>(), r'reminders', id);
  object.doseLogs.attach(col, col.isar.collection<DoseLog>(), r'doseLogs', id);
}

extension MedicineQueryWhereSort on QueryBuilder<Medicine, Medicine, QWhere> {
  QueryBuilder<Medicine, Medicine, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MedicineQueryWhere on QueryBuilder<Medicine, Medicine, QWhereClause> {
  QueryBuilder<Medicine, Medicine, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Medicine, Medicine, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterWhereClause> idBetween(
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

extension MedicineQueryFilter
    on QueryBuilder<Medicine, Medicine, QFilterCondition> {
  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> colorHexEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> colorHexGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> colorHexLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> colorHexBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorHex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> colorHexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> colorHexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> colorHexContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> colorHexMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'colorHex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> colorHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> colorHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'colorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> currentStockEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStock',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      currentStockGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStock',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> currentStockLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStock',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> currentStockBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStock',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doctorNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'doctorName',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      doctorNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'doctorName',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doctorNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doctorNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doctorNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doctorNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'doctorName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doctorNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doctorNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doctorNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'doctorName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doctorNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'doctorName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doctorNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doctorName',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      doctorNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'doctorName',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageUnitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageUnitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageUnitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageUnitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dosageUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageUnitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageUnitContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageUnitMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dosageUnit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosageUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      dosageUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dosageUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosageValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      dosageValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dosageValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dosageValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> dosageValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dosageValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> endDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> formFactorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formFactor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> formFactorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formFactor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> formFactorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formFactor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> formFactorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formFactor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> formFactorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formFactor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> formFactorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formFactor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> formFactorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formFactor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> formFactorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formFactor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> formFactorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formFactor',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      formFactorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formFactor',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> frequencyEqualTo(
      FrequencyType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> frequencyGreaterThan(
    FrequencyType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> frequencyLessThan(
    FrequencyType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequency',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> frequencyBetween(
    FrequencyType lower,
    FrequencyType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      intervalHoursIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'intervalHours',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      intervalHoursIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'intervalHours',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> intervalHoursEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      intervalHoursGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'intervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> intervalHoursLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'intervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> intervalHoursBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'intervalHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> isOngoingEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isOngoing',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      isRefillAlertEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRefillAlertEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      lowStockThresholdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lowStockThreshold',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      lowStockThresholdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lowStockThreshold',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      lowStockThresholdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lowStockThreshold',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      lowStockThresholdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lowStockThreshold',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> mealTypeEqualTo(
      MealType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealType',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> mealTypeGreaterThan(
    MealType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealType',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> mealTypeLessThan(
    MealType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealType',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> mealTypeBetween(
    MealType lower,
    MealType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pillImageLocalPath',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pillImageLocalPath',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pillImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pillImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pillImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pillImageLocalPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pillImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pillImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pillImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pillImageLocalPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pillImageLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      pillImageLocalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pillImageLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'prescriptionNotes',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'prescriptionNotes',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prescriptionNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prescriptionNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prescriptionNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prescriptionNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'prescriptionNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'prescriptionNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'prescriptionNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'prescriptionNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prescriptionNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      prescriptionNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'prescriptionNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      specificDaysOfWeekElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'specificDaysOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      specificDaysOfWeekElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'specificDaysOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      specificDaysOfWeekElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'specificDaysOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      specificDaysOfWeekElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'specificDaysOfWeek',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      specificDaysOfWeekLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'specificDaysOfWeek',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      specificDaysOfWeekIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'specificDaysOfWeek',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      specificDaysOfWeekIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'specificDaysOfWeek',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      specificDaysOfWeekLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'specificDaysOfWeek',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      specificDaysOfWeekLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'specificDaysOfWeek',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      specificDaysOfWeekLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'specificDaysOfWeek',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> startDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MedicineQueryObject
    on QueryBuilder<Medicine, Medicine, QFilterCondition> {}

extension MedicineQueryLinks
    on QueryBuilder<Medicine, Medicine, QFilterCondition> {
  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> reminders(
      FilterQuery<ReminderTime> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'reminders');
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      remindersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'reminders', length, true, length, true);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> remindersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'reminders', 0, true, 0, true);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      remindersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'reminders', 0, false, 999999, true);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      remindersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'reminders', 0, true, length, include);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      remindersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'reminders', length, include, 999999, true);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      remindersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'reminders', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doseLogs(
      FilterQuery<DoseLog> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'doseLogs');
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doseLogsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'doseLogs', length, true, length, true);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doseLogsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'doseLogs', 0, true, 0, true);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doseLogsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'doseLogs', 0, false, 999999, true);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      doseLogsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'doseLogs', 0, true, length, include);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition>
      doseLogsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'doseLogs', length, include, 999999, true);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterFilterCondition> doseLogsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'doseLogs', lower, includeLower, upper, includeUpper);
    });
  }
}

extension MedicineQuerySortBy on QueryBuilder<Medicine, Medicine, QSortBy> {
  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByCurrentStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStock', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByCurrentStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStock', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByDoctorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorName', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByDoctorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorName', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByDosageUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageUnit', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByDosageUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageUnit', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByDosageValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageValue', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByDosageValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageValue', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByFormFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formFactor', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByFormFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formFactor', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalHours', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByIntervalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalHours', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByIsOngoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOngoing', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByIsOngoingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOngoing', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByIsRefillAlertEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRefillAlertEnabled', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy>
      sortByIsRefillAlertEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRefillAlertEnabled', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByLowStockThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByLowStockThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByMealType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByMealTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByPillImageLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pillImageLocalPath', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy>
      sortByPillImageLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pillImageLocalPath', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByPrescriptionNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prescriptionNotes', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByPrescriptionNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prescriptionNotes', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MedicineQuerySortThenBy
    on QueryBuilder<Medicine, Medicine, QSortThenBy> {
  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByCurrentStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStock', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByCurrentStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStock', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByDoctorName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorName', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByDoctorNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorName', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByDosageUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageUnit', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByDosageUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageUnit', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByDosageValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageValue', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByDosageValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageValue', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByFormFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formFactor', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByFormFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formFactor', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalHours', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByIntervalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalHours', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByIsOngoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOngoing', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByIsOngoingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isOngoing', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByIsRefillAlertEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRefillAlertEnabled', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy>
      thenByIsRefillAlertEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRefillAlertEnabled', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByLowStockThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByLowStockThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByMealType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByMealTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByPillImageLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pillImageLocalPath', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy>
      thenByPillImageLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pillImageLocalPath', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByPrescriptionNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prescriptionNotes', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByPrescriptionNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prescriptionNotes', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Medicine, Medicine, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MedicineQueryWhereDistinct
    on QueryBuilder<Medicine, Medicine, QDistinct> {
  QueryBuilder<Medicine, Medicine, QDistinct> distinctByColorHex(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorHex', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByCurrentStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStock');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByDoctorName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doctorName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByDosageUnit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dosageUnit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByDosageValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dosageValue');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByFormFactor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formFactor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequency');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intervalHours');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByIsOngoing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isOngoing');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByIsRefillAlertEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRefillAlertEnabled');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByLowStockThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lowStockThreshold');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByMealType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealType');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByPillImageLocalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pillImageLocalPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByPrescriptionNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prescriptionNotes',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctBySpecificDaysOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'specificDaysOfWeek');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<Medicine, Medicine, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension MedicineQueryProperty
    on QueryBuilder<Medicine, Medicine, QQueryProperty> {
  QueryBuilder<Medicine, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Medicine, String, QQueryOperations> colorHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorHex');
    });
  }

  QueryBuilder<Medicine, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Medicine, int, QQueryOperations> currentStockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStock');
    });
  }

  QueryBuilder<Medicine, String?, QQueryOperations> doctorNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doctorName');
    });
  }

  QueryBuilder<Medicine, String, QQueryOperations> dosageUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dosageUnit');
    });
  }

  QueryBuilder<Medicine, double, QQueryOperations> dosageValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dosageValue');
    });
  }

  QueryBuilder<Medicine, DateTime?, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<Medicine, String, QQueryOperations> formFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formFactor');
    });
  }

  QueryBuilder<Medicine, FrequencyType, QQueryOperations> frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequency');
    });
  }

  QueryBuilder<Medicine, int?, QQueryOperations> intervalHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intervalHours');
    });
  }

  QueryBuilder<Medicine, bool, QQueryOperations> isOngoingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isOngoing');
    });
  }

  QueryBuilder<Medicine, bool, QQueryOperations>
      isRefillAlertEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRefillAlertEnabled');
    });
  }

  QueryBuilder<Medicine, int, QQueryOperations> lowStockThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lowStockThreshold');
    });
  }

  QueryBuilder<Medicine, MealType, QQueryOperations> mealTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealType');
    });
  }

  QueryBuilder<Medicine, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Medicine, String?, QQueryOperations>
      pillImageLocalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pillImageLocalPath');
    });
  }

  QueryBuilder<Medicine, String?, QQueryOperations>
      prescriptionNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prescriptionNotes');
    });
  }

  QueryBuilder<Medicine, List<int>, QQueryOperations>
      specificDaysOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'specificDaysOfWeek');
    });
  }

  QueryBuilder<Medicine, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<Medicine, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
