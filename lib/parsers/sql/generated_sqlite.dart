import 'dart:convert';
import 'dart:ui';
import 'package:petitparser/petitparser.dart';

final doubleParser = (char('-').optional() &
        char('0').or(pattern('1-9') & digit().star()) &
        (char('.') & char('0').or(pattern('1-9') & digit().star())).optional())
    .flatten()
    .map((value) => double.parse(value));

final table = (stringIgnoreCase('CREATE').trim() &
        (stringIgnoreCase('TEMPORARY') | stringIgnoreCase('TEMP'))
            .trim()
            .optional() &
        stringIgnoreCase('TABLE').trim() &
        identifier.trim() &
        string('(').trim() &
        column
            .trim()
            .separatedBy(string(',').trim(),
                includeSeparators: false, optionalSeparatorAtEnd: false)
            .trim() &
        string(')').trim() &
        string(';').trim())
    .trim();

class Table {
  final TableTemp? temp;
  final String name;
  final List<Column> columns;

  const Table({
    required this.name,
    required this.columns,
    this.temp,
  });

  Table copyWith({
    TableTemp? temp,
    String? name,
    List<Column>? columns,
  }) {
    return Table(
      name: name ?? this.name,
      columns: columns ?? this.columns,
      temp: temp ?? this.temp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Table) {
      return this.temp == other.temp &&
          this.name == other.name &&
          this.columns == other.columns;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(temp, name, columns);

  static Table fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Table) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Table(
      name: map['name'] as String,
      columns: (map['columns'] as List).map((e) => Column.fromJson(e)).toList(),
      temp: TableTemp.fromJson(map['temp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp?.toJson(),
      'name': name,
      'columns': columns.map((e) => e.toJson()).toList(),
    };
  }
}

class TableTemp {
  final String _inner;

  const TableTemp(this._inner);

  static const temporary = TableTemp('temporary');
  static const temp = TableTemp('temp');

  static const values = [
    TableTemp.temporary,
    TableTemp.temp,
  ];

  static TableTemp fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      // ignore: unrelated_type_equality_checks
      if (json == v) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other.toString() == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isTemporary => this == TableTemp.temporary;
  bool get isTemp => this == TableTemp.temp;

  _T when<_T>({
    required _T Function() temporary,
    required _T Function() temp,
  }) {
    switch (this._inner) {
      case 'temporary':
        return temporary();
      case 'temp':
        return temp();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? temporary,
    _T Function()? temp,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'temporary':
        c = temporary;
        break;
      case 'temp':
        c = temp;
        break;
    }
    return (c ?? orElse).call();
  }
}

final identifier = (letter() & (letter() | digit()).star()).flatten().trim();

final column = (identifier.trim() &
        columnType.trim().optional() &
        constraint.trim().star())
    .trim();

class Column {
  final String name;
  final ColumnType? type;

  const Column({
    required this.name,
    this.type,
  });

  Column copyWith({
    String? name,
    ColumnType? type,
  }) {
    return Column(
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Column) {
      return this.name == other.name && this.type == other.type;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(name, type);

  static Column fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Column) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Column(
      name: map['name'] as String,
      type: ColumnType.fromJson(map['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type?.toJson(),
    };
  }
}

final columnType = ((stringIgnoreCase('TEXT') |
        stringIgnoreCase('NUMERIC') |
        stringIgnoreCase('INTEGER') |
        stringIgnoreCase('REAL') |
        stringIgnoreCase('BLOB')))
    .trim();

class ColumnType {
  final String _inner;

  const ColumnType(this._inner);

  static const text = ColumnType('text');
  static const numeric = ColumnType('numeric');
  static const integer = ColumnType('integer');
  static const real = ColumnType('real');
  static const blob = ColumnType('blob');

  static const values = [
    ColumnType.text,
    ColumnType.numeric,
    ColumnType.integer,
    ColumnType.real,
    ColumnType.blob,
  ];

  static ColumnType fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      // ignore: unrelated_type_equality_checks
      if (json == v) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other.toString() == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isText => this == ColumnType.text;
  bool get isNumeric => this == ColumnType.numeric;
  bool get isInteger => this == ColumnType.integer;
  bool get isReal => this == ColumnType.real;
  bool get isBlob => this == ColumnType.blob;

  _T when<_T>({
    required _T Function() text,
    required _T Function() numeric,
    required _T Function() integer,
    required _T Function() real,
    required _T Function() blob,
  }) {
    switch (this._inner) {
      case 'text':
        return text();
      case 'numeric':
        return numeric();
      case 'integer':
        return integer();
      case 'real':
        return real();
      case 'blob':
        return blob();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? text,
    _T Function()? numeric,
    _T Function()? integer,
    _T Function()? real,
    _T Function()? blob,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'text':
        c = text;
        break;
      case 'numeric':
        c = numeric;
        break;
      case 'integer':
        c = integer;
        break;
      case 'real':
        c = real;
        break;
      case 'blob':
        c = blob;
        break;
    }
    return (c ?? orElse).call();
  }
}

final constraint = (stringIgnoreCase('CONSTRAINT').trim() &
        identifier.trim() &
        ((stringIgnoreCase('PRIMARY').trim() &
                        stringIgnoreCase('KEY').trim() &
                        (stringIgnoreCase('ASC') | stringIgnoreCase('DESC'))
                            .trim()
                            .optional() &
                        conflictClause.trim())
                    .trim() |
                (stringIgnoreCase('NOT').trim() &
                        stringIgnoreCase('NULL').trim() &
                        conflictClause.trim())
                    .trim() |
                (stringIgnoreCase('UNIQUE').trim() & conflictClause.trim())
                    .trim() |
                stringIgnoreCase('CHECK').trim() |
                (stringIgnoreCase('DEFAULT').trim() & expression.trim())
                    .trim() |
                foreignKey.trim())
            .trim())
    .trim();

class Constraint {
  final String name;
  final ConstraintValue value;

  const Constraint({
    required this.name,
    required this.value,
  });

  Constraint copyWith({
    String? name,
    ConstraintValue? value,
  }) {
    return Constraint(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Constraint) {
      return this.name == other.name && this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(name, value);

  static Constraint fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Constraint) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Constraint(
      name: map['name'] as String,
      value: ConstraintValue.fromJson(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value.toJson(),
    };
  }
}

abstract class ConstraintValue {
  const ConstraintValue._();

  const factory ConstraintValue.primaryKey({
    required PrimaryKey value,
  }) = ConstraintPrimaryKey;
  const factory ConstraintValue.notNull({
    required NotNull value,
  }) = ConstraintNotNull;
  const factory ConstraintValue.unique({
    required Unique value,
  }) = ConstraintUnique;
  const factory ConstraintValue.check({
    required String value,
  }) = ConstraintCheck;
  const factory ConstraintValue.defaultValue({
    required DefaultValue value,
  }) = ConstraintDefaultValue;
  const factory ConstraintValue.foreignKey({
    required ForeignKey value,
  }) = ConstraintForeignKey;

  Object get value;

  _T when<_T>({
    required _T Function(PrimaryKey value) primaryKey,
    required _T Function(NotNull value) notNull,
    required _T Function(Unique value) unique,
    required _T Function(String value) check,
    required _T Function(DefaultValue value) defaultValue,
    required _T Function(ForeignKey value) foreignKey,
  }) {
    final v = this;
    if (v is ConstraintPrimaryKey) {
      return primaryKey(v.value);
    } else if (v is ConstraintNotNull) {
      return notNull(v.value);
    } else if (v is ConstraintUnique) {
      return unique(v.value);
    } else if (v is ConstraintCheck) {
      return check(v.value);
    } else if (v is ConstraintDefaultValue) {
      return defaultValue(v.value);
    } else if (v is ConstraintForeignKey) {
      return foreignKey(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(PrimaryKey value)? primaryKey,
    _T Function(NotNull value)? notNull,
    _T Function(Unique value)? unique,
    _T Function(String value)? check,
    _T Function(DefaultValue value)? defaultValue,
    _T Function(ForeignKey value)? foreignKey,
  }) {
    final v = this;
    if (v is ConstraintPrimaryKey) {
      return primaryKey != null ? primaryKey(v.value) : orElse.call();
    } else if (v is ConstraintNotNull) {
      return notNull != null ? notNull(v.value) : orElse.call();
    } else if (v is ConstraintUnique) {
      return unique != null ? unique(v.value) : orElse.call();
    } else if (v is ConstraintCheck) {
      return check != null ? check(v.value) : orElse.call();
    } else if (v is ConstraintDefaultValue) {
      return defaultValue != null ? defaultValue(v.value) : orElse.call();
    } else if (v is ConstraintForeignKey) {
      return foreignKey != null ? foreignKey(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(ConstraintPrimaryKey value) primaryKey,
    required _T Function(ConstraintNotNull value) notNull,
    required _T Function(ConstraintUnique value) unique,
    required _T Function(ConstraintCheck value) check,
    required _T Function(ConstraintDefaultValue value) defaultValue,
    required _T Function(ConstraintForeignKey value) foreignKey,
  }) {
    final v = this;
    if (v is ConstraintPrimaryKey) {
      return primaryKey(v);
    } else if (v is ConstraintNotNull) {
      return notNull(v);
    } else if (v is ConstraintUnique) {
      return unique(v);
    } else if (v is ConstraintCheck) {
      return check(v);
    } else if (v is ConstraintDefaultValue) {
      return defaultValue(v);
    } else if (v is ConstraintForeignKey) {
      return foreignKey(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(ConstraintPrimaryKey value)? primaryKey,
    _T Function(ConstraintNotNull value)? notNull,
    _T Function(ConstraintUnique value)? unique,
    _T Function(ConstraintCheck value)? check,
    _T Function(ConstraintDefaultValue value)? defaultValue,
    _T Function(ConstraintForeignKey value)? foreignKey,
  }) {
    final v = this;
    if (v is ConstraintPrimaryKey) {
      return primaryKey != null ? primaryKey(v) : orElse.call();
    } else if (v is ConstraintNotNull) {
      return notNull != null ? notNull(v) : orElse.call();
    } else if (v is ConstraintUnique) {
      return unique != null ? unique(v) : orElse.call();
    } else if (v is ConstraintCheck) {
      return check != null ? check(v) : orElse.call();
    } else if (v is ConstraintDefaultValue) {
      return defaultValue != null ? defaultValue(v) : orElse.call();
    } else if (v is ConstraintForeignKey) {
      return foreignKey != null ? foreignKey(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isPrimaryKey => this is ConstraintPrimaryKey;
  bool get isNotNull => this is ConstraintNotNull;
  bool get isUnique => this is ConstraintUnique;
  bool get isCheck => this is ConstraintCheck;
  bool get isDefaultValue => this is ConstraintDefaultValue;
  bool get isForeignKey => this is ConstraintForeignKey;

  TypeConstraintValue get typeEnum;

  static ConstraintValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ConstraintValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'primaryKey':
        return ConstraintPrimaryKey.fromJson(map);
      case 'notNull':
        return ConstraintNotNull.fromJson(map);
      case 'unique':
        return ConstraintUnique.fromJson(map);
      case 'check':
        return ConstraintCheck.fromJson(map);
      case 'defaultValue':
        return ConstraintDefaultValue.fromJson(map);
      case 'foreignKey':
        return ConstraintForeignKey.fromJson(map);
      default:
        throw Exception('Invalid discriminator for ConstraintValue.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class TypeConstraintValue {
  final String _inner;

  const TypeConstraintValue(this._inner);

  static const primaryKey = TypeConstraintValue('primaryKey');
  static const notNull = TypeConstraintValue('notNull');
  static const unique = TypeConstraintValue('unique');
  static const check = TypeConstraintValue('check');
  static const defaultValue = TypeConstraintValue('defaultValue');
  static const foreignKey = TypeConstraintValue('foreignKey');

  static const values = [
    TypeConstraintValue.primaryKey,
    TypeConstraintValue.notNull,
    TypeConstraintValue.unique,
    TypeConstraintValue.check,
    TypeConstraintValue.defaultValue,
    TypeConstraintValue.foreignKey,
  ];

  static TypeConstraintValue fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      // ignore: unrelated_type_equality_checks
      if (json == v) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other.toString() == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isPrimaryKey => this == TypeConstraintValue.primaryKey;
  bool get isNotNull => this == TypeConstraintValue.notNull;
  bool get isUnique => this == TypeConstraintValue.unique;
  bool get isCheck => this == TypeConstraintValue.check;
  bool get isDefaultValue => this == TypeConstraintValue.defaultValue;
  bool get isForeignKey => this == TypeConstraintValue.foreignKey;

  _T when<_T>({
    required _T Function() primaryKey,
    required _T Function() notNull,
    required _T Function() unique,
    required _T Function() check,
    required _T Function() defaultValue,
    required _T Function() foreignKey,
  }) {
    switch (this._inner) {
      case 'primaryKey':
        return primaryKey();
      case 'notNull':
        return notNull();
      case 'unique':
        return unique();
      case 'check':
        return check();
      case 'defaultValue':
        return defaultValue();
      case 'foreignKey':
        return foreignKey();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? primaryKey,
    _T Function()? notNull,
    _T Function()? unique,
    _T Function()? check,
    _T Function()? defaultValue,
    _T Function()? foreignKey,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'primaryKey':
        c = primaryKey;
        break;
      case 'notNull':
        c = notNull;
        break;
      case 'unique':
        c = unique;
        break;
      case 'check':
        c = check;
        break;
      case 'defaultValue':
        c = defaultValue;
        break;
      case 'foreignKey':
        c = foreignKey;
        break;
    }
    return (c ?? orElse).call();
  }
}

class ConstraintPrimaryKey extends ConstraintValue {
  final PrimaryKey value;

  const ConstraintPrimaryKey({
    required this.value,
  }) : super._();

  @override
  TypeConstraintValue get typeEnum => TypeConstraintValue.primaryKey;

  ConstraintPrimaryKey copyWith({
    PrimaryKey? value,
  }) {
    return ConstraintPrimaryKey(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ConstraintPrimaryKey) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ConstraintPrimaryKey fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ConstraintPrimaryKey) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ConstraintPrimaryKey(
      value: PrimaryKey.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'primaryKey',
      'value': value.toJson(),
    };
  }
}

class ConstraintNotNull extends ConstraintValue {
  final NotNull value;

  const ConstraintNotNull({
    required this.value,
  }) : super._();

  @override
  TypeConstraintValue get typeEnum => TypeConstraintValue.notNull;

  ConstraintNotNull copyWith({
    NotNull? value,
  }) {
    return ConstraintNotNull(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ConstraintNotNull) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ConstraintNotNull fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ConstraintNotNull) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ConstraintNotNull(
      value: NotNull.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'notNull',
      'value': value.toJson(),
    };
  }
}

class ConstraintUnique extends ConstraintValue {
  final Unique value;

  const ConstraintUnique({
    required this.value,
  }) : super._();

  @override
  TypeConstraintValue get typeEnum => TypeConstraintValue.unique;

  ConstraintUnique copyWith({
    Unique? value,
  }) {
    return ConstraintUnique(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ConstraintUnique) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ConstraintUnique fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ConstraintUnique) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ConstraintUnique(
      value: Unique.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'unique',
      'value': value.toJson(),
    };
  }
}

class ConstraintCheck extends ConstraintValue {
  final String value;

  const ConstraintCheck({
    required this.value,
  }) : super._();

  @override
  TypeConstraintValue get typeEnum => TypeConstraintValue.check;

  ConstraintCheck copyWith({
    String? value,
  }) {
    return ConstraintCheck(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ConstraintCheck) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ConstraintCheck fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ConstraintCheck) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ConstraintCheck(
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'check',
      'value': value,
    };
  }
}

class ConstraintDefaultValue extends ConstraintValue {
  final DefaultValue value;

  const ConstraintDefaultValue({
    required this.value,
  }) : super._();

  @override
  TypeConstraintValue get typeEnum => TypeConstraintValue.defaultValue;

  ConstraintDefaultValue copyWith({
    DefaultValue? value,
  }) {
    return ConstraintDefaultValue(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ConstraintDefaultValue) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ConstraintDefaultValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ConstraintDefaultValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ConstraintDefaultValue(
      value: DefaultValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'defaultValue',
      'value': value.toJson(),
    };
  }
}

class ConstraintForeignKey extends ConstraintValue {
  final ForeignKey value;

  const ConstraintForeignKey({
    required this.value,
  }) : super._();

  @override
  TypeConstraintValue get typeEnum => TypeConstraintValue.foreignKey;

  ConstraintForeignKey copyWith({
    ForeignKey? value,
  }) {
    return ConstraintForeignKey(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ConstraintForeignKey) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ConstraintForeignKey fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ConstraintForeignKey) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ConstraintForeignKey(
      value: ForeignKey.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'foreignKey',
      'value': value.toJson(),
    };
  }
}

class PrimaryKey {
  final PrimaryKeyOrder? order;
  final ConflictClause clause;

  const PrimaryKey({
    required this.clause,
    this.order,
  });

  PrimaryKey copyWith({
    PrimaryKeyOrder? order,
    ConflictClause? clause,
  }) {
    return PrimaryKey(
      clause: clause ?? this.clause,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is PrimaryKey) {
      return this.order == other.order && this.clause == other.clause;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(order, clause);

  static PrimaryKey fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is PrimaryKey) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return PrimaryKey(
      clause: ConflictClause.fromJson(map['clause']),
      order: PrimaryKeyOrder.fromJson(map['order']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order?.toJson(),
      'clause': clause.toJson(),
    };
  }
}

class PrimaryKeyOrder {
  final String _inner;

  const PrimaryKeyOrder(this._inner);

  static const asc = PrimaryKeyOrder('asc');
  static const desc = PrimaryKeyOrder('desc');

  static const values = [
    PrimaryKeyOrder.asc,
    PrimaryKeyOrder.desc,
  ];

  static PrimaryKeyOrder fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      // ignore: unrelated_type_equality_checks
      if (json == v) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other.toString() == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isAsc => this == PrimaryKeyOrder.asc;
  bool get isDesc => this == PrimaryKeyOrder.desc;

  _T when<_T>({
    required _T Function() asc,
    required _T Function() desc,
  }) {
    switch (this._inner) {
      case 'asc':
        return asc();
      case 'desc':
        return desc();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? asc,
    _T Function()? desc,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'asc':
        c = asc;
        break;
      case 'desc':
        c = desc;
        break;
    }
    return (c ?? orElse).call();
  }
}

class NotNull {
  final ConflictClause clause;

  const NotNull({
    required this.clause,
  });

  NotNull copyWith({
    ConflictClause? clause,
  }) {
    return NotNull(
      clause: clause ?? this.clause,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is NotNull) {
      return this.clause == other.clause;
    }
    return false;
  }

  @override
  int get hashCode => clause.hashCode;

  static NotNull fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is NotNull) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return NotNull(
      clause: ConflictClause.fromJson(map['clause']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clause': clause.toJson(),
    };
  }
}

class Unique {
  final ConflictClause clause;

  const Unique({
    required this.clause,
  });

  Unique copyWith({
    ConflictClause? clause,
  }) {
    return Unique(
      clause: clause ?? this.clause,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Unique) {
      return this.clause == other.clause;
    }
    return false;
  }

  @override
  int get hashCode => clause.hashCode;

  static Unique fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Unique) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Unique(
      clause: ConflictClause.fromJson(map['clause']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clause': clause.toJson(),
    };
  }
}

class DefaultValue {
  final Expression value;

  const DefaultValue({
    required this.value,
  });

  DefaultValue copyWith({
    Expression? value,
  }) {
    return DefaultValue(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DefaultValue) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static DefaultValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is DefaultValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return DefaultValue(
      value: Expression.fromJson(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.toJson(),
    };
  }
}

final conflictClause = (stringIgnoreCase('ON').trim() &
        stringIgnoreCase('CONFLICT').trim() &
        (stringIgnoreCase('ROLLBACK').trim() |
                stringIgnoreCase('ABORT').trim() |
                stringIgnoreCase('FAIL').trim() |
                stringIgnoreCase('IGNORE').trim() |
                stringIgnoreCase('REPLACE').trim())
            .trim())
    .trim()
    .optional();

class ConflictClause {
  final ConflictClauseValue value;

  const ConflictClause({
    required this.value,
  });

  ConflictClause copyWith({
    ConflictClauseValue? value,
  }) {
    return ConflictClause(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ConflictClause) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ConflictClause fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ConflictClause) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ConflictClause(
      value: ConflictClauseValue.fromJson(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.toJson(),
    };
  }
}

class ConflictClauseValue {
  final String _inner;

  const ConflictClauseValue(this._inner);

  static const rollback = ConflictClauseValue('rollback');
  static const abort = ConflictClauseValue('abort');
  static const fail = ConflictClauseValue('fail');
  static const ignore = ConflictClauseValue('ignore');
  static const replace = ConflictClauseValue('replace');

  static const values = [
    ConflictClauseValue.rollback,
    ConflictClauseValue.abort,
    ConflictClauseValue.fail,
    ConflictClauseValue.ignore,
    ConflictClauseValue.replace,
  ];

  static ConflictClauseValue fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      // ignore: unrelated_type_equality_checks
      if (json == v) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other.toString() == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isRollback => this == ConflictClauseValue.rollback;
  bool get isAbort => this == ConflictClauseValue.abort;
  bool get isFail => this == ConflictClauseValue.fail;
  bool get isIgnore => this == ConflictClauseValue.ignore;
  bool get isReplace => this == ConflictClauseValue.replace;

  _T when<_T>({
    required _T Function() rollback,
    required _T Function() abort,
    required _T Function() fail,
    required _T Function() ignore,
    required _T Function() replace,
  }) {
    switch (this._inner) {
      case 'rollback':
        return rollback();
      case 'abort':
        return abort();
      case 'fail':
        return fail();
      case 'ignore':
        return ignore();
      case 'replace':
        return replace();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? rollback,
    _T Function()? abort,
    _T Function()? fail,
    _T Function()? ignore,
    _T Function()? replace,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'rollback':
        c = rollback;
        break;
      case 'abort':
        c = abort;
        break;
      case 'fail':
        c = fail;
        break;
      case 'ignore':
        c = ignore;
        break;
      case 'replace':
        c = replace;
        break;
    }
    return (c ?? orElse).call();
  }
}

final foreignKey = (stringIgnoreCase('REFERENCES').trim() &
        identifier.trim() &
        stringIgnoreCase('(').trim() &
        identifier
            .trim()
            .separatedBy(string(',').trim(),
                includeSeparators: false, optionalSeparatorAtEnd: true)
            .trim() &
        stringIgnoreCase(')').trim() &
        foreignKeyChangeClause.trim().repeat(0, 2))
    .trim();

class ForeignKey {
  final String tableName;
  final List<String> columnNames;
  final List<ForeignKeyChangeClause>? changeClauses;

  const ForeignKey({
    required this.tableName,
    required this.columnNames,
    this.changeClauses,
  });

  ForeignKey copyWith({
    String? tableName,
    List<String>? columnNames,
    List<ForeignKeyChangeClause>? changeClauses,
  }) {
    return ForeignKey(
      tableName: tableName ?? this.tableName,
      columnNames: columnNames ?? this.columnNames,
      changeClauses: changeClauses ?? this.changeClauses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ForeignKey) {
      return this.tableName == other.tableName &&
          this.columnNames == other.columnNames &&
          this.changeClauses == other.changeClauses;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(tableName, columnNames, changeClauses);

  static ForeignKey fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ForeignKey) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ForeignKey(
      tableName: map['tableName'] as String,
      columnNames:
          (map['columnNames'] as List).map((e) => e as String).toList(),
      changeClauses: (map['changeClauses'] as List)
          .map((e) => ForeignKeyChangeClause.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableName': tableName,
      'columnNames': columnNames.map((e) => e).toList(),
      'changeClauses': changeClauses?.map((e) => e.toJson()).toList(),
    };
  }
}

final foreignKeyChangeClause = (stringIgnoreCase('ON').trim() &
        (stringIgnoreCase('DELETE').trim() | stringIgnoreCase('UPDATE').trim())
            .trim() &
        ((stringIgnoreCase('SET').trim() & stringIgnoreCase('NULL').trim())
                    .trim() |
                (stringIgnoreCase('SET').trim() &
                        stringIgnoreCase('DEFAULT').trim())
                    .trim() |
                stringIgnoreCase('CASCADE').trim() |
                stringIgnoreCase('RESTRICT').trim() |
                (stringIgnoreCase('NO').trim() &
                        stringIgnoreCase('ACTION').trim())
                    .trim())
            .trim())
    .trim();

class ForeignKeyChangeClause {
  final ForeignKeyChangeClauseType type;
  final ForeignKeyChangeClauseValue value;

  const ForeignKeyChangeClause({
    required this.type,
    required this.value,
  });

  ForeignKeyChangeClause copyWith({
    ForeignKeyChangeClauseType? type,
    ForeignKeyChangeClauseValue? value,
  }) {
    return ForeignKeyChangeClause(
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ForeignKeyChangeClause) {
      return this.type == other.type && this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(type, value);

  static ForeignKeyChangeClause fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ForeignKeyChangeClause) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ForeignKeyChangeClause(
      type: ForeignKeyChangeClauseType.fromJson(map['type']),
      value: ForeignKeyChangeClauseValue.fromJson(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'value': value.toJson(),
    };
  }
}

class ForeignKeyChangeClauseType {
  final String _inner;

  const ForeignKeyChangeClauseType(this._inner);

  static const delete = ForeignKeyChangeClauseType('delete');
  static const update = ForeignKeyChangeClauseType('update');

  static const values = [
    ForeignKeyChangeClauseType.delete,
    ForeignKeyChangeClauseType.update,
  ];

  static ForeignKeyChangeClauseType fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      // ignore: unrelated_type_equality_checks
      if (json == v) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other.toString() == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isDelete => this == ForeignKeyChangeClauseType.delete;
  bool get isUpdate => this == ForeignKeyChangeClauseType.update;

  _T when<_T>({
    required _T Function() delete,
    required _T Function() update,
  }) {
    switch (this._inner) {
      case 'delete':
        return delete();
      case 'update':
        return update();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? delete,
    _T Function()? update,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'delete':
        c = delete;
        break;
      case 'update':
        c = update;
        break;
    }
    return (c ?? orElse).call();
  }
}

abstract class ForeignKeyChangeClauseValue {
  const ForeignKeyChangeClauseValue._();

  const factory ForeignKeyChangeClauseValue.setNull({
    required SetNull value,
  }) = ForeignKeyChangeClauseSetNull;
  const factory ForeignKeyChangeClauseValue.setDefault({
    required SetDefault value,
  }) = ForeignKeyChangeClauseSetDefault;
  const factory ForeignKeyChangeClauseValue.cascade({
    required String value,
  }) = ForeignKeyChangeClauseCascade;
  const factory ForeignKeyChangeClauseValue.restrict({
    required String value,
  }) = ForeignKeyChangeClauseRestrict;
  const factory ForeignKeyChangeClauseValue.noAction({
    required NoAction value,
  }) = ForeignKeyChangeClauseNoAction;

  Object get value;

  _T when<_T>({
    required _T Function(SetNull value) setNull,
    required _T Function(SetDefault value) setDefault,
    required _T Function(String value) cascade,
    required _T Function(String value) restrict,
    required _T Function(NoAction value) noAction,
  }) {
    final v = this;
    if (v is ForeignKeyChangeClauseSetNull) {
      return setNull(v.value);
    } else if (v is ForeignKeyChangeClauseSetDefault) {
      return setDefault(v.value);
    } else if (v is ForeignKeyChangeClauseCascade) {
      return cascade(v.value);
    } else if (v is ForeignKeyChangeClauseRestrict) {
      return restrict(v.value);
    } else if (v is ForeignKeyChangeClauseNoAction) {
      return noAction(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(SetNull value)? setNull,
    _T Function(SetDefault value)? setDefault,
    _T Function(String value)? cascade,
    _T Function(String value)? restrict,
    _T Function(NoAction value)? noAction,
  }) {
    final v = this;
    if (v is ForeignKeyChangeClauseSetNull) {
      return setNull != null ? setNull(v.value) : orElse.call();
    } else if (v is ForeignKeyChangeClauseSetDefault) {
      return setDefault != null ? setDefault(v.value) : orElse.call();
    } else if (v is ForeignKeyChangeClauseCascade) {
      return cascade != null ? cascade(v.value) : orElse.call();
    } else if (v is ForeignKeyChangeClauseRestrict) {
      return restrict != null ? restrict(v.value) : orElse.call();
    } else if (v is ForeignKeyChangeClauseNoAction) {
      return noAction != null ? noAction(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(ForeignKeyChangeClauseSetNull value) setNull,
    required _T Function(ForeignKeyChangeClauseSetDefault value) setDefault,
    required _T Function(ForeignKeyChangeClauseCascade value) cascade,
    required _T Function(ForeignKeyChangeClauseRestrict value) restrict,
    required _T Function(ForeignKeyChangeClauseNoAction value) noAction,
  }) {
    final v = this;
    if (v is ForeignKeyChangeClauseSetNull) {
      return setNull(v);
    } else if (v is ForeignKeyChangeClauseSetDefault) {
      return setDefault(v);
    } else if (v is ForeignKeyChangeClauseCascade) {
      return cascade(v);
    } else if (v is ForeignKeyChangeClauseRestrict) {
      return restrict(v);
    } else if (v is ForeignKeyChangeClauseNoAction) {
      return noAction(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(ForeignKeyChangeClauseSetNull value)? setNull,
    _T Function(ForeignKeyChangeClauseSetDefault value)? setDefault,
    _T Function(ForeignKeyChangeClauseCascade value)? cascade,
    _T Function(ForeignKeyChangeClauseRestrict value)? restrict,
    _T Function(ForeignKeyChangeClauseNoAction value)? noAction,
  }) {
    final v = this;
    if (v is ForeignKeyChangeClauseSetNull) {
      return setNull != null ? setNull(v) : orElse.call();
    } else if (v is ForeignKeyChangeClauseSetDefault) {
      return setDefault != null ? setDefault(v) : orElse.call();
    } else if (v is ForeignKeyChangeClauseCascade) {
      return cascade != null ? cascade(v) : orElse.call();
    } else if (v is ForeignKeyChangeClauseRestrict) {
      return restrict != null ? restrict(v) : orElse.call();
    } else if (v is ForeignKeyChangeClauseNoAction) {
      return noAction != null ? noAction(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isSetNull => this is ForeignKeyChangeClauseSetNull;
  bool get isSetDefault => this is ForeignKeyChangeClauseSetDefault;
  bool get isCascade => this is ForeignKeyChangeClauseCascade;
  bool get isRestrict => this is ForeignKeyChangeClauseRestrict;
  bool get isNoAction => this is ForeignKeyChangeClauseNoAction;

  TypeForeignKeyChangeClauseValue get typeEnum;

  static ForeignKeyChangeClauseValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ForeignKeyChangeClauseValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'setNull':
        return ForeignKeyChangeClauseSetNull.fromJson(map);
      case 'setDefault':
        return ForeignKeyChangeClauseSetDefault.fromJson(map);
      case 'cascade':
        return ForeignKeyChangeClauseCascade.fromJson(map);
      case 'restrict':
        return ForeignKeyChangeClauseRestrict.fromJson(map);
      case 'noAction':
        return ForeignKeyChangeClauseNoAction.fromJson(map);
      default:
        throw Exception(
            'Invalid discriminator for ForeignKeyChangeClauseValue.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class TypeForeignKeyChangeClauseValue {
  final String _inner;

  const TypeForeignKeyChangeClauseValue(this._inner);

  static const setNull = TypeForeignKeyChangeClauseValue('setNull');
  static const setDefault = TypeForeignKeyChangeClauseValue('setDefault');
  static const cascade = TypeForeignKeyChangeClauseValue('cascade');
  static const restrict = TypeForeignKeyChangeClauseValue('restrict');
  static const noAction = TypeForeignKeyChangeClauseValue('noAction');

  static const values = [
    TypeForeignKeyChangeClauseValue.setNull,
    TypeForeignKeyChangeClauseValue.setDefault,
    TypeForeignKeyChangeClauseValue.cascade,
    TypeForeignKeyChangeClauseValue.restrict,
    TypeForeignKeyChangeClauseValue.noAction,
  ];

  static TypeForeignKeyChangeClauseValue fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      // ignore: unrelated_type_equality_checks
      if (json == v) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other.toString() == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isSetNull => this == TypeForeignKeyChangeClauseValue.setNull;
  bool get isSetDefault => this == TypeForeignKeyChangeClauseValue.setDefault;
  bool get isCascade => this == TypeForeignKeyChangeClauseValue.cascade;
  bool get isRestrict => this == TypeForeignKeyChangeClauseValue.restrict;
  bool get isNoAction => this == TypeForeignKeyChangeClauseValue.noAction;

  _T when<_T>({
    required _T Function() setNull,
    required _T Function() setDefault,
    required _T Function() cascade,
    required _T Function() restrict,
    required _T Function() noAction,
  }) {
    switch (this._inner) {
      case 'setNull':
        return setNull();
      case 'setDefault':
        return setDefault();
      case 'cascade':
        return cascade();
      case 'restrict':
        return restrict();
      case 'noAction':
        return noAction();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? setNull,
    _T Function()? setDefault,
    _T Function()? cascade,
    _T Function()? restrict,
    _T Function()? noAction,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'setNull':
        c = setNull;
        break;
      case 'setDefault':
        c = setDefault;
        break;
      case 'cascade':
        c = cascade;
        break;
      case 'restrict':
        c = restrict;
        break;
      case 'noAction':
        c = noAction;
        break;
    }
    return (c ?? orElse).call();
  }
}

class ForeignKeyChangeClauseSetNull extends ForeignKeyChangeClauseValue {
  final SetNull value;

  const ForeignKeyChangeClauseSetNull({
    required this.value,
  }) : super._();

  @override
  TypeForeignKeyChangeClauseValue get typeEnum =>
      TypeForeignKeyChangeClauseValue.setNull;

  ForeignKeyChangeClauseSetNull copyWith({
    SetNull? value,
  }) {
    return ForeignKeyChangeClauseSetNull(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ForeignKeyChangeClauseSetNull) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ForeignKeyChangeClauseSetNull fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ForeignKeyChangeClauseSetNull) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ForeignKeyChangeClauseSetNull(
      value: SetNull.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'setNull',
      'value': value.toJson(),
    };
  }
}

class ForeignKeyChangeClauseSetDefault extends ForeignKeyChangeClauseValue {
  final SetDefault value;

  const ForeignKeyChangeClauseSetDefault({
    required this.value,
  }) : super._();

  @override
  TypeForeignKeyChangeClauseValue get typeEnum =>
      TypeForeignKeyChangeClauseValue.setDefault;

  ForeignKeyChangeClauseSetDefault copyWith({
    SetDefault? value,
  }) {
    return ForeignKeyChangeClauseSetDefault(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ForeignKeyChangeClauseSetDefault) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ForeignKeyChangeClauseSetDefault fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ForeignKeyChangeClauseSetDefault) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ForeignKeyChangeClauseSetDefault(
      value: SetDefault.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'setDefault',
      'value': value.toJson(),
    };
  }
}

class ForeignKeyChangeClauseCascade extends ForeignKeyChangeClauseValue {
  final String value;

  const ForeignKeyChangeClauseCascade({
    required this.value,
  }) : super._();

  @override
  TypeForeignKeyChangeClauseValue get typeEnum =>
      TypeForeignKeyChangeClauseValue.cascade;

  ForeignKeyChangeClauseCascade copyWith({
    String? value,
  }) {
    return ForeignKeyChangeClauseCascade(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ForeignKeyChangeClauseCascade) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ForeignKeyChangeClauseCascade fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ForeignKeyChangeClauseCascade) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ForeignKeyChangeClauseCascade(
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'cascade',
      'value': value,
    };
  }
}

class ForeignKeyChangeClauseRestrict extends ForeignKeyChangeClauseValue {
  final String value;

  const ForeignKeyChangeClauseRestrict({
    required this.value,
  }) : super._();

  @override
  TypeForeignKeyChangeClauseValue get typeEnum =>
      TypeForeignKeyChangeClauseValue.restrict;

  ForeignKeyChangeClauseRestrict copyWith({
    String? value,
  }) {
    return ForeignKeyChangeClauseRestrict(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ForeignKeyChangeClauseRestrict) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ForeignKeyChangeClauseRestrict fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ForeignKeyChangeClauseRestrict) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ForeignKeyChangeClauseRestrict(
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'restrict',
      'value': value,
    };
  }
}

class ForeignKeyChangeClauseNoAction extends ForeignKeyChangeClauseValue {
  final NoAction value;

  const ForeignKeyChangeClauseNoAction({
    required this.value,
  }) : super._();

  @override
  TypeForeignKeyChangeClauseValue get typeEnum =>
      TypeForeignKeyChangeClauseValue.noAction;

  ForeignKeyChangeClauseNoAction copyWith({
    NoAction? value,
  }) {
    return ForeignKeyChangeClauseNoAction(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ForeignKeyChangeClauseNoAction) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ForeignKeyChangeClauseNoAction fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ForeignKeyChangeClauseNoAction) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ForeignKeyChangeClauseNoAction(
      value: NoAction.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'noAction',
      'value': value.toJson(),
    };
  }
}

class SetNull {
  const SetNull();

  SetNull copyWith() {
    return const SetNull();
  }

  @override
  bool operator ==(Object other) {
    if (other is SetNull) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => const SetNull().hashCode;

  static SetNull fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is SetNull) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return const SetNull();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

class SetDefault {
  const SetDefault();

  SetDefault copyWith() {
    return const SetDefault();
  }

  @override
  bool operator ==(Object other) {
    if (other is SetDefault) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => const SetDefault().hashCode;

  static SetDefault fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is SetDefault) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return const SetDefault();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

class NoAction {
  const NoAction();

  NoAction copyWith() {
    return const NoAction();
  }

  @override
  bool operator ==(Object other) {
    if (other is NoAction) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => const NoAction().hashCode;

  static NoAction fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is NoAction) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return const NoAction();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

final expression = ((doubleParser.trim() |
            (string('"').trim() & any.neg().trim() & string('"').trim()).trim())
        .trim())
    .trim();

abstract class Expression {
  const Expression._();

  const factory Expression.number({
    required double value,
  }) = ExpressionNumber;
  const factory Expression.str({
    required Str value,
  }) = ExpressionStr;

  Object get value;

  _T when<_T>({
    required _T Function(double value) number,
    required _T Function(Str value) str,
  }) {
    final v = this;
    if (v is ExpressionNumber) {
      return number(v.value);
    } else if (v is ExpressionStr) {
      return str(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(double value)? number,
    _T Function(Str value)? str,
  }) {
    final v = this;
    if (v is ExpressionNumber) {
      return number != null ? number(v.value) : orElse.call();
    } else if (v is ExpressionStr) {
      return str != null ? str(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(ExpressionNumber value) number,
    required _T Function(ExpressionStr value) str,
  }) {
    final v = this;
    if (v is ExpressionNumber) {
      return number(v);
    } else if (v is ExpressionStr) {
      return str(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(ExpressionNumber value)? number,
    _T Function(ExpressionStr value)? str,
  }) {
    final v = this;
    if (v is ExpressionNumber) {
      return number != null ? number(v) : orElse.call();
    } else if (v is ExpressionStr) {
      return str != null ? str(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isNumber => this is ExpressionNumber;
  bool get isStr => this is ExpressionStr;

  TypeExpression get typeEnum;

  static Expression fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Expression) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'number':
        return ExpressionNumber.fromJson(map);
      case 'str':
        return ExpressionStr.fromJson(map);
      default:
        throw Exception('Invalid discriminator for Expression.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class TypeExpression {
  final String _inner;

  const TypeExpression(this._inner);

  static const number = TypeExpression('number');
  static const str = TypeExpression('str');

  static const values = [
    TypeExpression.number,
    TypeExpression.str,
  ];

  static TypeExpression fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      // ignore: unrelated_type_equality_checks
      if (json == v) {
        return v;
      }
    }
    throw Error();
  }

  String toJson() {
    return _inner;
  }

  @override
  String toString() {
    return _inner;
  }

  @override
  bool operator ==(Object other) {
    return other.toString() == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isNumber => this == TypeExpression.number;
  bool get isStr => this == TypeExpression.str;

  _T when<_T>({
    required _T Function() number,
    required _T Function() str,
  }) {
    switch (this._inner) {
      case 'number':
        return number();
      case 'str':
        return str();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? number,
    _T Function()? str,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'number':
        c = number;
        break;
      case 'str':
        c = str;
        break;
    }
    return (c ?? orElse).call();
  }
}

class ExpressionNumber extends Expression {
  final double value;

  const ExpressionNumber({
    required this.value,
  }) : super._();

  @override
  TypeExpression get typeEnum => TypeExpression.number;

  ExpressionNumber copyWith({
    double? value,
  }) {
    return ExpressionNumber(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ExpressionNumber) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ExpressionNumber fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ExpressionNumber) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ExpressionNumber(
      value: map['value'] as double,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'number',
      'value': value,
    };
  }
}

class ExpressionStr extends Expression {
  final Str value;

  const ExpressionStr({
    required this.value,
  }) : super._();

  @override
  TypeExpression get typeEnum => TypeExpression.str;

  ExpressionStr copyWith({
    Str? value,
  }) {
    return ExpressionStr(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ExpressionStr) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ExpressionStr fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ExpressionStr) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ExpressionStr(
      value: Str.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'str',
      'value': value.toJson(),
    };
  }
}

class Str {
  final String value;

  const Str({
    required this.value,
  });

  Str copyWith({
    String? value,
  }) {
    return Str(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Str) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static Str fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Str) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Str(
      value: map['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

final any = (string('"').neg().trim().star()).flatten().trim();