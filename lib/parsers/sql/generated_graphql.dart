import 'dart:convert';
import 'dart:ui';
import 'package:petitparser/petitparser.dart';

final doubleParser = (char('-').optional() &
        char('0').or(pattern('1-9') & digit().star()) &
        (char('.') & char('0').or(pattern('1-9') & digit().star())).optional())
    .flatten()
    .map((value) => double.parse(value));
final integerParser =
    (char('-').optional() & char('0').or(pattern('1-9') & digit().star()))
        .flatten()
        .map((value) => int.parse(value));

SettableParser<Definition>? _definition;

Parser<Definition> get definition {
  if (_definition != null) {
    return _definition!;
  }
  _definition = undefined();
  final p = (executableDefinition.trim()).map((l) {
    return Definition(
      executable: l as ExecutableDefinition,
    );
  }).trim();
  _definition!.set(p);
  return _definition!;
}

class Definition {
  final ExecutableDefinition executable;

  @override
  String toString() {
    return '${executable} ';
  }

  const Definition({
    required this.executable,
  });

  Definition copyWith({
    ExecutableDefinition? executable,
  }) {
    return Definition(
      executable: executable ?? this.executable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Definition) {
      return this.executable == other.executable;
    }
    return false;
  }

  @override
  int get hashCode => executable.hashCode;

  static Definition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Definition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Definition(
      executable: ExecutableDefinition.fromJson(map['executable']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'executable': executable.toJson(),
    };
  }
}

SettableParser<ExecutableDefinition>? _executableDefinition;

Parser<ExecutableDefinition> get executableDefinition {
  if (_executableDefinition != null) {
    return _executableDefinition!;
  }
  _executableDefinition = undefined();
  final p = (operationDefinition.trim()).map((l) {
    return ExecutableDefinition(
      operation: l as OperationDefinition,
    );
  }).trim();
  _executableDefinition!.set(p);
  return _executableDefinition!;
}

class ExecutableDefinition {
  final OperationDefinition operation;

  @override
  String toString() {
    return '${operation} ';
  }

  const ExecutableDefinition({
    required this.operation,
  });

  ExecutableDefinition copyWith({
    OperationDefinition? operation,
  }) {
    return ExecutableDefinition(
      operation: operation ?? this.operation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ExecutableDefinition) {
      return this.operation == other.operation;
    }
    return false;
  }

  @override
  int get hashCode => operation.hashCode;

  static ExecutableDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ExecutableDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ExecutableDefinition(
      operation: OperationDefinition.fromJson(map['operation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operation': operation.toJson(),
    };
  }
}

SettableParser<OperationDefinition>? _operationDefinition;

Parser<OperationDefinition> get operationDefinition {
  if (_operationDefinition != null) {
    return _operationDefinition!;
  }
  _operationDefinition = undefined();
  final p = ((selectionSet
                  .trim()
                  .map((v) => OperationDefinition.selectionSet(value: v)) |
              ((string('query').trim().map((_) => OpOperationType.query) |
                              string('mutation')
                                  .trim()
                                  .map((_) => OpOperationType.mutation) |
                              string('subscription')
                                  .trim()
                                  .map((_) => OpOperationType.subscription))
                          .cast<OpOperationType>()
                          .trim() &
                      name.trim().optional() &
                      variableDefinitions.trim().optional() &
                      directives.trim().optional() &
                      selectionSet.trim())
                  .map((l) {
                    return Op(
                      operationType: l[0] as OpOperationType,
                      name: l[1] as String?,
                      variableDefinitions: l[2] as String?,
                      directives: l[3] as Directives?,
                      selection: l[4] as SelectionSet,
                    );
                  })
                  .trim()
                  .map((v) => OperationDefinition.op(value: v)))
          .cast<OperationDefinition>()
          .trim())
      .trim();
  _operationDefinition!.set(p);
  return _operationDefinition!;
}

abstract class OperationDefinition {
  const OperationDefinition._();

  @override
  String toString() {
    return value.toString();
  }

  const factory OperationDefinition.selectionSet({
    required SelectionSet value,
  }) = OperationDefinitionSelectionSet;
  const factory OperationDefinition.op({
    required Op value,
  }) = OperationDefinitionOp;

  Object get value;

  _T when<_T>({
    required _T Function(SelectionSet value) selectionSet,
    required _T Function(Op value) op,
  }) {
    final v = this;
    if (v is OperationDefinitionSelectionSet) {
      return selectionSet(v.value);
    } else if (v is OperationDefinitionOp) {
      return op(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(SelectionSet value)? selectionSet,
    _T Function(Op value)? op,
  }) {
    final v = this;
    if (v is OperationDefinitionSelectionSet) {
      return selectionSet != null ? selectionSet(v.value) : orElse.call();
    } else if (v is OperationDefinitionOp) {
      return op != null ? op(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(OperationDefinitionSelectionSet value) selectionSet,
    required _T Function(OperationDefinitionOp value) op,
  }) {
    final v = this;
    if (v is OperationDefinitionSelectionSet) {
      return selectionSet(v);
    } else if (v is OperationDefinitionOp) {
      return op(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(OperationDefinitionSelectionSet value)? selectionSet,
    _T Function(OperationDefinitionOp value)? op,
  }) {
    final v = this;
    if (v is OperationDefinitionSelectionSet) {
      return selectionSet != null ? selectionSet(v) : orElse.call();
    } else if (v is OperationDefinitionOp) {
      return op != null ? op(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isSelectionSet => this is OperationDefinitionSelectionSet;
  bool get isOp => this is OperationDefinitionOp;

  static OperationDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is OperationDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'selectionSet':
        return OperationDefinitionSelectionSet.fromJson(map);
      case 'op':
        return OperationDefinitionOp.fromJson(map);
      default:
        throw Exception(
            'Invalid discriminator for OperationDefinition.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class OperationDefinitionSelectionSet extends OperationDefinition {
  final SelectionSet value;

  const OperationDefinitionSelectionSet({
    required this.value,
  }) : super._();

  OperationDefinitionSelectionSet copyWith({
    SelectionSet? value,
  }) {
    return OperationDefinitionSelectionSet(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is OperationDefinitionSelectionSet) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static OperationDefinitionSelectionSet fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is OperationDefinitionSelectionSet) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return OperationDefinitionSelectionSet(
      value: SelectionSet.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'selectionSet',
      'value': value.toJson(),
    };
  }
}

class OperationDefinitionOp extends OperationDefinition {
  final Op value;

  const OperationDefinitionOp({
    required this.value,
  }) : super._();

  OperationDefinitionOp copyWith({
    Op? value,
  }) {
    return OperationDefinitionOp(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is OperationDefinitionOp) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static OperationDefinitionOp fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is OperationDefinitionOp) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return OperationDefinitionOp(
      value: Op.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'op',
      'value': value.toJson(),
    };
  }
}

class Op {
  final OpOperationType operationType;
  final String? name;
  final String? variableDefinitions;
  final Directives? directives;
  final SelectionSet selection;

  @override
  String toString() {
    return '${operationType} ${name == null ? "" : "${name!}"} ${variableDefinitions == null ? "" : "${variableDefinitions!}"} ${directives == null ? "" : "${directives!}"} ${selection} ';
  }

  const Op({
    required this.operationType,
    required this.selection,
    this.name,
    this.variableDefinitions,
    this.directives,
  });

  Op copyWith({
    OpOperationType? operationType,
    String? name,
    String? variableDefinitions,
    Directives? directives,
    SelectionSet? selection,
  }) {
    return Op(
      operationType: operationType ?? this.operationType,
      selection: selection ?? this.selection,
      name: name ?? this.name,
      variableDefinitions: variableDefinitions ?? this.variableDefinitions,
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Op) {
      return this.operationType == other.operationType &&
          this.name == other.name &&
          this.variableDefinitions == other.variableDefinitions &&
          this.directives == other.directives &&
          this.selection == other.selection;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(
      operationType, name, variableDefinitions, directives, selection);

  static Op fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Op) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Op(
      operationType: OpOperationType.fromJson(map['operationType']),
      selection: SelectionSet.fromJson(map['selection']),
      name: map['name'] as String,
      variableDefinitions: map['variableDefinitions'] as String,
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operationType': operationType.toJson(),
      'name': name,
      'variableDefinitions': variableDefinitions,
      'directives': directives?.toJson(),
      'selection': selection.toJson(),
    };
  }
}

class OpOperationType {
  final String _inner;

  const OpOperationType._(this._inner);

  static const query = OpOperationType._('query');
  static const mutation = OpOperationType._('mutation');
  static const subscription = OpOperationType._('subscription');

  static const values = [
    OpOperationType.query,
    OpOperationType.mutation,
    OpOperationType.subscription,
  ];

  static OpOperationType fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      if (json.toString() == v._inner) {
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
    return other is OpOperationType &&
        other.runtimeType == runtimeType &&
        other._inner == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isQuery => this == OpOperationType.query;
  bool get isMutation => this == OpOperationType.mutation;
  bool get isSubscription => this == OpOperationType.subscription;

  _T when<_T>({
    required _T Function() query,
    required _T Function() mutation,
    required _T Function() subscription,
  }) {
    switch (this._inner) {
      case 'query':
        return query();
      case 'mutation':
        return mutation();
      case 'subscription':
        return subscription();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? query,
    _T Function()? mutation,
    _T Function()? subscription,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'query':
        c = query;
        break;
      case 'mutation':
        c = mutation;
        break;
      case 'subscription':
        c = subscription;
        break;
    }
    return (c ?? orElse).call();
  }
}

SettableParser<SelectionSet>? _selectionSet;

Parser<SelectionSet> get selectionSet {
  if (_selectionSet != null) {
    return _selectionSet!;
  }
  _selectionSet = undefined();
  final p = (char('{').trim() &
          selection
              .trim()
              .separatedBy<Selection>(char(',').trim(),
                  includeSeparators: false, optionalSeparatorAtEnd: true)
              .trim() &
          char('}').trim())
      .map((l) {
    return SelectionSet(
      selection: l[1] as List<Selection>,
    );
  }).trim();
  _selectionSet!.set(p);
  return _selectionSet!;
}

class SelectionSet {
  final List<Selection> selection;

  @override
  String toString() {
    return '{ ${selection.join(',')} } ';
  }

  const SelectionSet({
    required this.selection,
  });

  SelectionSet copyWith({
    List<Selection>? selection,
  }) {
    return SelectionSet(
      selection: selection ?? this.selection,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is SelectionSet) {
      return this.selection == other.selection;
    }
    return false;
  }

  @override
  int get hashCode => selection.hashCode;

  static SelectionSet fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is SelectionSet) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return SelectionSet(
      selection:
          (map['selection'] as List).map((e) => Selection.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selection': selection.map((e) => e.toJson()).toList(),
    };
  }
}

final name = ((letter() | char('_')) & (letter() | digit() | char('_')).star())
    .flatten();

SettableParser<VariableDefinition>? _variableDefinition;

Parser<VariableDefinition> get variableDefinition {
  if (_variableDefinition != null) {
    return _variableDefinition!;
  }
  _variableDefinition = undefined();
  final p = (variable.trim() &
          char(':').trim() &
          type.trim() &
          defaultValue.trim().optional())
      .map((l) {
    return VariableDefinition(
      variable: l[0] as Variable,
      type: l[2] as Type,
      defaultValue: l[3] as DefaultValue?,
    );
  }).trim();
  _variableDefinition!.set(p);
  return _variableDefinition!;
}

class VariableDefinition {
  final Variable variable;
  final Type type;
  final DefaultValue? defaultValue;

  @override
  String toString() {
    return '${variable} : ${type} ${defaultValue == null ? "" : "${defaultValue!}"} ';
  }

  const VariableDefinition({
    required this.variable,
    required this.type,
    this.defaultValue,
  });

  VariableDefinition copyWith({
    Variable? variable,
    Type? type,
    DefaultValue? defaultValue,
  }) {
    return VariableDefinition(
      variable: variable ?? this.variable,
      type: type ?? this.type,
      defaultValue: defaultValue ?? this.defaultValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is VariableDefinition) {
      return this.variable == other.variable &&
          this.type == other.type &&
          this.defaultValue == other.defaultValue;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(variable, type, defaultValue);

  static VariableDefinition fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is VariableDefinition) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return VariableDefinition(
      variable: Variable.fromJson(map['variable']),
      type: Type.fromJson(map['type']),
      defaultValue: map['defaultValue'] == null
          ? null
          : DefaultValue.fromJson(map['defaultValue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variable': variable.toJson(),
      'type': type.toJson(),
      'defaultValue': defaultValue?.toJson(),
    };
  }
}

SettableParser<Type>? _type;

Parser<Type> get type {
  if (_type != null) {
    return _type!;
  }
  _type = undefined();
  final p = ((name.trim().map((v) => TypeValue.named(value: v)) |
                  (char('[').trim() & type.trim() & char(']').trim())
                      .map((l) {
                        return ListType(
                          inner: l[1] as Type,
                        );
                      })
                      .trim()
                      .map((v) => TypeValue.listType(value: v)))
              .cast<TypeValue>()
              .trim() &
          char('!').trim().optional())
      .map((l) {
    return Type(
      value: l[0] as TypeValue,
    );
  }).trim();
  _type!.set(p);
  return _type!;
}

class Type {
  final TypeValue value;

  @override
  String toString() {
    return '${value} ! ';
  }

  const Type({
    required this.value,
  });

  Type copyWith({
    TypeValue? value,
  }) {
    return Type(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Type) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static Type fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Type) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Type(
      value: TypeValue.fromJson(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.toJson(),
    };
  }
}

abstract class TypeValue {
  const TypeValue._();

  @override
  String toString() {
    return value.toString();
  }

  const factory TypeValue.named({
    required String value,
  }) = TypeNamed;
  const factory TypeValue.listType({
    required ListType value,
  }) = TypeListType;

  Object get value;

  _T when<_T>({
    required _T Function(String value) named,
    required _T Function(ListType value) listType,
  }) {
    final v = this;
    if (v is TypeNamed) {
      return named(v.value);
    } else if (v is TypeListType) {
      return listType(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(String value)? named,
    _T Function(ListType value)? listType,
  }) {
    final v = this;
    if (v is TypeNamed) {
      return named != null ? named(v.value) : orElse.call();
    } else if (v is TypeListType) {
      return listType != null ? listType(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(TypeNamed value) named,
    required _T Function(TypeListType value) listType,
  }) {
    final v = this;
    if (v is TypeNamed) {
      return named(v);
    } else if (v is TypeListType) {
      return listType(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(TypeNamed value)? named,
    _T Function(TypeListType value)? listType,
  }) {
    final v = this;
    if (v is TypeNamed) {
      return named != null ? named(v) : orElse.call();
    } else if (v is TypeListType) {
      return listType != null ? listType(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isNamed => this is TypeNamed;
  bool get isListType => this is TypeListType;

  static TypeValue fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeValue) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'named':
        return TypeNamed.fromJson(map);
      case 'listType':
        return TypeListType.fromJson(map);
      default:
        throw Exception('Invalid discriminator for TypeValue.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class TypeNamed extends TypeValue {
  final String value;

  const TypeNamed({
    required this.value,
  }) : super._();

  TypeNamed copyWith({
    String? value,
  }) {
    return TypeNamed(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeNamed) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeNamed fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeNamed) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeNamed(
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'named',
      'value': value,
    };
  }
}

class TypeListType extends TypeValue {
  final ListType value;

  const TypeListType({
    required this.value,
  }) : super._();

  TypeListType copyWith({
    ListType? value,
  }) {
    return TypeListType(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is TypeListType) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static TypeListType fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is TypeListType) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return TypeListType(
      value: ListType.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'listType',
      'value': value.toJson(),
    };
  }
}

class ListType {
  final Type inner;

  @override
  String toString() {
    return '[ ${inner} ] ';
  }

  const ListType({
    required this.inner,
  });

  ListType copyWith({
    Type? inner,
  }) {
    return ListType(
      inner: inner ?? this.inner,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ListType) {
      return this.inner == other.inner;
    }
    return false;
  }

  @override
  int get hashCode => inner.hashCode;

  static ListType fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ListType) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ListType(
      inner: Type.fromJson(map['inner']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inner': inner.toJson(),
    };
  }
}

final defaultValue = (char('=').trim() & value.trim()).map((l) {
  return DefaultValue(
    value: l[1] as Value,
  );
}).trim();

class DefaultValue {
  final Value value;

  @override
  String toString() {
    return '= ${value} ';
  }

  const DefaultValue({
    required this.value,
  });

  DefaultValue copyWith({
    Value? value,
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
      value: Value.fromJson(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.toJson(),
    };
  }
}

final value = ((variable.trim().map((v) => Value.variable(value: v)) |
            doubleParser.trim().map((v) => Value.float(value: v)) |
            integerParser.trim().map((v) => Value.integer(value: v)) |
            boolValue.trim().map((v) => Value.boolean(value: v)) |
            string('null').trim().map((v) => Value.null_(value: v)))
        .cast<Value>()
        .trim())
    .trim();

abstract class Value {
  const Value._();

  @override
  String toString() {
    return value.toString();
  }

  const factory Value.variable({
    required Variable value,
  }) = ValueVariable;
  const factory Value.float({
    required double value,
  }) = ValueFloat;
  const factory Value.integer({
    required int value,
  }) = ValueInteger;
  const factory Value.boolean({
    required BoolValue value,
  }) = ValueBoolean;
  const factory Value.null_({
    required String value,
  }) = ValueNull;

  Object get value;

  _T when<_T>({
    required _T Function(Variable value) variable,
    required _T Function(double value) float,
    required _T Function(int value) integer,
    required _T Function(BoolValue value) boolean,
    required _T Function(String value) null_,
  }) {
    final v = this;
    if (v is ValueVariable) {
      return variable(v.value);
    } else if (v is ValueFloat) {
      return float(v.value);
    } else if (v is ValueInteger) {
      return integer(v.value);
    } else if (v is ValueBoolean) {
      return boolean(v.value);
    } else if (v is ValueNull) {
      return null_(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(Variable value)? variable,
    _T Function(double value)? float,
    _T Function(int value)? integer,
    _T Function(BoolValue value)? boolean,
    _T Function(String value)? null_,
  }) {
    final v = this;
    if (v is ValueVariable) {
      return variable != null ? variable(v.value) : orElse.call();
    } else if (v is ValueFloat) {
      return float != null ? float(v.value) : orElse.call();
    } else if (v is ValueInteger) {
      return integer != null ? integer(v.value) : orElse.call();
    } else if (v is ValueBoolean) {
      return boolean != null ? boolean(v.value) : orElse.call();
    } else if (v is ValueNull) {
      return null_ != null ? null_(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(ValueVariable value) variable,
    required _T Function(ValueFloat value) float,
    required _T Function(ValueInteger value) integer,
    required _T Function(ValueBoolean value) boolean,
    required _T Function(ValueNull value) null_,
  }) {
    final v = this;
    if (v is ValueVariable) {
      return variable(v);
    } else if (v is ValueFloat) {
      return float(v);
    } else if (v is ValueInteger) {
      return integer(v);
    } else if (v is ValueBoolean) {
      return boolean(v);
    } else if (v is ValueNull) {
      return null_(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(ValueVariable value)? variable,
    _T Function(ValueFloat value)? float,
    _T Function(ValueInteger value)? integer,
    _T Function(ValueBoolean value)? boolean,
    _T Function(ValueNull value)? null_,
  }) {
    final v = this;
    if (v is ValueVariable) {
      return variable != null ? variable(v) : orElse.call();
    } else if (v is ValueFloat) {
      return float != null ? float(v) : orElse.call();
    } else if (v is ValueInteger) {
      return integer != null ? integer(v) : orElse.call();
    } else if (v is ValueBoolean) {
      return boolean != null ? boolean(v) : orElse.call();
    } else if (v is ValueNull) {
      return null_ != null ? null_(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isVariable => this is ValueVariable;
  bool get isFloat => this is ValueFloat;
  bool get isInteger => this is ValueInteger;
  bool get isBoolean => this is ValueBoolean;
  bool get isNull => this is ValueNull;

  static Value fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Value) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'variable':
        return ValueVariable.fromJson(map);
      case 'float':
        return ValueFloat.fromJson(map);
      case 'integer':
        return ValueInteger.fromJson(map);
      case 'boolean':
        return ValueBoolean.fromJson(map);
      case 'null':
        return ValueNull.fromJson(map);
      default:
        throw Exception('Invalid discriminator for Value.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class ValueVariable extends Value {
  final Variable value;

  const ValueVariable({
    required this.value,
  }) : super._();

  ValueVariable copyWith({
    Variable? value,
  }) {
    return ValueVariable(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueVariable) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueVariable fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueVariable) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueVariable(
      value: Variable.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'variable',
      'value': value.toJson(),
    };
  }
}

class ValueFloat extends Value {
  final double value;

  const ValueFloat({
    required this.value,
  }) : super._();

  ValueFloat copyWith({
    double? value,
  }) {
    return ValueFloat(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueFloat) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueFloat fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueFloat) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueFloat(
      value: map['value'] as double,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'float',
      'value': value,
    };
  }
}

class ValueInteger extends Value {
  final int value;

  const ValueInteger({
    required this.value,
  }) : super._();

  ValueInteger copyWith({
    int? value,
  }) {
    return ValueInteger(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueInteger) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueInteger fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueInteger) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueInteger(
      value: map['value'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'integer',
      'value': value,
    };
  }
}

class ValueBoolean extends Value {
  final BoolValue value;

  const ValueBoolean({
    required this.value,
  }) : super._();

  ValueBoolean copyWith({
    BoolValue? value,
  }) {
    return ValueBoolean(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueBoolean) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueBoolean fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueBoolean) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueBoolean(
      value: BoolValue.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'boolean',
      'value': value.toJson(),
    };
  }
}

class ValueNull extends Value {
  final String value;

  const ValueNull({
    required this.value,
  }) : super._();

  ValueNull copyWith({
    String? value,
  }) {
    return ValueNull(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is ValueNull) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static ValueNull fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is ValueNull) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return ValueNull(
      value: map['value'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'null',
      'value': value,
    };
  }
}

final variable = (string('\$').trim() & name.trim()).map((l) {
  return Variable(
    name: l[1] as String,
  );
}).trim();

class Variable {
  final String name;

  @override
  String toString() {
    return '\$ ${name} ';
  }

  const Variable({
    required this.name,
  });

  Variable copyWith({
    String? name,
  }) {
    return Variable(
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Variable) {
      return this.name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  static Variable fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Variable) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Variable(
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

final boolValue = ((string('true').map((_) => BoolValue.true_) |
            string('false').map((_) => BoolValue.false_))
        .cast<BoolValue>())
    .trim();

class BoolValue {
  final String _inner;

  const BoolValue._(this._inner);

  static const true_ = BoolValue._('true');
  static const false_ = BoolValue._('false');

  static const values = [
    BoolValue.true_,
    BoolValue.false_,
  ];

  static BoolValue fromJson(Object? json) {
    if (json == null) {
      throw Error();
    }
    for (final v in values) {
      if (json.toString() == v._inner) {
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
    return other is BoolValue &&
        other.runtimeType == runtimeType &&
        other._inner == _inner;
  }

  @override
  int get hashCode => _inner.hashCode;

  bool get isTrue => this == BoolValue.true_;
  bool get isFalse => this == BoolValue.false_;

  _T when<_T>({
    required _T Function() true_,
    required _T Function() false_,
  }) {
    switch (this._inner) {
      case 'true':
        return true_();
      case 'false':
        return false_();
    }
    throw Error();
  }

  _T maybeWhen<_T>({
    _T Function()? true_,
    _T Function()? false_,
    required _T Function() orElse,
  }) {
    _T Function()? c;
    switch (this._inner) {
      case 'true':
        c = true_;
        break;
      case 'false':
        c = false_;
        break;
    }
    return (c ?? orElse).call();
  }
}

SettableParser<String>? _variableDefinitions;

Parser<String> get variableDefinitions {
  if (_variableDefinitions != null) {
    return _variableDefinitions!;
  }
  _variableDefinitions = undefined();
  final p = (char('(').trim() &
          variableDefinition
              .trim()
              .separatedBy<VariableDefinition>(char(',').trim(),
                  includeSeparators: false, optionalSeparatorAtEnd: true)
              .trim() &
          char(')').trim())
      .flatten()
      .trim();
  _variableDefinitions!.set(p);
  return _variableDefinitions!;
}

SettableParser<Selection>? _selection;

Parser<Selection> get selection {
  if (_selection != null) {
    return _selection!;
  }
  _selection = undefined();
  final p = ((field.trim().map((v) => Selection.field(value: v)) |
              fragmentSpread
                  .trim()
                  .map((v) => Selection.fragmentSpread(value: v)))
          .cast<Selection>()
          .trim())
      .trim();
  _selection!.set(p);
  return _selection!;
}

abstract class Selection {
  const Selection._();

  @override
  String toString() {
    return value.toString();
  }

  const factory Selection.field({
    required Field value,
  }) = SelectionField;
  const factory Selection.fragmentSpread({
    required FragmentSpread value,
  }) = SelectionFragmentSpread;

  Object get value;

  _T when<_T>({
    required _T Function(Field value) field,
    required _T Function(FragmentSpread value) fragmentSpread,
  }) {
    final v = this;
    if (v is SelectionField) {
      return field(v.value);
    } else if (v is SelectionFragmentSpread) {
      return fragmentSpread(v.value);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(Field value)? field,
    _T Function(FragmentSpread value)? fragmentSpread,
  }) {
    final v = this;
    if (v is SelectionField) {
      return field != null ? field(v.value) : orElse.call();
    } else if (v is SelectionFragmentSpread) {
      return fragmentSpread != null ? fragmentSpread(v.value) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(SelectionField value) field,
    required _T Function(SelectionFragmentSpread value) fragmentSpread,
  }) {
    final v = this;
    if (v is SelectionField) {
      return field(v);
    } else if (v is SelectionFragmentSpread) {
      return fragmentSpread(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(SelectionField value)? field,
    _T Function(SelectionFragmentSpread value)? fragmentSpread,
  }) {
    final v = this;
    if (v is SelectionField) {
      return field != null ? field(v) : orElse.call();
    } else if (v is SelectionFragmentSpread) {
      return fragmentSpread != null ? fragmentSpread(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isField => this is SelectionField;
  bool get isFragmentSpread => this is SelectionFragmentSpread;

  static Selection fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Selection) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    switch (map['runtimeType'] as String) {
      case 'field':
        return SelectionField.fromJson(map);
      case 'fragmentSpread':
        return SelectionFragmentSpread.fromJson(map);
      default:
        throw Exception('Invalid discriminator for Selection.fromJson '
            '${map["runtimeType"]}. Input map: $map');
    }
  }

  Map<String, dynamic> toJson();
}

class SelectionField extends Selection {
  final Field value;

  const SelectionField({
    required this.value,
  }) : super._();

  SelectionField copyWith({
    Field? value,
  }) {
    return SelectionField(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is SelectionField) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static SelectionField fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is SelectionField) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return SelectionField(
      value: Field.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'field',
      'value': value.toJson(),
    };
  }
}

class SelectionFragmentSpread extends Selection {
  final FragmentSpread value;

  const SelectionFragmentSpread({
    required this.value,
  }) : super._();

  SelectionFragmentSpread copyWith({
    FragmentSpread? value,
  }) {
    return SelectionFragmentSpread(
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is SelectionFragmentSpread) {
      return this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;

  static SelectionFragmentSpread fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is SelectionFragmentSpread) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return SelectionFragmentSpread(
      value: FragmentSpread.fromJson(map['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'runtimeType': 'fragmentSpread',
      'value': value.toJson(),
    };
  }
}

SettableParser<Field>? _field;

Parser<Field> get field {
  if (_field != null) {
    return _field!;
  }
  _field = undefined();
  final p = (alias.trim().optional() &
          name.trim() &
          arguments.trim().optional() &
          directives.trim().optional() &
          selectionSet.trim().optional())
      .map((l) {
    return Field(
      alias: l[0] as Alias?,
      name: l[1] as String,
      arguments: l[2] as Arguments?,
      directives: l[3] as Directives?,
      selectionSet: l[4] as SelectionSet?,
    );
  }).trim();
  _field!.set(p);
  return _field!;
}

class Field {
  final Alias? alias;
  final String name;
  final Arguments? arguments;
  final Directives? directives;
  final SelectionSet? selectionSet;

  @override
  String toString() {
    return '${alias == null ? "" : "${alias!}"} ${name} ${arguments == null ? "" : "${arguments!}"} ${directives == null ? "" : "${directives!}"} ${selectionSet == null ? "" : "${selectionSet!}"} ';
  }

  const Field({
    required this.name,
    this.alias,
    this.arguments,
    this.directives,
    this.selectionSet,
  });

  Field copyWith({
    Alias? alias,
    String? name,
    Arguments? arguments,
    Directives? directives,
    SelectionSet? selectionSet,
  }) {
    return Field(
      name: name ?? this.name,
      alias: alias ?? this.alias,
      arguments: arguments ?? this.arguments,
      directives: directives ?? this.directives,
      selectionSet: selectionSet ?? this.selectionSet,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Field) {
      return this.alias == other.alias &&
          this.name == other.name &&
          this.arguments == other.arguments &&
          this.directives == other.directives &&
          this.selectionSet == other.selectionSet;
    }
    return false;
  }

  @override
  int get hashCode =>
      hashValues(alias, name, arguments, directives, selectionSet);

  static Field fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Field) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Field(
      name: map['name'] as String,
      alias: map['alias'] == null ? null : Alias.fromJson(map['alias']),
      arguments: map['arguments'] == null
          ? null
          : Arguments.fromJson(map['arguments']),
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
      selectionSet: map['selectionSet'] == null
          ? null
          : SelectionSet.fromJson(map['selectionSet']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alias': alias?.toJson(),
      'name': name,
      'arguments': arguments?.toJson(),
      'directives': directives?.toJson(),
      'selectionSet': selectionSet?.toJson(),
    };
  }
}

SettableParser<FragmentSpread>? _fragmentSpread;

Parser<FragmentSpread> get fragmentSpread {
  if (_fragmentSpread != null) {
    return _fragmentSpread!;
  }
  _fragmentSpread = undefined();
  final p = (string('...').trim() & name.trim() & directives.trim().optional())
      .map((l) {
    return FragmentSpread(
      name: l[1] as String,
      directives: l[2] as Directives?,
    );
  }).trim();
  _fragmentSpread!.set(p);
  return _fragmentSpread!;
}

class FragmentSpread {
  final String name;
  final Directives? directives;

  @override
  String toString() {
    return '... ${name} ${directives == null ? "" : "${directives!}"} ';
  }

  const FragmentSpread({
    required this.name,
    this.directives,
  });

  FragmentSpread copyWith({
    String? name,
    Directives? directives,
  }) {
    return FragmentSpread(
      name: name ?? this.name,
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is FragmentSpread) {
      return this.name == other.name && this.directives == other.directives;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(name, directives);

  static FragmentSpread fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is FragmentSpread) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return FragmentSpread(
      name: map['name'] as String,
      directives: map['directives'] == null
          ? null
          : Directives.fromJson(map['directives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'directives': directives?.toJson(),
    };
  }
}

SettableParser<Directives>? _directives;

Parser<Directives> get directives {
  if (_directives != null) {
    return _directives!;
  }
  _directives = undefined();
  final p = (directive
          .trim()
          .separatedBy<Directive>(char(',').trim(),
              includeSeparators: false, optionalSeparatorAtEnd: true)
          .trim())
      .map((l) {
    return Directives(
      directives: l as List<Directive>,
    );
  }).trim();
  _directives!.set(p);
  return _directives!;
}

class Directives {
  final List<Directive> directives;

  @override
  String toString() {
    return '${directives.join(',')} ';
  }

  const Directives({
    required this.directives,
  });

  Directives copyWith({
    List<Directive>? directives,
  }) {
    return Directives(
      directives: directives ?? this.directives,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Directives) {
      return this.directives == other.directives;
    }
    return false;
  }

  @override
  int get hashCode => directives.hashCode;

  static Directives fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Directives) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Directives(
      directives: (map['directives'] as List)
          .map((e) => Directive.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'directives': directives.map((e) => e.toJson()).toList(),
    };
  }
}

SettableParser<Directive>? _directive;

Parser<Directive> get directive {
  if (_directive != null) {
    return _directive!;
  }
  _directive = undefined();
  final p =
      (char('@').trim() & name.trim() & arguments.trim().optional()).map((l) {
    return Directive(
      name: l[1] as String,
      arguments: l[2] as Arguments?,
    );
  }).trim();
  _directive!.set(p);
  return _directive!;
}

class Directive {
  final String name;
  final Arguments? arguments;

  @override
  String toString() {
    return '@ ${name} ${arguments == null ? "" : "${arguments!}"} ';
  }

  const Directive({
    required this.name,
    this.arguments,
  });

  Directive copyWith({
    String? name,
    Arguments? arguments,
  }) {
    return Directive(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Directive) {
      return this.name == other.name && this.arguments == other.arguments;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(name, arguments);

  static Directive fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Directive) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Directive(
      name: map['name'] as String,
      arguments: map['arguments'] == null
          ? null
          : Arguments.fromJson(map['arguments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'arguments': arguments?.toJson(),
    };
  }
}

SettableParser<Arguments>? _arguments;

Parser<Arguments> get arguments {
  if (_arguments != null) {
    return _arguments!;
  }
  _arguments = undefined();
  final p = (char('(').trim() &
          argument
              .trim()
              .separatedBy<Argument>(char(',').trim(),
                  includeSeparators: false, optionalSeparatorAtEnd: true)
              .trim() &
          char(')').trim())
      .map((l) {
    return Arguments(
      arguments: l[1] as List<Argument>,
    );
  }).trim();
  _arguments!.set(p);
  return _arguments!;
}

class Arguments {
  final List<Argument> arguments;

  @override
  String toString() {
    return '( ${arguments.join(',')} ) ';
  }

  const Arguments({
    required this.arguments,
  });

  Arguments copyWith({
    List<Argument>? arguments,
  }) {
    return Arguments(
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Arguments) {
      return this.arguments == other.arguments;
    }
    return false;
  }

  @override
  int get hashCode => arguments.hashCode;

  static Arguments fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Arguments) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Arguments(
      arguments:
          (map['arguments'] as List).map((e) => Argument.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arguments': arguments.map((e) => e.toJson()).toList(),
    };
  }
}

SettableParser<Argument>? _argument;

Parser<Argument> get argument {
  if (_argument != null) {
    return _argument!;
  }
  _argument = undefined();
  final p = (name.trim() & char(':').trim() & value.trim()).map((l) {
    return Argument(
      name: l[0] as String,
      value: l[2] as Value,
    );
  }).trim();
  _argument!.set(p);
  return _argument!;
}

class Argument {
  final String name;
  final Value value;

  @override
  String toString() {
    return '${name} : ${value} ';
  }

  const Argument({
    required this.name,
    required this.value,
  });

  Argument copyWith({
    String? name,
    Value? value,
  }) {
    return Argument(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Argument) {
      return this.name == other.name && this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(name, value);

  static Argument fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Argument) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Argument(
      name: map['name'] as String,
      value: Value.fromJson(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value.toJson(),
    };
  }
}

final alias = (name.trim() & char(':').trim()).map((l) {
  return Alias(
    name: l[0] as String,
  );
});

class Alias {
  final String name;

  @override
  String toString() {
    return '${name} : ';
  }

  const Alias({
    required this.name,
  });

  Alias copyWith({
    String? name,
  }) {
    return Alias(
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Alias) {
      return this.name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  static Alias fromJson(Object? _map) {
    final Map<String, dynamic> map;
    if (_map is Alias) {
      return _map;
    } else if (_map is String) {
      map = jsonDecode(_map) as Map<String, dynamic>;
    } else {
      map = (_map! as Map).cast();
    }

    return Alias(
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

void main() {
  final r = definition.parse('''
  { de: d3s (cc : 2, ll : \$s, cc: -1.3) @ fef }
  
  ''');

  print(r);

  const f = Definition(
    executable: ExecutableDefinition(
      operation: OperationDefinition.op(
        value: Op(
          operationType: OpOperationType.subscription,
          name: 'de',
          selection: SelectionSet(
            selection: [
              Selection.field(
                value: Field(
                  name: 'name',
                  arguments: Arguments(
                    arguments: [
                      Argument(
                        name: 'vvv',
                        value: Value.boolean(
                          value: BoolValue.true_,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Selection.fragmentSpread(
                value: FragmentSpread(
                  name: 'da',
                  directives: Directives(
                    directives: [
                      Directive(name: 'da')
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
  print(f);
}
