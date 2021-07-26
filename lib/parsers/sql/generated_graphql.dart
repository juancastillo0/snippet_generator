// import 'dart:convert';
// import 'dart:ui';
// import 'package:petitparser/petitparser.dart';

// extension ButNotParser<T> on Parser<T> {
//   Parser<T> butNot(Parser not) {
//     return this.and().seq(not.end().not()).pick(0).cast();
//   }
// }

// final doubleParser = (char('-').optional() &
//         char('0').or(pattern('1-9') & digit().star()) &
//         (char('.') & char('0').or(pattern('1-9') & digit().star())).optional())
//     .flatten()
//     .map((value) => double.parse(value));
// final integerParser =
//     (char('-').optional() & char('0').or(pattern('1-9') & digit().star()))
//         .flatten()
//         .map((value) => int.parse(value));

// final definition =
//     ((executableDefinition.trim().map((v) => Definition.executable(value: v)) |
//                 typeSystemDefinition
//                     .trim()
//                     .map((v) => Definition.typeSystem(value: v)))
//             .cast<Definition>()
//             .trim())
//         .trim();

// abstract class Definition {
//   const Definition._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory Definition.executable({
//     required ExecutableDefinition value,
//   }) = DefinitionExecutable;
//   const factory Definition.typeSystem({
//     required TypeSystemDefinition value,
//   }) = DefinitionTypeSystem;

//   Object get value;

//   _T when<_T>({
//     required _T Function(ExecutableDefinition value) executable,
//     required _T Function(TypeSystemDefinition value) typeSystem,
//   }) {
//     final v = this;
//     if (v is DefinitionExecutable) {
//       return executable(v.value);
//     } else if (v is DefinitionTypeSystem) {
//       return typeSystem(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(ExecutableDefinition value)? executable,
//     _T Function(TypeSystemDefinition value)? typeSystem,
//   }) {
//     final v = this;
//     if (v is DefinitionExecutable) {
//       return executable != null ? executable(v.value) : orElse.call();
//     } else if (v is DefinitionTypeSystem) {
//       return typeSystem != null ? typeSystem(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(DefinitionExecutable value) executable,
//     required _T Function(DefinitionTypeSystem value) typeSystem,
//   }) {
//     final v = this;
//     if (v is DefinitionExecutable) {
//       return executable(v);
//     } else if (v is DefinitionTypeSystem) {
//       return typeSystem(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(DefinitionExecutable value)? executable,
//     _T Function(DefinitionTypeSystem value)? typeSystem,
//   }) {
//     final v = this;
//     if (v is DefinitionExecutable) {
//       return executable != null ? executable(v) : orElse.call();
//     } else if (v is DefinitionTypeSystem) {
//       return typeSystem != null ? typeSystem(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isExecutable => this is DefinitionExecutable;
//   bool get isTypeSystem => this is DefinitionTypeSystem;

//   static Definition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Definition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'executable':
//         return DefinitionExecutable.fromJson(map);
//       case 'typeSystem':
//         return DefinitionTypeSystem.fromJson(map);
//       default:
//         throw Exception('Invalid discriminator for Definition.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class DefinitionExecutable extends Definition {
//   final ExecutableDefinition value;

//   const DefinitionExecutable({
//     required this.value,
//   }) : super._();

//   DefinitionExecutable copyWith({
//     ExecutableDefinition? value,
//   }) {
//     return DefinitionExecutable(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is DefinitionExecutable) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static DefinitionExecutable fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is DefinitionExecutable) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return DefinitionExecutable(
//       value: ExecutableDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'executable',
//       'value': value.toJson(),
//     };
//   }
// }

// class DefinitionTypeSystem extends Definition {
//   final TypeSystemDefinition value;

//   const DefinitionTypeSystem({
//     required this.value,
//   }) : super._();

//   DefinitionTypeSystem copyWith({
//     TypeSystemDefinition? value,
//   }) {
//     return DefinitionTypeSystem(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is DefinitionTypeSystem) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static DefinitionTypeSystem fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is DefinitionTypeSystem) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return DefinitionTypeSystem(
//       value: TypeSystemDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'typeSystem',
//       'value': value.toJson(),
//     };
//   }
// }

// final executableDefinition = ((operationDefinition
//                 .trim()
//                 .map((v) => ExecutableDefinition.operation(value: v)) |
//             fragmentDefinition
//                 .trim()
//                 .map((v) => ExecutableDefinition.fragment(value: v)))
//         .cast<ExecutableDefinition>()
//         .trim())
//     .trim();

// abstract class ExecutableDefinition {
//   const ExecutableDefinition._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory ExecutableDefinition.operation({
//     required OperationDefinition value,
//   }) = ExecutableDefinitionOperation;
//   const factory ExecutableDefinition.fragment({
//     required FragmentDefinition value,
//   }) = ExecutableDefinitionFragment;

//   Object get value;

//   _T when<_T>({
//     required _T Function(OperationDefinition value) operation,
//     required _T Function(FragmentDefinition value) fragment,
//   }) {
//     final v = this;
//     if (v is ExecutableDefinitionOperation) {
//       return operation(v.value);
//     } else if (v is ExecutableDefinitionFragment) {
//       return fragment(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(OperationDefinition value)? operation,
//     _T Function(FragmentDefinition value)? fragment,
//   }) {
//     final v = this;
//     if (v is ExecutableDefinitionOperation) {
//       return operation != null ? operation(v.value) : orElse.call();
//     } else if (v is ExecutableDefinitionFragment) {
//       return fragment != null ? fragment(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(ExecutableDefinitionOperation value) operation,
//     required _T Function(ExecutableDefinitionFragment value) fragment,
//   }) {
//     final v = this;
//     if (v is ExecutableDefinitionOperation) {
//       return operation(v);
//     } else if (v is ExecutableDefinitionFragment) {
//       return fragment(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(ExecutableDefinitionOperation value)? operation,
//     _T Function(ExecutableDefinitionFragment value)? fragment,
//   }) {
//     final v = this;
//     if (v is ExecutableDefinitionOperation) {
//       return operation != null ? operation(v) : orElse.call();
//     } else if (v is ExecutableDefinitionFragment) {
//       return fragment != null ? fragment(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isOperation => this is ExecutableDefinitionOperation;
//   bool get isFragment => this is ExecutableDefinitionFragment;

//   static ExecutableDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ExecutableDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'operation':
//         return ExecutableDefinitionOperation.fromJson(map);
//       case 'fragment':
//         return ExecutableDefinitionFragment.fromJson(map);
//       default:
//         throw Exception(
//             'Invalid discriminator for ExecutableDefinition.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class ExecutableDefinitionOperation extends ExecutableDefinition {
//   final OperationDefinition value;

//   const ExecutableDefinitionOperation({
//     required this.value,
//   }) : super._();

//   ExecutableDefinitionOperation copyWith({
//     OperationDefinition? value,
//   }) {
//     return ExecutableDefinitionOperation(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ExecutableDefinitionOperation) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static ExecutableDefinitionOperation fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ExecutableDefinitionOperation) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ExecutableDefinitionOperation(
//       value: OperationDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'operation',
//       'value': value.toJson(),
//     };
//   }
// }

// class ExecutableDefinitionFragment extends ExecutableDefinition {
//   final FragmentDefinition value;

//   const ExecutableDefinitionFragment({
//     required this.value,
//   }) : super._();

//   ExecutableDefinitionFragment copyWith({
//     FragmentDefinition? value,
//   }) {
//     return ExecutableDefinitionFragment(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ExecutableDefinitionFragment) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static ExecutableDefinitionFragment fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ExecutableDefinitionFragment) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ExecutableDefinitionFragment(
//       value: FragmentDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'fragment',
//       'value': value.toJson(),
//     };
//   }
// }

// final operationDefinition = ((selectionSet
//                 .trim()
//                 .map((v) => OperationDefinition.selectionSet(value: v)) |
//             (operationType.trim() &
//                     name.trim().optional() &
//                     variableDefinitions.trim().optional() &
//                     directives.trim().optional() &
//                     selectionSet.trim())
//                 .map((l) {
//                   return Op(
//                     type: l[0] as OperationType,
//                     name: l[1] as String?,
//                     variableDefinitions: l[2] as String?,
//                     directives: l[3] as Directives?,
//                     selection: l[4] as SelectionSet,
//                   );
//                 })
//                 .trim()
//                 .map((v) => OperationDefinition.op(value: v)))
//         .cast<OperationDefinition>()
//         .trim())
//     .trim();

// abstract class OperationDefinition {
//   const OperationDefinition._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory OperationDefinition.selectionSet({
//     required SelectionSet value,
//   }) = OperationDefinitionSelectionSet;
//   const factory OperationDefinition.op({
//     required Op value,
//   }) = OperationDefinitionOp;

//   Object get value;

//   _T when<_T>({
//     required _T Function(SelectionSet value) selectionSet,
//     required _T Function(Op value) op,
//   }) {
//     final v = this;
//     if (v is OperationDefinitionSelectionSet) {
//       return selectionSet(v.value);
//     } else if (v is OperationDefinitionOp) {
//       return op(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(SelectionSet value)? selectionSet,
//     _T Function(Op value)? op,
//   }) {
//     final v = this;
//     if (v is OperationDefinitionSelectionSet) {
//       return selectionSet != null ? selectionSet(v.value) : orElse.call();
//     } else if (v is OperationDefinitionOp) {
//       return op != null ? op(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(OperationDefinitionSelectionSet value) selectionSet,
//     required _T Function(OperationDefinitionOp value) op,
//   }) {
//     final v = this;
//     if (v is OperationDefinitionSelectionSet) {
//       return selectionSet(v);
//     } else if (v is OperationDefinitionOp) {
//       return op(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(OperationDefinitionSelectionSet value)? selectionSet,
//     _T Function(OperationDefinitionOp value)? op,
//   }) {
//     final v = this;
//     if (v is OperationDefinitionSelectionSet) {
//       return selectionSet != null ? selectionSet(v) : orElse.call();
//     } else if (v is OperationDefinitionOp) {
//       return op != null ? op(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isSelectionSet => this is OperationDefinitionSelectionSet;
//   bool get isOp => this is OperationDefinitionOp;

//   static OperationDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is OperationDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'selectionSet':
//         return OperationDefinitionSelectionSet.fromJson(map);
//       case 'op':
//         return OperationDefinitionOp.fromJson(map);
//       default:
//         throw Exception(
//             'Invalid discriminator for OperationDefinition.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class OperationDefinitionSelectionSet extends OperationDefinition {
//   final SelectionSet value;

//   const OperationDefinitionSelectionSet({
//     required this.value,
//   }) : super._();

//   OperationDefinitionSelectionSet copyWith({
//     SelectionSet? value,
//   }) {
//     return OperationDefinitionSelectionSet(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is OperationDefinitionSelectionSet) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static OperationDefinitionSelectionSet fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is OperationDefinitionSelectionSet) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return OperationDefinitionSelectionSet(
//       value: SelectionSet.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'selectionSet',
//       'value': value.toJson(),
//     };
//   }
// }

// class OperationDefinitionOp extends OperationDefinition {
//   final Op value;

//   const OperationDefinitionOp({
//     required this.value,
//   }) : super._();

//   OperationDefinitionOp copyWith({
//     Op? value,
//   }) {
//     return OperationDefinitionOp(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is OperationDefinitionOp) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static OperationDefinitionOp fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is OperationDefinitionOp) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return OperationDefinitionOp(
//       value: Op.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'op',
//       'value': value.toJson(),
//     };
//   }
// }

// class Op {
//   final OperationType type;
//   final String? name;
//   final String? variableDefinitions;
//   final Directives? directives;
//   final SelectionSet selection;

//   @override
//   String toString() {
//     return '${type} ${name == null ? "" : "${name!}"} ${variableDefinitions == null ? "" : "${variableDefinitions!}"} ${directives == null ? "" : "${directives!}"} ${selection} ';
//   }

//   const Op({
//     required this.type,
//     required this.selection,
//     this.name,
//     this.variableDefinitions,
//     this.directives,
//   });

//   Op copyWith({
//     OperationType? type,
//     String? name,
//     String? variableDefinitions,
//     Directives? directives,
//     SelectionSet? selection,
//   }) {
//     return Op(
//       type: type ?? this.type,
//       selection: selection ?? this.selection,
//       name: name ?? this.name,
//       variableDefinitions: variableDefinitions ?? this.variableDefinitions,
//       directives: directives ?? this.directives,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Op) {
//       return this.type == other.type &&
//           this.name == other.name &&
//           this.variableDefinitions == other.variableDefinitions &&
//           this.directives == other.directives &&
//           this.selection == other.selection;
//     }
//     return false;
//   }

//   @override
//   int get hashCode =>
//       hashValues(type, name, variableDefinitions, directives, selection);

//   static Op fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Op) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Op(
//       type: OperationType.fromJson(map['type']),
//       selection: SelectionSet.fromJson(map['selection']),
//       name: map['name'] as String,
//       variableDefinitions: map['variableDefinitions'] as String,
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'type': type.toJson(),
//       'name': name,
//       'variableDefinitions': variableDefinitions,
//       'directives': directives?.toJson(),
//       'selection': selection.toJson(),
//     };
//   }
// }

// SettableParser<SelectionSet>? _selectionSet;

// Parser<SelectionSet> get selectionSet {
//   if (_selectionSet != null) {
//     return _selectionSet!;
//   }
//   _selectionSet = undefined();
//   final p = (char('{').trim() &
//           selection
//               .trim()
//               .separatedBy<Selection>(char(',').trim(),
//                   includeSeparators: false, optionalSeparatorAtEnd: true)
//               .trim() &
//           char('}').trim())
//       .map((l) {
//     return SelectionSet(
//       selection: l[1] as List<Selection>,
//     );
//   }).trim();
//   _selectionSet!.set(p);
//   return _selectionSet!;
// }

// class SelectionSet {
//   final List<Selection> selection;

//   @override
//   String toString() {
//     return '{ ${selection.join(',')} } ';
//   }

//   const SelectionSet({
//     required this.selection,
//   });

//   SelectionSet copyWith({
//     List<Selection>? selection,
//   }) {
//     return SelectionSet(
//       selection: selection ?? this.selection,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is SelectionSet) {
//       return this.selection == other.selection;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => selection.hashCode;

//   static SelectionSet fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is SelectionSet) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return SelectionSet(
//       selection:
//           (map['selection'] as List).map((e) => Selection.fromJson(e)).toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'selection': selection.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// final name = ((letter() | char('_')) & (letter() | digit() | char('_')).star())
//     .flatten();

// final variableDefinition = (variable.trim() &
//         char(':').trim() &
//         type.trim() &
//         defaultValue.trim().optional())
//     .map((l) {
//   return VariableDefinition(
//     variable: l[0] as Variable,
//     type: l[2] as Type,
//     defaultValue: l[3] as DefaultValue?,
//   );
// }).trim();

// class VariableDefinition {
//   final Variable variable;
//   final Type type;
//   final DefaultValue? defaultValue;

//   @override
//   String toString() {
//     return '${variable} : ${type} ${defaultValue == null ? "" : "${defaultValue!}"} ';
//   }

//   const VariableDefinition({
//     required this.variable,
//     required this.type,
//     this.defaultValue,
//   });

//   VariableDefinition copyWith({
//     Variable? variable,
//     Type? type,
//     DefaultValue? defaultValue,
//   }) {
//     return VariableDefinition(
//       variable: variable ?? this.variable,
//       type: type ?? this.type,
//       defaultValue: defaultValue ?? this.defaultValue,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is VariableDefinition) {
//       return this.variable == other.variable &&
//           this.type == other.type &&
//           this.defaultValue == other.defaultValue;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(variable, type, defaultValue);

//   static VariableDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is VariableDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return VariableDefinition(
//       variable: Variable.fromJson(map['variable']),
//       type: Type.fromJson(map['type']),
//       defaultValue: map['defaultValue'] == null
//           ? null
//           : DefaultValue.fromJson(map['defaultValue']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'variable': variable.toJson(),
//       'type': type.toJson(),
//       'defaultValue': defaultValue?.toJson(),
//     };
//   }
// }

// SettableParser<Type>? _type;

// Parser<Type> get type {
//   if (_type != null) {
//     return _type!;
//   }
//   _type = undefined();
//   final p = ((name.trim().map((v) => TypeValue.named(value: v)) |
//                   (char('[').trim() & type.trim() & char(']').trim())
//                       .map((l) {
//                         return ListType(
//                           inner: l[1] as Type,
//                         );
//                       })
//                       .trim()
//                       .map((v) => TypeValue.listType(value: v)))
//               .cast<TypeValue>()
//               .trim() &
//           char('!').trim().optional())
//       .map((l) {
//     return Type(
//       value: l[0] as TypeValue,
//     );
//   }).trim();
//   _type!.set(p);
//   return _type!;
// }

// class Type {
//   final TypeValue value;

//   @override
//   String toString() {
//     return '${value} ! ';
//   }

//   const Type({
//     required this.value,
//   });

//   Type copyWith({
//     TypeValue? value,
//   }) {
//     return Type(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Type) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static Type fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Type) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Type(
//       value: TypeValue.fromJson(map['value']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'value': value.toJson(),
//     };
//   }
// }

// abstract class TypeValue {
//   const TypeValue._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory TypeValue.named({
//     required String value,
//   }) = TypeNamed;
//   const factory TypeValue.listType({
//     required ListType value,
//   }) = TypeListType;

//   Object get value;

//   _T when<_T>({
//     required _T Function(String value) named,
//     required _T Function(ListType value) listType,
//   }) {
//     final v = this;
//     if (v is TypeNamed) {
//       return named(v.value);
//     } else if (v is TypeListType) {
//       return listType(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(String value)? named,
//     _T Function(ListType value)? listType,
//   }) {
//     final v = this;
//     if (v is TypeNamed) {
//       return named != null ? named(v.value) : orElse.call();
//     } else if (v is TypeListType) {
//       return listType != null ? listType(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(TypeNamed value) named,
//     required _T Function(TypeListType value) listType,
//   }) {
//     final v = this;
//     if (v is TypeNamed) {
//       return named(v);
//     } else if (v is TypeListType) {
//       return listType(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(TypeNamed value)? named,
//     _T Function(TypeListType value)? listType,
//   }) {
//     final v = this;
//     if (v is TypeNamed) {
//       return named != null ? named(v) : orElse.call();
//     } else if (v is TypeListType) {
//       return listType != null ? listType(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isNamed => this is TypeNamed;
//   bool get isListType => this is TypeListType;

//   static TypeValue fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeValue) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'named':
//         return TypeNamed.fromJson(map);
//       case 'listType':
//         return TypeListType.fromJson(map);
//       default:
//         throw Exception('Invalid discriminator for TypeValue.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class TypeNamed extends TypeValue {
//   final String value;

//   const TypeNamed({
//     required this.value,
//   }) : super._();

//   TypeNamed copyWith({
//     String? value,
//   }) {
//     return TypeNamed(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeNamed) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static TypeNamed fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeNamed) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeNamed(
//       value: map['value'] as String,
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'named',
//       'value': value,
//     };
//   }
// }

// class TypeListType extends TypeValue {
//   final ListType value;

//   const TypeListType({
//     required this.value,
//   }) : super._();

//   TypeListType copyWith({
//     ListType? value,
//   }) {
//     return TypeListType(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeListType) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static TypeListType fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeListType) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeListType(
//       value: ListType.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'listType',
//       'value': value.toJson(),
//     };
//   }
// }

// class ListType {
//   final Type inner;

//   @override
//   String toString() {
//     return '[ ${inner} ] ';
//   }

//   const ListType({
//     required this.inner,
//   });

//   ListType copyWith({
//     Type? inner,
//   }) {
//     return ListType(
//       inner: inner ?? this.inner,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ListType) {
//       return this.inner == other.inner;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => inner.hashCode;

//   static ListType fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ListType) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ListType(
//       inner: Type.fromJson(map['inner']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'inner': inner.toJson(),
//     };
//   }
// }

// final defaultValue = (char('=').trim() & value.trim()).map((l) {
//   return DefaultValue(
//     value: l[1] as Value,
//   );
// }).trim();

// class DefaultValue {
//   final Value value;

//   @override
//   String toString() {
//     return '= ${value} ';
//   }

//   const DefaultValue({
//     required this.value,
//   });

//   DefaultValue copyWith({
//     Value? value,
//   }) {
//     return DefaultValue(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is DefaultValue) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static DefaultValue fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is DefaultValue) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return DefaultValue(
//       value: Value.fromJson(map['value']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'value': value.toJson(),
//     };
//   }
// }

// SettableParser<Value>? _value;

// Parser<Value> get value {
//   if (_value != null) {
//     return _value!;
//   }
//   _value = undefined();
//   final p = ((variable.trim().map((v) => Value.variable(value: v)) |
//               doubleParser.trim().map((v) => Value.float(value: v)) |
//               integerParser.trim().map((v) => Value.integer(value: v)) |
//               boolValue.trim().map((v) => Value.boolean(value: v)) |
//               string('null').trim().map((v) => Value.null_(value: v)) |
//               name.trim().map((v) => Value.enumValue(value: v)) |
//               (char('[').trim() &
//                       value
//                           .trim()
//                           .separatedBy<Value>(char(',').trim(),
//                               includeSeparators: false,
//                               optionalSeparatorAtEnd: true)
//                           .trim() &
//                       char(']').trim())
//                   .map((l) {
//                     return ListValue(
//                       values: l[1] as List<Value>,
//                     );
//                   })
//                   .trim()
//                   .map((v) => Value.listValue(value: v)) |
//               (char('{').trim() &
//                       argument
//                           .trim()
//                           .separatedBy<Argument>(char(',').trim(),
//                               includeSeparators: false,
//                               optionalSeparatorAtEnd: true)
//                           .trim() &
//                       char('}').trim())
//                   .map((l) {
//                     return ObjectValue(
//                       values: l[1] as List<Argument>,
//                     );
//                   })
//                   .trim()
//                   .map((v) => Value.objectValue(value: v)))
//           .cast<Value>()
//           .trim())
//       .trim();
//   _value!.set(p);
//   return _value!;
// }

// abstract class Value {
//   const Value._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory Value.variable({
//     required Variable value,
//   }) = ValueVariable;
//   const factory Value.float({
//     required double value,
//   }) = ValueFloat;
//   const factory Value.integer({
//     required int value,
//   }) = ValueInteger;
//   const factory Value.boolean({
//     required BoolValue value,
//   }) = ValueBoolean;
//   const factory Value.null_({
//     required String value,
//   }) = ValueNull;
//   const factory Value.enumValue({
//     required String value,
//   }) = ValueEnumValue;
//   const factory Value.listValue({
//     required ListValue value,
//   }) = ValueListValue;
//   const factory Value.objectValue({
//     required ObjectValue value,
//   }) = ValueObjectValue;

//   Object get value;

//   _T when<_T>({
//     required _T Function(Variable value) variable,
//     required _T Function(double value) float,
//     required _T Function(int value) integer,
//     required _T Function(BoolValue value) boolean,
//     required _T Function(String value) null_,
//     required _T Function(String value) enumValue,
//     required _T Function(ListValue value) listValue,
//     required _T Function(ObjectValue value) objectValue,
//   }) {
//     final v = this;
//     if (v is ValueVariable) {
//       return variable(v.value);
//     } else if (v is ValueFloat) {
//       return float(v.value);
//     } else if (v is ValueInteger) {
//       return integer(v.value);
//     } else if (v is ValueBoolean) {
//       return boolean(v.value);
//     } else if (v is ValueNull) {
//       return null_(v.value);
//     } else if (v is ValueEnumValue) {
//       return enumValue(v.value);
//     } else if (v is ValueListValue) {
//       return listValue(v.value);
//     } else if (v is ValueObjectValue) {
//       return objectValue(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(Variable value)? variable,
//     _T Function(double value)? float,
//     _T Function(int value)? integer,
//     _T Function(BoolValue value)? boolean,
//     _T Function(String value)? null_,
//     _T Function(String value)? enumValue,
//     _T Function(ListValue value)? listValue,
//     _T Function(ObjectValue value)? objectValue,
//   }) {
//     final v = this;
//     if (v is ValueVariable) {
//       return variable != null ? variable(v.value) : orElse.call();
//     } else if (v is ValueFloat) {
//       return float != null ? float(v.value) : orElse.call();
//     } else if (v is ValueInteger) {
//       return integer != null ? integer(v.value) : orElse.call();
//     } else if (v is ValueBoolean) {
//       return boolean != null ? boolean(v.value) : orElse.call();
//     } else if (v is ValueNull) {
//       return null_ != null ? null_(v.value) : orElse.call();
//     } else if (v is ValueEnumValue) {
//       return enumValue != null ? enumValue(v.value) : orElse.call();
//     } else if (v is ValueListValue) {
//       return listValue != null ? listValue(v.value) : orElse.call();
//     } else if (v is ValueObjectValue) {
//       return objectValue != null ? objectValue(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(ValueVariable value) variable,
//     required _T Function(ValueFloat value) float,
//     required _T Function(ValueInteger value) integer,
//     required _T Function(ValueBoolean value) boolean,
//     required _T Function(ValueNull value) null_,
//     required _T Function(ValueEnumValue value) enumValue,
//     required _T Function(ValueListValue value) listValue,
//     required _T Function(ValueObjectValue value) objectValue,
//   }) {
//     final v = this;
//     if (v is ValueVariable) {
//       return variable(v);
//     } else if (v is ValueFloat) {
//       return float(v);
//     } else if (v is ValueInteger) {
//       return integer(v);
//     } else if (v is ValueBoolean) {
//       return boolean(v);
//     } else if (v is ValueNull) {
//       return null_(v);
//     } else if (v is ValueEnumValue) {
//       return enumValue(v);
//     } else if (v is ValueListValue) {
//       return listValue(v);
//     } else if (v is ValueObjectValue) {
//       return objectValue(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(ValueVariable value)? variable,
//     _T Function(ValueFloat value)? float,
//     _T Function(ValueInteger value)? integer,
//     _T Function(ValueBoolean value)? boolean,
//     _T Function(ValueNull value)? null_,
//     _T Function(ValueEnumValue value)? enumValue,
//     _T Function(ValueListValue value)? listValue,
//     _T Function(ValueObjectValue value)? objectValue,
//   }) {
//     final v = this;
//     if (v is ValueVariable) {
//       return variable != null ? variable(v) : orElse.call();
//     } else if (v is ValueFloat) {
//       return float != null ? float(v) : orElse.call();
//     } else if (v is ValueInteger) {
//       return integer != null ? integer(v) : orElse.call();
//     } else if (v is ValueBoolean) {
//       return boolean != null ? boolean(v) : orElse.call();
//     } else if (v is ValueNull) {
//       return null_ != null ? null_(v) : orElse.call();
//     } else if (v is ValueEnumValue) {
//       return enumValue != null ? enumValue(v) : orElse.call();
//     } else if (v is ValueListValue) {
//       return listValue != null ? listValue(v) : orElse.call();
//     } else if (v is ValueObjectValue) {
//       return objectValue != null ? objectValue(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isVariable => this is ValueVariable;
//   bool get isFloat => this is ValueFloat;
//   bool get isInteger => this is ValueInteger;
//   bool get isBoolean => this is ValueBoolean;
//   bool get isNull => this is ValueNull;
//   bool get isEnumValue => this is ValueEnumValue;
//   bool get isListValue => this is ValueListValue;
//   bool get isObjectValue => this is ValueObjectValue;

//   static Value fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Value) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'variable':
//         return ValueVariable.fromJson(map);
//       case 'float':
//         return ValueFloat.fromJson(map);
//       case 'integer':
//         return ValueInteger.fromJson(map);
//       case 'boolean':
//         return ValueBoolean.fromJson(map);
//       case 'null':
//         return ValueNull.fromJson(map);
//       case 'enumValue':
//         return ValueEnumValue.fromJson(map);
//       case 'listValue':
//         return ValueListValue.fromJson(map);
//       case 'objectValue':
//         return ValueObjectValue.fromJson(map);
//       default:
//         throw Exception('Invalid discriminator for Value.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class ValueVariable extends Value {
//   final Variable value;

//   const ValueVariable({
//     required this.value,
//   }) : super._();

//   ValueVariable copyWith({
//     Variable? value,
//   }) {
//     return ValueVariable(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ValueVariable) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static ValueVariable fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ValueVariable) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ValueVariable(
//       value: Variable.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'variable',
//       'value': value.toJson(),
//     };
//   }
// }

// class ValueFloat extends Value {
//   final double value;

//   const ValueFloat({
//     required this.value,
//   }) : super._();

//   ValueFloat copyWith({
//     double? value,
//   }) {
//     return ValueFloat(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ValueFloat) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static ValueFloat fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ValueFloat) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ValueFloat(
//       value: map['value'] as double,
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'float',
//       'value': value,
//     };
//   }
// }

// class ValueInteger extends Value {
//   final int value;

//   const ValueInteger({
//     required this.value,
//   }) : super._();

//   ValueInteger copyWith({
//     int? value,
//   }) {
//     return ValueInteger(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ValueInteger) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static ValueInteger fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ValueInteger) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ValueInteger(
//       value: map['value'] as int,
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'integer',
//       'value': value,
//     };
//   }
// }

// class ValueBoolean extends Value {
//   final BoolValue value;

//   const ValueBoolean({
//     required this.value,
//   }) : super._();

//   ValueBoolean copyWith({
//     BoolValue? value,
//   }) {
//     return ValueBoolean(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ValueBoolean) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static ValueBoolean fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ValueBoolean) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ValueBoolean(
//       value: BoolValue.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'boolean',
//       'value': value.toJson(),
//     };
//   }
// }

// class ValueNull extends Value {
//   final String value;

//   const ValueNull({
//     required this.value,
//   }) : super._();

//   ValueNull copyWith({
//     String? value,
//   }) {
//     return ValueNull(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ValueNull) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static ValueNull fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ValueNull) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ValueNull(
//       value: map['value'] as String,
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'null',
//       'value': value,
//     };
//   }
// }

// class ValueEnumValue extends Value {
//   final String value;

//   const ValueEnumValue({
//     required this.value,
//   }) : super._();

//   ValueEnumValue copyWith({
//     String? value,
//   }) {
//     return ValueEnumValue(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ValueEnumValue) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static ValueEnumValue fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ValueEnumValue) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ValueEnumValue(
//       value: map['value'] as String,
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'enumValue',
//       'value': value,
//     };
//   }
// }

// class ValueListValue extends Value {
//   final ListValue value;

//   const ValueListValue({
//     required this.value,
//   }) : super._();

//   ValueListValue copyWith({
//     ListValue? value,
//   }) {
//     return ValueListValue(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ValueListValue) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static ValueListValue fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ValueListValue) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ValueListValue(
//       value: ListValue.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'listValue',
//       'value': value.toJson(),
//     };
//   }
// }

// class ValueObjectValue extends Value {
//   final ObjectValue value;

//   const ValueObjectValue({
//     required this.value,
//   }) : super._();

//   ValueObjectValue copyWith({
//     ObjectValue? value,
//   }) {
//     return ValueObjectValue(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ValueObjectValue) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static ValueObjectValue fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ValueObjectValue) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ValueObjectValue(
//       value: ObjectValue.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'objectValue',
//       'value': value.toJson(),
//     };
//   }
// }

// class ListValue {
//   final List<Value> values;

//   @override
//   String toString() {
//     return '[ ${values.join(',')} ] ';
//   }

//   const ListValue({
//     required this.values,
//   });

//   ListValue copyWith({
//     List<Value>? values,
//   }) {
//     return ListValue(
//       values: values ?? this.values,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ListValue) {
//       return this.values == other.values;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => values.hashCode;

//   static ListValue fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ListValue) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ListValue(
//       values: (map['values'] as List).map((e) => Value.fromJson(e)).toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'values': values.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// class ObjectValue {
//   final List<Argument> values;

//   @override
//   String toString() {
//     return '{ ${values.join(',')} } ';
//   }

//   const ObjectValue({
//     required this.values,
//   });

//   ObjectValue copyWith({
//     List<Argument>? values,
//   }) {
//     return ObjectValue(
//       values: values ?? this.values,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ObjectValue) {
//       return this.values == other.values;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => values.hashCode;

//   static ObjectValue fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ObjectValue) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ObjectValue(
//       values: (map['values'] as List).map((e) => Argument.fromJson(e)).toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'values': values.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// final variable = (string('\$').trim() & name.trim()).map((l) {
//   return Variable(
//     name: l[1] as String,
//   );
// }).trim();

// class Variable {
//   final String name;

//   @override
//   String toString() {
//     return '\$ ${name} ';
//   }

//   const Variable({
//     required this.name,
//   });

//   Variable copyWith({
//     String? name,
//   }) {
//     return Variable(
//       name: name ?? this.name,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Variable) {
//       return this.name == other.name;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => name.hashCode;

//   static Variable fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Variable) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Variable(
//       name: map['name'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//     };
//   }
// }

// final boolValue = ((string('true').map((_) => BoolValue.true_) |
//             string('false').map((_) => BoolValue.false_))
//         .cast<BoolValue>())
//     .trim();

// class BoolValue {
//   final String _inner;

//   const BoolValue._(this._inner);

//   static const true_ = BoolValue._('true');
//   static const false_ = BoolValue._('false');

//   static const values = [
//     BoolValue.true_,
//     BoolValue.false_,
//   ];

//   static BoolValue fromJson(Object? json) {
//     if (json == null) {
//       throw Error();
//     }
//     for (final v in values) {
//       if (json.toString() == v._inner) {
//         return v;
//       }
//     }
//     throw Error();
//   }

//   String toJson() {
//     return _inner;
//   }

//   @override
//   String toString() {
//     return _inner;
//   }

//   @override
//   bool operator ==(Object other) {
//     return other is BoolValue &&
//         other.runtimeType == runtimeType &&
//         other._inner == _inner;
//   }

//   @override
//   int get hashCode => _inner.hashCode;

//   bool get isTrue_ => this == BoolValue.true_;
//   bool get isFalse_ => this == BoolValue.false_;

//   _T when<_T>({
//     required _T Function() true_,
//     required _T Function() false_,
//   }) {
//     switch (this._inner) {
//       case 'true':
//         return true_();
//       case 'false':
//         return false_();
//     }
//     throw Error();
//   }

//   _T maybeWhen<_T>({
//     _T Function()? true_,
//     _T Function()? false_,
//     required _T Function() orElse,
//   }) {
//     _T Function()? c;
//     switch (this._inner) {
//       case 'true':
//         c = true_;
//         break;
//       case 'false':
//         c = false_;
//         break;
//     }
//     return (c ?? orElse).call();
//   }
// }

// final variableDefinitions = (char('(').trim() &
//         variableDefinition
//             .trim()
//             .separatedBy<VariableDefinition>(char(',').trim(),
//                 includeSeparators: false, optionalSeparatorAtEnd: true)
//             .trim() &
//         char(')').trim())
//     .flatten()
//     .trim();

// SettableParser<Selection>? _selection;

// Parser<Selection> get selection {
//   if (_selection != null) {
//     return _selection!;
//   }
//   _selection = undefined();
//   final p = ((field.trim().map((v) => Selection.field(value: v)) |
//               fragmentSpread
//                   .trim()
//                   .map((v) => Selection.fragmentSpread(value: v)) |
//               inlineFragment
//                   .trim()
//                   .map((v) => Selection.inlineFragment(value: v)))
//           .cast<Selection>()
//           .trim())
//       .trim();
//   _selection!.set(p);
//   return _selection!;
// }

// abstract class Selection {
//   const Selection._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory Selection.field({
//     required Field value,
//   }) = SelectionField;
//   const factory Selection.fragmentSpread({
//     required FragmentSpread value,
//   }) = SelectionFragmentSpread;
//   const factory Selection.inlineFragment({
//     required InlineFragment value,
//   }) = SelectionInlineFragment;

//   Object get value;

//   _T when<_T>({
//     required _T Function(Field value) field,
//     required _T Function(FragmentSpread value) fragmentSpread,
//     required _T Function(InlineFragment value) inlineFragment,
//   }) {
//     final v = this;
//     if (v is SelectionField) {
//       return field(v.value);
//     } else if (v is SelectionFragmentSpread) {
//       return fragmentSpread(v.value);
//     } else if (v is SelectionInlineFragment) {
//       return inlineFragment(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(Field value)? field,
//     _T Function(FragmentSpread value)? fragmentSpread,
//     _T Function(InlineFragment value)? inlineFragment,
//   }) {
//     final v = this;
//     if (v is SelectionField) {
//       return field != null ? field(v.value) : orElse.call();
//     } else if (v is SelectionFragmentSpread) {
//       return fragmentSpread != null ? fragmentSpread(v.value) : orElse.call();
//     } else if (v is SelectionInlineFragment) {
//       return inlineFragment != null ? inlineFragment(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(SelectionField value) field,
//     required _T Function(SelectionFragmentSpread value) fragmentSpread,
//     required _T Function(SelectionInlineFragment value) inlineFragment,
//   }) {
//     final v = this;
//     if (v is SelectionField) {
//       return field(v);
//     } else if (v is SelectionFragmentSpread) {
//       return fragmentSpread(v);
//     } else if (v is SelectionInlineFragment) {
//       return inlineFragment(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(SelectionField value)? field,
//     _T Function(SelectionFragmentSpread value)? fragmentSpread,
//     _T Function(SelectionInlineFragment value)? inlineFragment,
//   }) {
//     final v = this;
//     if (v is SelectionField) {
//       return field != null ? field(v) : orElse.call();
//     } else if (v is SelectionFragmentSpread) {
//       return fragmentSpread != null ? fragmentSpread(v) : orElse.call();
//     } else if (v is SelectionInlineFragment) {
//       return inlineFragment != null ? inlineFragment(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isField => this is SelectionField;
//   bool get isFragmentSpread => this is SelectionFragmentSpread;
//   bool get isInlineFragment => this is SelectionInlineFragment;

//   static Selection fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Selection) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'field':
//         return SelectionField.fromJson(map);
//       case 'fragmentSpread':
//         return SelectionFragmentSpread.fromJson(map);
//       case 'inlineFragment':
//         return SelectionInlineFragment.fromJson(map);
//       default:
//         throw Exception('Invalid discriminator for Selection.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class SelectionField extends Selection {
//   final Field value;

//   const SelectionField({
//     required this.value,
//   }) : super._();

//   SelectionField copyWith({
//     Field? value,
//   }) {
//     return SelectionField(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is SelectionField) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static SelectionField fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is SelectionField) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return SelectionField(
//       value: Field.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'field',
//       'value': value.toJson(),
//     };
//   }
// }

// class SelectionFragmentSpread extends Selection {
//   final FragmentSpread value;

//   const SelectionFragmentSpread({
//     required this.value,
//   }) : super._();

//   SelectionFragmentSpread copyWith({
//     FragmentSpread? value,
//   }) {
//     return SelectionFragmentSpread(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is SelectionFragmentSpread) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static SelectionFragmentSpread fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is SelectionFragmentSpread) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return SelectionFragmentSpread(
//       value: FragmentSpread.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'fragmentSpread',
//       'value': value.toJson(),
//     };
//   }
// }

// class SelectionInlineFragment extends Selection {
//   final InlineFragment value;

//   const SelectionInlineFragment({
//     required this.value,
//   }) : super._();

//   SelectionInlineFragment copyWith({
//     InlineFragment? value,
//   }) {
//     return SelectionInlineFragment(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is SelectionInlineFragment) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static SelectionInlineFragment fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is SelectionInlineFragment) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return SelectionInlineFragment(
//       value: InlineFragment.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'inlineFragment',
//       'value': value.toJson(),
//     };
//   }
// }

// SettableParser<Field>? _field;

// Parser<Field> get field {
//   if (_field != null) {
//     return _field!;
//   }
//   _field = undefined();
//   final p = (alias.trim().optional() &
//           name.trim() &
//           arguments.trim().optional() &
//           directives.trim().optional() &
//           selectionSet.trim().optional())
//       .map((l) {
//     return Field(
//       alias: l[0] as Alias?,
//       name: l[1] as String,
//       arguments: l[2] as Arguments?,
//       directives: l[3] as Directives?,
//       selectionSet: l[4] as SelectionSet?,
//     );
//   }).trim();
//   _field!.set(p);
//   return _field!;
// }

// class Field {
//   final Alias? alias;
//   final String name;
//   final Arguments? arguments;
//   final Directives? directives;
//   final SelectionSet? selectionSet;

//   @override
//   String toString() {
//     return '${alias == null ? "" : "${alias!}"} ${name} ${arguments == null ? "" : "${arguments!}"} ${directives == null ? "" : "${directives!}"} ${selectionSet == null ? "" : "${selectionSet!}"} ';
//   }

//   const Field({
//     required this.name,
//     this.alias,
//     this.arguments,
//     this.directives,
//     this.selectionSet,
//   });

//   Field copyWith({
//     Alias? alias,
//     String? name,
//     Arguments? arguments,
//     Directives? directives,
//     SelectionSet? selectionSet,
//   }) {
//     return Field(
//       name: name ?? this.name,
//       alias: alias ?? this.alias,
//       arguments: arguments ?? this.arguments,
//       directives: directives ?? this.directives,
//       selectionSet: selectionSet ?? this.selectionSet,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Field) {
//       return this.alias == other.alias &&
//           this.name == other.name &&
//           this.arguments == other.arguments &&
//           this.directives == other.directives &&
//           this.selectionSet == other.selectionSet;
//     }
//     return false;
//   }

//   @override
//   int get hashCode =>
//       hashValues(alias, name, arguments, directives, selectionSet);

//   static Field fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Field) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Field(
//       name: map['name'] as String,
//       alias: map['alias'] == null ? null : Alias.fromJson(map['alias']),
//       arguments: map['arguments'] == null
//           ? null
//           : Arguments.fromJson(map['arguments']),
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//       selectionSet: map['selectionSet'] == null
//           ? null
//           : SelectionSet.fromJson(map['selectionSet']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'alias': alias?.toJson(),
//       'name': name,
//       'arguments': arguments?.toJson(),
//       'directives': directives?.toJson(),
//       'selectionSet': selectionSet?.toJson(),
//     };
//   }
// }

// final fragmentSpread =
//     (string('...').trim() & name.trim() & directives.trim().optional())
//         .map((l) {
//   return FragmentSpread(
//     name: l[1] as String,
//     directives: l[2] as Directives?,
//   );
// }).trim();

// class FragmentSpread {
//   final String name;
//   final Directives? directives;

//   @override
//   String toString() {
//     return '... ${name} ${directives == null ? "" : "${directives!}"} ';
//   }

//   const FragmentSpread({
//     required this.name,
//     this.directives,
//   });

//   FragmentSpread copyWith({
//     String? name,
//     Directives? directives,
//   }) {
//     return FragmentSpread(
//       name: name ?? this.name,
//       directives: directives ?? this.directives,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is FragmentSpread) {
//       return this.name == other.name && this.directives == other.directives;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, directives);

//   static FragmentSpread fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is FragmentSpread) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return FragmentSpread(
//       name: map['name'] as String,
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'directives': directives?.toJson(),
//     };
//   }
// }

// final directives = (directive
//         .trim()
//         .separatedBy<Directive>(char(',').trim(),
//             includeSeparators: false, optionalSeparatorAtEnd: true)
//         .trim())
//     .map((l) {
//   return Directives(
//     directives: l as List<Directive>,
//   );
// }).trim();

// class Directives {
//   final List<Directive> directives;

//   @override
//   String toString() {
//     return '${directives.join(',')} ';
//   }

//   const Directives({
//     required this.directives,
//   });

//   Directives copyWith({
//     List<Directive>? directives,
//   }) {
//     return Directives(
//       directives: directives ?? this.directives,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Directives) {
//       return this.directives == other.directives;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => directives.hashCode;

//   static Directives fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Directives) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Directives(
//       directives: (map['directives'] as List)
//           .map((e) => Directive.fromJson(e))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'directives': directives.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// final directive =
//     (char('@').trim() & name.trim() & arguments.trim().optional()).map((l) {
//   return Directive(
//     name: l[1] as String,
//     arguments: l[2] as Arguments?,
//   );
// }).trim();

// class Directive {
//   final String name;
//   final Arguments? arguments;

//   @override
//   String toString() {
//     return '@ ${name} ${arguments == null ? "" : "${arguments!}"} ';
//   }

//   const Directive({
//     required this.name,
//     this.arguments,
//   });

//   Directive copyWith({
//     String? name,
//     Arguments? arguments,
//   }) {
//     return Directive(
//       name: name ?? this.name,
//       arguments: arguments ?? this.arguments,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Directive) {
//       return this.name == other.name && this.arguments == other.arguments;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, arguments);

//   static Directive fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Directive) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Directive(
//       name: map['name'] as String,
//       arguments: map['arguments'] == null
//           ? null
//           : Arguments.fromJson(map['arguments']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'arguments': arguments?.toJson(),
//     };
//   }
// }

// final arguments = (char('(').trim() &
//         argument
//             .trim()
//             .separatedBy<Argument>(char(',').trim(),
//                 includeSeparators: false, optionalSeparatorAtEnd: true)
//             .trim() &
//         char(')').trim())
//     .map((l) {
//   return Arguments(
//     arguments: l[1] as List<Argument>,
//   );
// }).trim();

// class Arguments {
//   final List<Argument> arguments;

//   @override
//   String toString() {
//     return '( ${arguments.join(',')} ) ';
//   }

//   const Arguments({
//     required this.arguments,
//   });

//   Arguments copyWith({
//     List<Argument>? arguments,
//   }) {
//     return Arguments(
//       arguments: arguments ?? this.arguments,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Arguments) {
//       return this.arguments == other.arguments;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => arguments.hashCode;

//   static Arguments fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Arguments) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Arguments(
//       arguments:
//           (map['arguments'] as List).map((e) => Argument.fromJson(e)).toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'arguments': arguments.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// SettableParser<Argument>? _argument;

// Parser<Argument> get argument {
//   if (_argument != null) {
//     return _argument!;
//   }
//   _argument = undefined();
//   final p = (name.trim() & char(':').trim() & value.trim()).map((l) {
//     return Argument(
//       name: l[0] as String,
//       value: l[2] as Value,
//     );
//   }).trim();
//   _argument!.set(p);
//   return _argument!;
// }

// class Argument {
//   final String name;
//   final Value value;

//   @override
//   String toString() {
//     return '${name} : ${value} ';
//   }

//   const Argument({
//     required this.name,
//     required this.value,
//   });

//   Argument copyWith({
//     String? name,
//     Value? value,
//   }) {
//     return Argument(
//       name: name ?? this.name,
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Argument) {
//       return this.name == other.name && this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, value);

//   static Argument fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Argument) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Argument(
//       name: map['name'] as String,
//       value: Value.fromJson(map['value']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'value': value.toJson(),
//     };
//   }
// }

// final alias = (name.trim() & char(':').trim()).map((l) {
//   return Alias(
//     name: l[0] as String,
//   );
// });

// class Alias {
//   final String name;

//   @override
//   String toString() {
//     return '${name} : ';
//   }

//   const Alias({
//     required this.name,
//   });

//   Alias copyWith({
//     String? name,
//   }) {
//     return Alias(
//       name: name ?? this.name,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Alias) {
//       return this.name == other.name;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => name.hashCode;

//   static Alias fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Alias) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Alias(
//       name: map['name'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//     };
//   }
// }

// final fragmentDefinition = (string('fragment').trim() &
//         name.trim() &
//         typeCondition.trim() &
//         directives.trim().optional() &
//         selectionSet.trim())
//     .map((l) {
//   return FragmentDefinition(
//     name: l[1] as String,
//     condition: l[2] as TypeCondition,
//     directives: l[3] as Directives?,
//     selection: l[4] as SelectionSet,
//   );
// }).trim();

// class FragmentDefinition {
//   final String name;
//   final TypeCondition condition;
//   final Directives? directives;
//   final SelectionSet selection;

//   @override
//   String toString() {
//     return 'fragment ${name} ${condition} ${directives == null ? "" : "${directives!}"} ${selection} ';
//   }

//   const FragmentDefinition({
//     required this.name,
//     required this.condition,
//     required this.selection,
//     this.directives,
//   });

//   FragmentDefinition copyWith({
//     String? name,
//     TypeCondition? condition,
//     Directives? directives,
//     SelectionSet? selection,
//   }) {
//     return FragmentDefinition(
//       name: name ?? this.name,
//       condition: condition ?? this.condition,
//       selection: selection ?? this.selection,
//       directives: directives ?? this.directives,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is FragmentDefinition) {
//       return this.name == other.name &&
//           this.condition == other.condition &&
//           this.directives == other.directives &&
//           this.selection == other.selection;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, condition, directives, selection);

//   static FragmentDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is FragmentDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return FragmentDefinition(
//       name: map['name'] as String,
//       condition: TypeCondition.fromJson(map['condition']),
//       selection: SelectionSet.fromJson(map['selection']),
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'condition': condition.toJson(),
//       'directives': directives?.toJson(),
//       'selection': selection.toJson(),
//     };
//   }
// }

// final typeCondition = (string('on').trim() & name.trim()).map((l) {
//   return TypeCondition(
//     name: l[1] as String,
//   );
// }).trim();

// class TypeCondition {
//   final String name;

//   @override
//   String toString() {
//     return 'on ${name} ';
//   }

//   const TypeCondition({
//     required this.name,
//   });

//   TypeCondition copyWith({
//     String? name,
//   }) {
//     return TypeCondition(
//       name: name ?? this.name,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeCondition) {
//       return this.name == other.name;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => name.hashCode;

//   static TypeCondition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeCondition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeCondition(
//       name: map['name'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//     };
//   }
// }

// SettableParser<InlineFragment>? _inlineFragment;

// Parser<InlineFragment> get inlineFragment {
//   if (_inlineFragment != null) {
//     return _inlineFragment!;
//   }
//   _inlineFragment = undefined();
//   final p = (string('...').trim() &
//           typeCondition.trim().optional() &
//           directives.trim().optional() &
//           selectionSet.trim())
//       .map((l) {
//     return InlineFragment(
//       condition: l[1] as TypeCondition?,
//       directives: l[2] as Directives?,
//       selection: l[3] as SelectionSet,
//     );
//   }).trim();
//   _inlineFragment!.set(p);
//   return _inlineFragment!;
// }

// class InlineFragment {
//   final TypeCondition? condition;
//   final Directives? directives;
//   final SelectionSet selection;

//   @override
//   String toString() {
//     return '... ${condition == null ? "" : "${condition!}"} ${directives == null ? "" : "${directives!}"} ${selection} ';
//   }

//   const InlineFragment({
//     required this.selection,
//     this.condition,
//     this.directives,
//   });

//   InlineFragment copyWith({
//     TypeCondition? condition,
//     Directives? directives,
//     SelectionSet? selection,
//   }) {
//     return InlineFragment(
//       selection: selection ?? this.selection,
//       condition: condition ?? this.condition,
//       directives: directives ?? this.directives,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is InlineFragment) {
//       return this.condition == other.condition &&
//           this.directives == other.directives &&
//           this.selection == other.selection;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(condition, directives, selection);

//   static InlineFragment fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is InlineFragment) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return InlineFragment(
//       selection: SelectionSet.fromJson(map['selection']),
//       condition: map['condition'] == null
//           ? null
//           : TypeCondition.fromJson(map['condition']),
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'condition': condition?.toJson(),
//       'directives': directives?.toJson(),
//       'selection': selection.toJson(),
//     };
//   }
// }

// final typeSystemDefinition = ((schemaDefinition
//                 .trim()
//                 .map((v) => TypeSystemDefinition.schema(value: v)) |
//             typeDefinition
//                 .trim()
//                 .map((v) => TypeSystemDefinition.type(value: v)))
//         .cast<TypeSystemDefinition>()
//         .trim())
//     .trim();

// abstract class TypeSystemDefinition {
//   const TypeSystemDefinition._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory TypeSystemDefinition.schema({
//     required SchemaDefinition value,
//   }) = TypeSystemDefinitionSchema;
//   const factory TypeSystemDefinition.type({
//     required TypeDefinition value,
//   }) = TypeSystemDefinitionType;

//   Object get value;

//   _T when<_T>({
//     required _T Function(SchemaDefinition value) schema,
//     required _T Function(TypeDefinition value) type,
//   }) {
//     final v = this;
//     if (v is TypeSystemDefinitionSchema) {
//       return schema(v.value);
//     } else if (v is TypeSystemDefinitionType) {
//       return type(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(SchemaDefinition value)? schema,
//     _T Function(TypeDefinition value)? type,
//   }) {
//     final v = this;
//     if (v is TypeSystemDefinitionSchema) {
//       return schema != null ? schema(v.value) : orElse.call();
//     } else if (v is TypeSystemDefinitionType) {
//       return type != null ? type(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(TypeSystemDefinitionSchema value) schema,
//     required _T Function(TypeSystemDefinitionType value) type,
//   }) {
//     final v = this;
//     if (v is TypeSystemDefinitionSchema) {
//       return schema(v);
//     } else if (v is TypeSystemDefinitionType) {
//       return type(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(TypeSystemDefinitionSchema value)? schema,
//     _T Function(TypeSystemDefinitionType value)? type,
//   }) {
//     final v = this;
//     if (v is TypeSystemDefinitionSchema) {
//       return schema != null ? schema(v) : orElse.call();
//     } else if (v is TypeSystemDefinitionType) {
//       return type != null ? type(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isSchema => this is TypeSystemDefinitionSchema;
//   bool get isType => this is TypeSystemDefinitionType;

//   static TypeSystemDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeSystemDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'schema':
//         return TypeSystemDefinitionSchema.fromJson(map);
//       case 'type':
//         return TypeSystemDefinitionType.fromJson(map);
//       default:
//         throw Exception(
//             'Invalid discriminator for TypeSystemDefinition.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class TypeSystemDefinitionSchema extends TypeSystemDefinition {
//   final SchemaDefinition value;

//   const TypeSystemDefinitionSchema({
//     required this.value,
//   }) : super._();

//   TypeSystemDefinitionSchema copyWith({
//     SchemaDefinition? value,
//   }) {
//     return TypeSystemDefinitionSchema(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeSystemDefinitionSchema) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static TypeSystemDefinitionSchema fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeSystemDefinitionSchema) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeSystemDefinitionSchema(
//       value: SchemaDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'schema',
//       'value': value.toJson(),
//     };
//   }
// }

// class TypeSystemDefinitionType extends TypeSystemDefinition {
//   final TypeDefinition value;

//   const TypeSystemDefinitionType({
//     required this.value,
//   }) : super._();

//   TypeSystemDefinitionType copyWith({
//     TypeDefinition? value,
//   }) {
//     return TypeSystemDefinitionType(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeSystemDefinitionType) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static TypeSystemDefinitionType fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeSystemDefinitionType) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeSystemDefinitionType(
//       value: TypeDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'type',
//       'value': value.toJson(),
//     };
//   }
// }

// final schemaDefinition = (string('schema').trim() &
//         directives.trim().optional() &
//         char('{').trim() &
//         operationTypeDefinition
//             .trim()
//             .separatedBy<OperationTypeDefinition>(char(',').trim(),
//                 includeSeparators: false, optionalSeparatorAtEnd: true)
//             .trim() &
//         char('}').trim())
//     .map((l) {
//   return SchemaDefinition(
//     directives: l[1] as Directives?,
//     operations: l[3] as List<OperationTypeDefinition>,
//   );
// }).trim();

// class SchemaDefinition {
//   final Directives? directives;
//   final List<OperationTypeDefinition> operations;

//   @override
//   String toString() {
//     return 'schema ${directives == null ? "" : "${directives!}"} { ${operations.join(',')} } ';
//   }

//   const SchemaDefinition({
//     required this.operations,
//     this.directives,
//   });

//   SchemaDefinition copyWith({
//     Directives? directives,
//     List<OperationTypeDefinition>? operations,
//   }) {
//     return SchemaDefinition(
//       operations: operations ?? this.operations,
//       directives: directives ?? this.directives,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is SchemaDefinition) {
//       return this.directives == other.directives &&
//           this.operations == other.operations;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(directives, operations);

//   static SchemaDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is SchemaDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return SchemaDefinition(
//       operations: (map['operations'] as List)
//           .map((e) => OperationTypeDefinition.fromJson(e))
//           .toList(),
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'directives': directives?.toJson(),
//       'operations': operations.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// final operationTypeDefinition =
//     (operationType.trim() & char(':').trim() & name.trim()).map((l) {
//   return OperationTypeDefinition(
//     type: l[0] as OperationType,
//     name: l[2] as String,
//   );
// }).trim();

// class OperationTypeDefinition {
//   final OperationType type;
//   final String name;

//   @override
//   String toString() {
//     return '${type} : ${name} ';
//   }

//   const OperationTypeDefinition({
//     required this.type,
//     required this.name,
//   });

//   OperationTypeDefinition copyWith({
//     OperationType? type,
//     String? name,
//   }) {
//     return OperationTypeDefinition(
//       type: type ?? this.type,
//       name: name ?? this.name,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is OperationTypeDefinition) {
//       return this.type == other.type && this.name == other.name;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(type, name);

//   static OperationTypeDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is OperationTypeDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return OperationTypeDefinition(
//       type: OperationType.fromJson(map['type']),
//       name: map['name'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'type': type.toJson(),
//       'name': name,
//     };
//   }
// }

// final operationType = ((string('query').trim().map((_) => OperationType.query) |
//             string('mutation').trim().map((_) => OperationType.mutation) |
//             string('subscription')
//                 .trim()
//                 .map((_) => OperationType.subscription))
//         .cast<OperationType>()
//         .trim())
//     .trim();

// class OperationType {
//   final String _inner;

//   const OperationType._(this._inner);

//   static const query = OperationType._('query');
//   static const mutation = OperationType._('mutation');
//   static const subscription = OperationType._('subscription');

//   static const values = [
//     OperationType.query,
//     OperationType.mutation,
//     OperationType.subscription,
//   ];

//   static OperationType fromJson(Object? json) {
//     if (json == null) {
//       throw Error();
//     }
//     for (final v in values) {
//       if (json.toString() == v._inner) {
//         return v;
//       }
//     }
//     throw Error();
//   }

//   String toJson() {
//     return _inner;
//   }

//   @override
//   String toString() {
//     return _inner;
//   }

//   @override
//   bool operator ==(Object other) {
//     return other is OperationType &&
//         other.runtimeType == runtimeType &&
//         other._inner == _inner;
//   }

//   @override
//   int get hashCode => _inner.hashCode;

//   bool get isQuery => this == OperationType.query;
//   bool get isMutation => this == OperationType.mutation;
//   bool get isSubscription => this == OperationType.subscription;

//   _T when<_T>({
//     required _T Function() query,
//     required _T Function() mutation,
//     required _T Function() subscription,
//   }) {
//     switch (this._inner) {
//       case 'query':
//         return query();
//       case 'mutation':
//         return mutation();
//       case 'subscription':
//         return subscription();
//     }
//     throw Error();
//   }

//   _T maybeWhen<_T>({
//     _T Function()? query,
//     _T Function()? mutation,
//     _T Function()? subscription,
//     required _T Function() orElse,
//   }) {
//     _T Function()? c;
//     switch (this._inner) {
//       case 'query':
//         c = query;
//         break;
//       case 'mutation':
//         c = mutation;
//         break;
//       case 'subscription':
//         c = subscription;
//         break;
//     }
//     return (c ?? orElse).call();
//   }
// }

// final typeDefinition =
//     ((scalarTypeDefinition.trim().map((v) => TypeDefinition.scalar(value: v)) |
//                 objectTypeDefinition
//                     .trim()
//                     .map((v) => TypeDefinition.object(value: v)) |
//                 interfaceTypeDefinition
//                     .trim()
//                     .map((v) => TypeDefinition.interface(value: v)) |
//                 unionTypeDefinition
//                     .trim()
//                     .map((v) => TypeDefinition.union(value: v)) |
//                 enumTypeDefinition
//                     .trim()
//                     .map((v) => TypeDefinition.enumDef(value: v)) |
//                 inputObjectTypeDefinition
//                     .trim()
//                     .map((v) => TypeDefinition.inputObject(value: v)))
//             .cast<TypeDefinition>()
//             .trim())
//         .trim();

// abstract class TypeDefinition {
//   const TypeDefinition._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory TypeDefinition.scalar({
//     required ScalarTypeDefinition value,
//   }) = TypeDefinitionScalar;
//   const factory TypeDefinition.object({
//     required ObjectTypeDefinition value,
//   }) = TypeDefinitionObject;
//   const factory TypeDefinition.interface({
//     required InterfaceTypeDefinition value,
//   }) = TypeDefinitionInterface;
//   const factory TypeDefinition.union({
//     required UnionTypeDefinition value,
//   }) = TypeDefinitionUnion;
//   const factory TypeDefinition.enumDef({
//     required EnumTypeDefinition value,
//   }) = TypeDefinitionEnumDef;
//   const factory TypeDefinition.inputObject({
//     required InputObjectTypeDefinition value,
//   }) = TypeDefinitionInputObject;

//   Object get value;

//   _T when<_T>({
//     required _T Function(ScalarTypeDefinition value) scalar,
//     required _T Function(ObjectTypeDefinition value) object,
//     required _T Function(InterfaceTypeDefinition value) interface,
//     required _T Function(UnionTypeDefinition value) union,
//     required _T Function(EnumTypeDefinition value) enumDef,
//     required _T Function(InputObjectTypeDefinition value) inputObject,
//   }) {
//     final v = this;
//     if (v is TypeDefinitionScalar) {
//       return scalar(v.value);
//     } else if (v is TypeDefinitionObject) {
//       return object(v.value);
//     } else if (v is TypeDefinitionInterface) {
//       return interface(v.value);
//     } else if (v is TypeDefinitionUnion) {
//       return union(v.value);
//     } else if (v is TypeDefinitionEnumDef) {
//       return enumDef(v.value);
//     } else if (v is TypeDefinitionInputObject) {
//       return inputObject(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(ScalarTypeDefinition value)? scalar,
//     _T Function(ObjectTypeDefinition value)? object,
//     _T Function(InterfaceTypeDefinition value)? interface,
//     _T Function(UnionTypeDefinition value)? union,
//     _T Function(EnumTypeDefinition value)? enumDef,
//     _T Function(InputObjectTypeDefinition value)? inputObject,
//   }) {
//     final v = this;
//     if (v is TypeDefinitionScalar) {
//       return scalar != null ? scalar(v.value) : orElse.call();
//     } else if (v is TypeDefinitionObject) {
//       return object != null ? object(v.value) : orElse.call();
//     } else if (v is TypeDefinitionInterface) {
//       return interface != null ? interface(v.value) : orElse.call();
//     } else if (v is TypeDefinitionUnion) {
//       return union != null ? union(v.value) : orElse.call();
//     } else if (v is TypeDefinitionEnumDef) {
//       return enumDef != null ? enumDef(v.value) : orElse.call();
//     } else if (v is TypeDefinitionInputObject) {
//       return inputObject != null ? inputObject(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(TypeDefinitionScalar value) scalar,
//     required _T Function(TypeDefinitionObject value) object,
//     required _T Function(TypeDefinitionInterface value) interface,
//     required _T Function(TypeDefinitionUnion value) union,
//     required _T Function(TypeDefinitionEnumDef value) enumDef,
//     required _T Function(TypeDefinitionInputObject value) inputObject,
//   }) {
//     final v = this;
//     if (v is TypeDefinitionScalar) {
//       return scalar(v);
//     } else if (v is TypeDefinitionObject) {
//       return object(v);
//     } else if (v is TypeDefinitionInterface) {
//       return interface(v);
//     } else if (v is TypeDefinitionUnion) {
//       return union(v);
//     } else if (v is TypeDefinitionEnumDef) {
//       return enumDef(v);
//     } else if (v is TypeDefinitionInputObject) {
//       return inputObject(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(TypeDefinitionScalar value)? scalar,
//     _T Function(TypeDefinitionObject value)? object,
//     _T Function(TypeDefinitionInterface value)? interface,
//     _T Function(TypeDefinitionUnion value)? union,
//     _T Function(TypeDefinitionEnumDef value)? enumDef,
//     _T Function(TypeDefinitionInputObject value)? inputObject,
//   }) {
//     final v = this;
//     if (v is TypeDefinitionScalar) {
//       return scalar != null ? scalar(v) : orElse.call();
//     } else if (v is TypeDefinitionObject) {
//       return object != null ? object(v) : orElse.call();
//     } else if (v is TypeDefinitionInterface) {
//       return interface != null ? interface(v) : orElse.call();
//     } else if (v is TypeDefinitionUnion) {
//       return union != null ? union(v) : orElse.call();
//     } else if (v is TypeDefinitionEnumDef) {
//       return enumDef != null ? enumDef(v) : orElse.call();
//     } else if (v is TypeDefinitionInputObject) {
//       return inputObject != null ? inputObject(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isScalar => this is TypeDefinitionScalar;
//   bool get isObject => this is TypeDefinitionObject;
//   bool get isInterface => this is TypeDefinitionInterface;
//   bool get isUnion => this is TypeDefinitionUnion;
//   bool get isEnumDef => this is TypeDefinitionEnumDef;
//   bool get isInputObject => this is TypeDefinitionInputObject;

//   static TypeDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'scalar':
//         return TypeDefinitionScalar.fromJson(map);
//       case 'object':
//         return TypeDefinitionObject.fromJson(map);
//       case 'interface':
//         return TypeDefinitionInterface.fromJson(map);
//       case 'union':
//         return TypeDefinitionUnion.fromJson(map);
//       case 'enumDef':
//         return TypeDefinitionEnumDef.fromJson(map);
//       case 'inputObject':
//         return TypeDefinitionInputObject.fromJson(map);
//       default:
//         throw Exception('Invalid discriminator for TypeDefinition.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class TypeDefinitionScalar extends TypeDefinition {
//   final ScalarTypeDefinition value;

//   const TypeDefinitionScalar({
//     required this.value,
//   }) : super._();

//   TypeDefinitionScalar copyWith({
//     ScalarTypeDefinition? value,
//   }) {
//     return TypeDefinitionScalar(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeDefinitionScalar) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static TypeDefinitionScalar fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeDefinitionScalar) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeDefinitionScalar(
//       value: ScalarTypeDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'scalar',
//       'value': value.toJson(),
//     };
//   }
// }

// class TypeDefinitionObject extends TypeDefinition {
//   final ObjectTypeDefinition value;

//   const TypeDefinitionObject({
//     required this.value,
//   }) : super._();

//   TypeDefinitionObject copyWith({
//     ObjectTypeDefinition? value,
//   }) {
//     return TypeDefinitionObject(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeDefinitionObject) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static TypeDefinitionObject fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeDefinitionObject) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeDefinitionObject(
//       value: ObjectTypeDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'object',
//       'value': value.toJson(),
//     };
//   }
// }

// class TypeDefinitionInterface extends TypeDefinition {
//   final InterfaceTypeDefinition value;

//   const TypeDefinitionInterface({
//     required this.value,
//   }) : super._();

//   TypeDefinitionInterface copyWith({
//     InterfaceTypeDefinition? value,
//   }) {
//     return TypeDefinitionInterface(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeDefinitionInterface) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static TypeDefinitionInterface fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeDefinitionInterface) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeDefinitionInterface(
//       value: InterfaceTypeDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'interface',
//       'value': value.toJson(),
//     };
//   }
// }

// class TypeDefinitionUnion extends TypeDefinition {
//   final UnionTypeDefinition value;

//   const TypeDefinitionUnion({
//     required this.value,
//   }) : super._();

//   TypeDefinitionUnion copyWith({
//     UnionTypeDefinition? value,
//   }) {
//     return TypeDefinitionUnion(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeDefinitionUnion) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static TypeDefinitionUnion fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeDefinitionUnion) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeDefinitionUnion(
//       value: UnionTypeDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'union',
//       'value': value.toJson(),
//     };
//   }
// }

// class TypeDefinitionEnumDef extends TypeDefinition {
//   final EnumTypeDefinition value;

//   const TypeDefinitionEnumDef({
//     required this.value,
//   }) : super._();

//   TypeDefinitionEnumDef copyWith({
//     EnumTypeDefinition? value,
//   }) {
//     return TypeDefinitionEnumDef(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeDefinitionEnumDef) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static TypeDefinitionEnumDef fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeDefinitionEnumDef) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeDefinitionEnumDef(
//       value: EnumTypeDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'enumDef',
//       'value': value.toJson(),
//     };
//   }
// }

// class TypeDefinitionInputObject extends TypeDefinition {
//   final InputObjectTypeDefinition value;

//   const TypeDefinitionInputObject({
//     required this.value,
//   }) : super._();

//   TypeDefinitionInputObject copyWith({
//     InputObjectTypeDefinition? value,
//   }) {
//     return TypeDefinitionInputObject(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is TypeDefinitionInputObject) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static TypeDefinitionInputObject fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is TypeDefinitionInputObject) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return TypeDefinitionInputObject(
//       value: InputObjectTypeDefinition.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'inputObject',
//       'value': value.toJson(),
//     };
//   }
// }

// final scalarTypeDefinition =
//     (string('scalar').trim() & name.trim() & directives.trim().optional())
//         .map((l) {
//   return ScalarTypeDefinition(
//     name: l[1] as String,
//     directives: l[2] as Directives?,
//   );
// }).trim();

// class ScalarTypeDefinition {
//   final String name;
//   final Directives? directives;

//   @override
//   String toString() {
//     return 'scalar ${name} ${directives == null ? "" : "${directives!}"} ';
//   }

//   const ScalarTypeDefinition({
//     required this.name,
//     this.directives,
//   });

//   ScalarTypeDefinition copyWith({
//     String? name,
//     Directives? directives,
//   }) {
//     return ScalarTypeDefinition(
//       name: name ?? this.name,
//       directives: directives ?? this.directives,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ScalarTypeDefinition) {
//       return this.name == other.name && this.directives == other.directives;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, directives);

//   static ScalarTypeDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ScalarTypeDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ScalarTypeDefinition(
//       name: map['name'] as String,
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'directives': directives?.toJson(),
//     };
//   }
// }

// final objectTypeDefinition = (string('type').trim() &
//         name.trim() &
//         implementsInterfaces.trim().optional() &
//         directives.trim() &
//         fieldsDefinition.trim().optional())
//     .map((l) {
//   return ObjectTypeDefinition(
//     name: l[1] as String,
//     implement: l[2] as ImplementsInterfaces?,
//     directives: l[3] as Directives,
//     fields: l[4] as FieldsDefinition?,
//   );
// }).trim();

// class ObjectTypeDefinition {
//   final String name;
//   final ImplementsInterfaces? implement;
//   final Directives directives;
//   final FieldsDefinition? fields;

//   @override
//   String toString() {
//     return 'type ${name} ${implement == null ? "" : "${implement!}"} ${directives} ${fields == null ? "" : "${fields!}"} ';
//   }

//   const ObjectTypeDefinition({
//     required this.name,
//     required this.directives,
//     this.implement,
//     this.fields,
//   });

//   ObjectTypeDefinition copyWith({
//     String? name,
//     ImplementsInterfaces? implement,
//     Directives? directives,
//     FieldsDefinition? fields,
//   }) {
//     return ObjectTypeDefinition(
//       name: name ?? this.name,
//       directives: directives ?? this.directives,
//       implement: implement ?? this.implement,
//       fields: fields ?? this.fields,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ObjectTypeDefinition) {
//       return this.name == other.name &&
//           this.implement == other.implement &&
//           this.directives == other.directives &&
//           this.fields == other.fields;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, implement, directives, fields);

//   static ObjectTypeDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ObjectTypeDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ObjectTypeDefinition(
//       name: map['name'] as String,
//       directives: Directives.fromJson(map['directives']),
//       implement: map['implement'] == null
//           ? null
//           : ImplementsInterfaces.fromJson(map['implement']),
//       fields: map['fields'] == null
//           ? null
//           : FieldsDefinition.fromJson(map['fields']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'implement': implement?.toJson(),
//       'directives': directives.toJson(),
//       'fields': fields?.toJson(),
//     };
//   }
// }

// SettableParser<ImplementsInterfaces>? _implementsInterfaces;

// Parser<ImplementsInterfaces> get implementsInterfaces {
//   if (_implementsInterfaces != null) {
//     return _implementsInterfaces!;
//   }
//   _implementsInterfaces = undefined();
//   final p =
//       ((string('implements').trim() & char('&').trim().optional() & name.trim())
//                   .map((l) {
//                     return ImplValue(
//                       name: l[2] as String,
//                     );
//                   })
//                   .trim()
//                   .map((v) => ImplementsInterfaces.implValue(value: v)) |
//               (implementsInterfaces.trim() & char('&').trim() & name.trim())
//                   .map((l) {
//                     return ImplList(
//                       impl: l[0] as ImplementsInterfaces,
//                       name: l[2] as String,
//                     );
//                   })
//                   .trim()
//                   .map((v) => ImplementsInterfaces.implList(value: v)))
//           .cast<ImplementsInterfaces>()
//           .trim();
//   _implementsInterfaces!.set(p);
//   return _implementsInterfaces!;
// }

// abstract class ImplementsInterfaces {
//   const ImplementsInterfaces._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory ImplementsInterfaces.implValue({
//     required ImplValue value,
//   }) = implementsInterfacesImplValue;
//   const factory ImplementsInterfaces.implList({
//     required ImplList value,
//   }) = implementsInterfacesImplList;

//   Object get value;

//   _T when<_T>({
//     required _T Function(ImplValue value) implValue,
//     required _T Function(ImplList value) implList,
//   }) {
//     final v = this;
//     if (v is implementsInterfacesImplValue) {
//       return implValue(v.value);
//     } else if (v is implementsInterfacesImplList) {
//       return implList(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(ImplValue value)? implValue,
//     _T Function(ImplList value)? implList,
//   }) {
//     final v = this;
//     if (v is implementsInterfacesImplValue) {
//       return implValue != null ? implValue(v.value) : orElse.call();
//     } else if (v is implementsInterfacesImplList) {
//       return implList != null ? implList(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(implementsInterfacesImplValue value) implValue,
//     required _T Function(implementsInterfacesImplList value) implList,
//   }) {
//     final v = this;
//     if (v is implementsInterfacesImplValue) {
//       return implValue(v);
//     } else if (v is implementsInterfacesImplList) {
//       return implList(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(implementsInterfacesImplValue value)? implValue,
//     _T Function(implementsInterfacesImplList value)? implList,
//   }) {
//     final v = this;
//     if (v is implementsInterfacesImplValue) {
//       return implValue != null ? implValue(v) : orElse.call();
//     } else if (v is implementsInterfacesImplList) {
//       return implList != null ? implList(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isImplValue => this is implementsInterfacesImplValue;
//   bool get isImplList => this is implementsInterfacesImplList;

//   static ImplementsInterfaces fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ImplementsInterfaces) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'implValue':
//         return implementsInterfacesImplValue.fromJson(map);
//       case 'implList':
//         return implementsInterfacesImplList.fromJson(map);
//       default:
//         throw Exception(
//             'Invalid discriminator for ImplementsInterfaces.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class implementsInterfacesImplValue extends ImplementsInterfaces {
//   final ImplValue value;

//   const implementsInterfacesImplValue({
//     required this.value,
//   }) : super._();

//   implementsInterfacesImplValue copyWith({
//     ImplValue? value,
//   }) {
//     return implementsInterfacesImplValue(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is implementsInterfacesImplValue) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static implementsInterfacesImplValue fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is implementsInterfacesImplValue) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return implementsInterfacesImplValue(
//       value: ImplValue.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'implValue',
//       'value': value.toJson(),
//     };
//   }
// }

// class implementsInterfacesImplList extends ImplementsInterfaces {
//   final ImplList value;

//   const implementsInterfacesImplList({
//     required this.value,
//   }) : super._();

//   implementsInterfacesImplList copyWith({
//     ImplList? value,
//   }) {
//     return implementsInterfacesImplList(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is implementsInterfacesImplList) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static implementsInterfacesImplList fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is implementsInterfacesImplList) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return implementsInterfacesImplList(
//       value: ImplList.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'implList',
//       'value': value.toJson(),
//     };
//   }
// }

// class ImplValue {
//   final String name;

//   @override
//   String toString() {
//     return 'implements & ${name} ';
//   }

//   const ImplValue({
//     required this.name,
//   });

//   ImplValue copyWith({
//     String? name,
//   }) {
//     return ImplValue(
//       name: name ?? this.name,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ImplValue) {
//       return this.name == other.name;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => name.hashCode;

//   static ImplValue fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ImplValue) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ImplValue(
//       name: map['name'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//     };
//   }
// }

// class ImplList {
//   final ImplementsInterfaces impl;
//   final String name;

//   @override
//   String toString() {
//     return '${impl} & ${name} ';
//   }

//   const ImplList({
//     required this.impl,
//     required this.name,
//   });

//   ImplList copyWith({
//     ImplementsInterfaces? impl,
//     String? name,
//   }) {
//     return ImplList(
//       impl: impl ?? this.impl,
//       name: name ?? this.name,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ImplList) {
//       return this.impl == other.impl && this.name == other.name;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(impl, name);

//   static ImplList fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ImplList) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ImplList(
//       impl: ImplementsInterfaces.fromJson(map['impl']),
//       name: map['name'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'impl': impl.toJson(),
//       'name': name,
//     };
//   }
// }

// final fieldsDefinition = (char('{').trim() &
//         fieldDefinition
//             .trim()
//             .separatedBy<FieldDefinition>(char(',').trim(),
//                 includeSeparators: false, optionalSeparatorAtEnd: true)
//             .trim() &
//         char('}').trim())
//     .map((l) {
//   return FieldsDefinition(
//     fields: l[1] as List<FieldDefinition>,
//   );
// }).trim();

// class FieldsDefinition {
//   final List<FieldDefinition> fields;

//   @override
//   String toString() {
//     return '{ ${fields.join(',')} } ';
//   }

//   const FieldsDefinition({
//     required this.fields,
//   });

//   FieldsDefinition copyWith({
//     List<FieldDefinition>? fields,
//   }) {
//     return FieldsDefinition(
//       fields: fields ?? this.fields,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is FieldsDefinition) {
//       return this.fields == other.fields;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => fields.hashCode;

//   static FieldsDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is FieldsDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return FieldsDefinition(
//       fields: (map['fields'] as List)
//           .map((e) => FieldDefinition.fromJson(e))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'fields': fields.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// final fieldDefinition = (name.trim() &
//         argumentsDefinition.trim().optional() &
//         char(':').trim() &
//         type.trim() &
//         directives.trim())
//     .map((l) {
//   return FieldDefinition(
//     name: l[0] as String,
//     arguments: l[1] as ArgumentsDefinition?,
//     type: l[3] as Type,
//     directives: l[4] as Directives,
//   );
// }).trim();

// class FieldDefinition {
//   final String name;
//   final ArgumentsDefinition? arguments;
//   final Type type;
//   final Directives directives;

//   @override
//   String toString() {
//     return '${name} ${arguments == null ? "" : "${arguments!}"} : ${type} ${directives} ';
//   }

//   const FieldDefinition({
//     required this.name,
//     required this.type,
//     required this.directives,
//     this.arguments,
//   });

//   FieldDefinition copyWith({
//     String? name,
//     ArgumentsDefinition? arguments,
//     Type? type,
//     Directives? directives,
//   }) {
//     return FieldDefinition(
//       name: name ?? this.name,
//       type: type ?? this.type,
//       directives: directives ?? this.directives,
//       arguments: arguments ?? this.arguments,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is FieldDefinition) {
//       return this.name == other.name &&
//           this.arguments == other.arguments &&
//           this.type == other.type &&
//           this.directives == other.directives;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, arguments, type, directives);

//   static FieldDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is FieldDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return FieldDefinition(
//       name: map['name'] as String,
//       type: Type.fromJson(map['type']),
//       directives: Directives.fromJson(map['directives']),
//       arguments: map['arguments'] == null
//           ? null
//           : ArgumentsDefinition.fromJson(map['arguments']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'arguments': arguments?.toJson(),
//       'type': type.toJson(),
//       'directives': directives.toJson(),
//     };
//   }
// }

// final argumentsDefinition =
//     (char('(').trim() & inputValueDefinition.trim() & char(')').trim())
//         .map((l) {
//   return ArgumentsDefinition(
//     values: l[1] as InputValueDefinition,
//   );
// }).trim();

// class ArgumentsDefinition {
//   final InputValueDefinition values;

//   @override
//   String toString() {
//     return '( ${values} ) ';
//   }

//   const ArgumentsDefinition({
//     required this.values,
//   });

//   ArgumentsDefinition copyWith({
//     InputValueDefinition? values,
//   }) {
//     return ArgumentsDefinition(
//       values: values ?? this.values,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is ArgumentsDefinition) {
//       return this.values == other.values;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => values.hashCode;

//   static ArgumentsDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is ArgumentsDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return ArgumentsDefinition(
//       values: InputValueDefinition.fromJson(map['values']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'values': values.toJson(),
//     };
//   }
// }

// final inputValueDefinition = (name.trim() &
//         char(':').trim() &
//         type.trim() &
//         defaultValue.trim().optional() &
//         directives.trim().optional())
//     .map((l) {
//   return InputValueDefinition(
//     name: l[0] as String,
//     type: l[2] as Type,
//     defaultValue: l[3] as DefaultValue?,
//     directives: l[4] as Directives?,
//   );
// }).trim();

// class InputValueDefinition {
//   final String name;
//   final Type type;
//   final DefaultValue? defaultValue;
//   final Directives? directives;

//   @override
//   String toString() {
//     return '${name} : ${type} ${defaultValue == null ? "" : "${defaultValue!}"} ${directives == null ? "" : "${directives!}"} ';
//   }

//   const InputValueDefinition({
//     required this.name,
//     required this.type,
//     this.defaultValue,
//     this.directives,
//   });

//   InputValueDefinition copyWith({
//     String? name,
//     Type? type,
//     DefaultValue? defaultValue,
//     Directives? directives,
//   }) {
//     return InputValueDefinition(
//       name: name ?? this.name,
//       type: type ?? this.type,
//       defaultValue: defaultValue ?? this.defaultValue,
//       directives: directives ?? this.directives,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is InputValueDefinition) {
//       return this.name == other.name &&
//           this.type == other.type &&
//           this.defaultValue == other.defaultValue &&
//           this.directives == other.directives;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, type, defaultValue, directives);

//   static InputValueDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is InputValueDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return InputValueDefinition(
//       name: map['name'] as String,
//       type: Type.fromJson(map['type']),
//       defaultValue: map['defaultValue'] == null
//           ? null
//           : DefaultValue.fromJson(map['defaultValue']),
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'type': type.toJson(),
//       'defaultValue': defaultValue?.toJson(),
//       'directives': directives?.toJson(),
//     };
//   }
// }

// final interfaceTypeDefinition = (string('interface').trim() &
//         name.trim() &
//         directives.trim().optional() &
//         fieldsDefinition.trim().optional())
//     .map((l) {
//   return InterfaceTypeDefinition(
//     name: l[1] as String,
//     directives: l[2] as Directives?,
//     fields: l[3] as FieldsDefinition?,
//   );
// }).trim();

// class InterfaceTypeDefinition {
//   final String name;
//   final Directives? directives;
//   final FieldsDefinition? fields;

//   @override
//   String toString() {
//     return 'interface ${name} ${directives == null ? "" : "${directives!}"} ${fields == null ? "" : "${fields!}"} ';
//   }

//   const InterfaceTypeDefinition({
//     required this.name,
//     this.directives,
//     this.fields,
//   });

//   InterfaceTypeDefinition copyWith({
//     String? name,
//     Directives? directives,
//     FieldsDefinition? fields,
//   }) {
//     return InterfaceTypeDefinition(
//       name: name ?? this.name,
//       directives: directives ?? this.directives,
//       fields: fields ?? this.fields,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is InterfaceTypeDefinition) {
//       return this.name == other.name &&
//           this.directives == other.directives &&
//           this.fields == other.fields;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, directives, fields);

//   static InterfaceTypeDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is InterfaceTypeDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return InterfaceTypeDefinition(
//       name: map['name'] as String,
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//       fields: map['fields'] == null
//           ? null
//           : FieldsDefinition.fromJson(map['fields']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'directives': directives?.toJson(),
//       'fields': fields?.toJson(),
//     };
//   }
// }

// final unionTypeDefinition = (string('union').trim() &
//         name.trim() &
//         directives.trim().optional() &
//         unionMemberTypes.trim().optional())
//     .map((l) {
//   return UnionTypeDefinition(
//     name: l[1] as String,
//     directives: l[2] as Directives?,
//     unionMemberTypes: l[3] as UnionMemberTypes?,
//   );
// }).trim();

// class UnionTypeDefinition {
//   final String name;
//   final Directives? directives;
//   final UnionMemberTypes? unionMemberTypes;

//   @override
//   String toString() {
//     return 'union ${name} ${directives == null ? "" : "${directives!}"} ${unionMemberTypes == null ? "" : "${unionMemberTypes!}"} ';
//   }

//   const UnionTypeDefinition({
//     required this.name,
//     this.directives,
//     this.unionMemberTypes,
//   });

//   UnionTypeDefinition copyWith({
//     String? name,
//     Directives? directives,
//     UnionMemberTypes? unionMemberTypes,
//   }) {
//     return UnionTypeDefinition(
//       name: name ?? this.name,
//       directives: directives ?? this.directives,
//       unionMemberTypes: unionMemberTypes ?? this.unionMemberTypes,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is UnionTypeDefinition) {
//       return this.name == other.name &&
//           this.directives == other.directives &&
//           this.unionMemberTypes == other.unionMemberTypes;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, directives, unionMemberTypes);

//   static UnionTypeDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is UnionTypeDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return UnionTypeDefinition(
//       name: map['name'] as String,
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//       unionMemberTypes: map['unionMemberTypes'] == null
//           ? null
//           : UnionMemberTypes.fromJson(map['unionMemberTypes']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'directives': directives?.toJson(),
//       'unionMemberTypes': unionMemberTypes?.toJson(),
//     };
//   }
// }

// SettableParser<UnionMemberTypes>? _unionMemberTypes;

// Parser<UnionMemberTypes> get unionMemberTypes {
//   if (_unionMemberTypes != null) {
//     return _unionMemberTypes!;
//   }
//   _unionMemberTypes = undefined();
//   final p = (((char('=').trim() & char('|').trim().optional() & name.trim())
//                   .map((l) {
//                     return Item(
//                       value: l[2] as String,
//                     );
//                   })
//                   .trim()
//                   .map((v) => UnionMemberTypes.item(value: v)) |
//               (unionMemberTypes.trim() & char('|').trim() & name.trim())
//                   .map((l) {
//                     return Items(
//                       values: l[0] as UnionMemberTypes,
//                       value: l[2] as String,
//                     );
//                   })
//                   .trim()
//                   .map((v) => UnionMemberTypes.items(value: v)))
//           .cast<UnionMemberTypes>()
//           .trim())
//       .trim();
//   _unionMemberTypes!.set(p);
//   return _unionMemberTypes!;
// }

// abstract class UnionMemberTypes {
//   const UnionMemberTypes._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory UnionMemberTypes.item({
//     required Item value,
//   }) = UnionMemberTypesItem;
//   const factory UnionMemberTypes.items({
//     required Items value,
//   }) = UnionMemberTypesItems;

//   Object get value;

//   _T when<_T>({
//     required _T Function(Item value) item,
//     required _T Function(Items value) items,
//   }) {
//     final v = this;
//     if (v is UnionMemberTypesItem) {
//       return item(v.value);
//     } else if (v is UnionMemberTypesItems) {
//       return items(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(Item value)? item,
//     _T Function(Items value)? items,
//   }) {
//     final v = this;
//     if (v is UnionMemberTypesItem) {
//       return item != null ? item(v.value) : orElse.call();
//     } else if (v is UnionMemberTypesItems) {
//       return items != null ? items(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(UnionMemberTypesItem value) item,
//     required _T Function(UnionMemberTypesItems value) items,
//   }) {
//     final v = this;
//     if (v is UnionMemberTypesItem) {
//       return item(v);
//     } else if (v is UnionMemberTypesItems) {
//       return items(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(UnionMemberTypesItem value)? item,
//     _T Function(UnionMemberTypesItems value)? items,
//   }) {
//     final v = this;
//     if (v is UnionMemberTypesItem) {
//       return item != null ? item(v) : orElse.call();
//     } else if (v is UnionMemberTypesItems) {
//       return items != null ? items(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isItem => this is UnionMemberTypesItem;
//   bool get isItems => this is UnionMemberTypesItems;

//   static UnionMemberTypes fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is UnionMemberTypes) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'item':
//         return UnionMemberTypesItem.fromJson(map);
//       case 'items':
//         return UnionMemberTypesItems.fromJson(map);
//       default:
//         throw Exception('Invalid discriminator for UnionMemberTypes.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class UnionMemberTypesItem extends UnionMemberTypes {
//   final Item value;

//   const UnionMemberTypesItem({
//     required this.value,
//   }) : super._();

//   UnionMemberTypesItem copyWith({
//     Item? value,
//   }) {
//     return UnionMemberTypesItem(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is UnionMemberTypesItem) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static UnionMemberTypesItem fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is UnionMemberTypesItem) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return UnionMemberTypesItem(
//       value: Item.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'item',
//       'value': value.toJson(),
//     };
//   }
// }

// class UnionMemberTypesItems extends UnionMemberTypes {
//   final Items value;

//   const UnionMemberTypesItems({
//     required this.value,
//   }) : super._();

//   UnionMemberTypesItems copyWith({
//     Items? value,
//   }) {
//     return UnionMemberTypesItems(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is UnionMemberTypesItems) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static UnionMemberTypesItems fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is UnionMemberTypesItems) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return UnionMemberTypesItems(
//       value: Items.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'items',
//       'value': value.toJson(),
//     };
//   }
// }

// class Item {
//   final String value;

//   @override
//   String toString() {
//     return '= | ${value} ';
//   }

//   const Item({
//     required this.value,
//   });

//   Item copyWith({
//     String? value,
//   }) {
//     return Item(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Item) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static Item fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Item) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Item(
//       value: map['value'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'value': value,
//     };
//   }
// }

// class Items {
//   final UnionMemberTypes values;
//   final String value;

//   @override
//   String toString() {
//     return '${values} | ${value} ';
//   }

//   const Items({
//     required this.values,
//     required this.value,
//   });

//   Items copyWith({
//     UnionMemberTypes? values,
//     String? value,
//   }) {
//     return Items(
//       values: values ?? this.values,
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Items) {
//       return this.values == other.values && this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(values, value);

//   static Items fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Items) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Items(
//       values: UnionMemberTypes.fromJson(map['values']),
//       value: map['value'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'values': values.toJson(),
//       'value': value,
//     };
//   }
// }

// final enumTypeDefinition = (string('enum').trim() &
//         name.trim() &
//         directives.trim().optional() &
//         enumValuesDefinition.trim().optional())
//     .map((l) {
//   return EnumTypeDefinition(
//     name: l[1] as String,
//     directives: l[2] as Directives?,
//     values: l[3] as EnumValuesDefinition?,
//   );
// }).trim();

// class EnumTypeDefinition {
//   final String name;
//   final Directives? directives;
//   final EnumValuesDefinition? values;

//   @override
//   String toString() {
//     return 'enum ${name} ${directives == null ? "" : "${directives!}"} ${values == null ? "" : "${values!}"} ';
//   }

//   const EnumTypeDefinition({
//     required this.name,
//     this.directives,
//     this.values,
//   });

//   EnumTypeDefinition copyWith({
//     String? name,
//     Directives? directives,
//     EnumValuesDefinition? values,
//   }) {
//     return EnumTypeDefinition(
//       name: name ?? this.name,
//       directives: directives ?? this.directives,
//       values: values ?? this.values,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is EnumTypeDefinition) {
//       return this.name == other.name &&
//           this.directives == other.directives &&
//           this.values == other.values;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, directives, values);

//   static EnumTypeDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is EnumTypeDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return EnumTypeDefinition(
//       name: map['name'] as String,
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//       values: map['values'] == null
//           ? null
//           : EnumValuesDefinition.fromJson(map['values']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'directives': directives?.toJson(),
//       'values': values?.toJson(),
//     };
//   }
// }

// final enumValuesDefinition = (char('{').trim() &
//         enumValueDefinition
//             .trim()
//             .separatedBy<EnumValueDefinition>(char(',').trim(),
//                 includeSeparators: false, optionalSeparatorAtEnd: true)
//             .trim() &
//         char('}').trim())
//     .map((l) {
//   return EnumValuesDefinition(
//     values: l[1] as List<EnumValueDefinition>,
//   );
// }).trim();

// class EnumValuesDefinition {
//   final List<EnumValueDefinition> values;

//   @override
//   String toString() {
//     return '{ ${values.join(',')} } ';
//   }

//   const EnumValuesDefinition({
//     required this.values,
//   });

//   EnumValuesDefinition copyWith({
//     List<EnumValueDefinition>? values,
//   }) {
//     return EnumValuesDefinition(
//       values: values ?? this.values,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is EnumValuesDefinition) {
//       return this.values == other.values;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => values.hashCode;

//   static EnumValuesDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is EnumValuesDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return EnumValuesDefinition(
//       values: (map['values'] as List)
//           .map((e) => EnumValueDefinition.fromJson(e))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'values': values.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// final enumValueDefinition =
//     (name.trim() & directives.trim().optional()).map((l) {
//   return EnumValueDefinition(
//     name: l[0] as String,
//     directives: l[1] as Directives?,
//   );
// }).trim();

// class EnumValueDefinition {
//   final String name;
//   final Directives? directives;

//   @override
//   String toString() {
//     return '${name} ${directives == null ? "" : "${directives!}"} ';
//   }

//   const EnumValueDefinition({
//     required this.name,
//     this.directives,
//   });

//   EnumValueDefinition copyWith({
//     String? name,
//     Directives? directives,
//   }) {
//     return EnumValueDefinition(
//       name: name ?? this.name,
//       directives: directives ?? this.directives,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is EnumValueDefinition) {
//       return this.name == other.name && this.directives == other.directives;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, directives);

//   static EnumValueDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is EnumValueDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return EnumValueDefinition(
//       name: map['name'] as String,
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'directives': directives?.toJson(),
//     };
//   }
// }

// final inputObjectTypeDefinition = (string('input').trim() &
//         name.trim() &
//         directives.trim().optional() &
//         inputFieldsDefinition.trim().optional())
//     .map((l) {
//   return InputObjectTypeDefinition(
//     name: l[1] as String,
//     directives: l[2] as Directives?,
//     fields: l[3] as InputFieldsDefinition?,
//   );
// }).trim();

// class InputObjectTypeDefinition {
//   final String name;
//   final Directives? directives;
//   final InputFieldsDefinition? fields;

//   @override
//   String toString() {
//     return 'input ${name} ${directives == null ? "" : "${directives!}"} ${fields == null ? "" : "${fields!}"} ';
//   }

//   const InputObjectTypeDefinition({
//     required this.name,
//     this.directives,
//     this.fields,
//   });

//   InputObjectTypeDefinition copyWith({
//     String? name,
//     Directives? directives,
//     InputFieldsDefinition? fields,
//   }) {
//     return InputObjectTypeDefinition(
//       name: name ?? this.name,
//       directives: directives ?? this.directives,
//       fields: fields ?? this.fields,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is InputObjectTypeDefinition) {
//       return this.name == other.name &&
//           this.directives == other.directives &&
//           this.fields == other.fields;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => hashValues(name, directives, fields);

//   static InputObjectTypeDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is InputObjectTypeDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return InputObjectTypeDefinition(
//       name: map['name'] as String,
//       directives: map['directives'] == null
//           ? null
//           : Directives.fromJson(map['directives']),
//       fields: map['fields'] == null
//           ? null
//           : InputFieldsDefinition.fromJson(map['fields']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'directives': directives?.toJson(),
//       'fields': fields?.toJson(),
//     };
//   }
// }

// final inputFieldsDefinition = (char('{').trim() &
//         inputValueDefinition
//             .trim()
//             .separatedBy<InputValueDefinition>(char(',').trim(),
//                 includeSeparators: false, optionalSeparatorAtEnd: true)
//             .trim() &
//         char('}').trim())
//     .map((l) {
//   return InputFieldsDefinition(
//     fields: l[1] as List<InputValueDefinition>,
//   );
// }).trim();

// class InputFieldsDefinition {
//   final List<InputValueDefinition> fields;

//   @override
//   String toString() {
//     return '{ ${fields.join(',')} } ';
//   }

//   const InputFieldsDefinition({
//     required this.fields,
//   });

//   InputFieldsDefinition copyWith({
//     List<InputValueDefinition>? fields,
//   }) {
//     return InputFieldsDefinition(
//       fields: fields ?? this.fields,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is InputFieldsDefinition) {
//       return this.fields == other.fields;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => fields.hashCode;

//   static InputFieldsDefinition fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is InputFieldsDefinition) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return InputFieldsDefinition(
//       fields: (map['fields'] as List)
//           .map((e) => InputValueDefinition.fromJson(e))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'fields': fields.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// final ignored = ((whitespace() | char(',') | comment)).flatten();

// final comment = (char('#') & string('\n').neg().trim()).map((l) {
//   return Comment();
// }).trim();

// class Comment {
//   @override
//   String toString() {
//     return '#\n ';
//   }

//   const Comment();

//   Comment copyWith() {
//     return const Comment();
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Comment) {
//       return true;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => const Comment().hashCode;

//   static Comment fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Comment) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return const Comment();
//   }

//   Map<String, dynamic> toJson() {
//     return {};
//   }
// }

// final sourceCharacter =
//     (patternIgnoreCase('\u0009\u000A\u000D\u0020-\uFFFF')).flatten();

// final stringCharacter = ((sourceCharacter
//             .butNot((char('"').map((_) => SourceNot.doubleQuote) |
//                     string('\\').map((_) => SourceNot.escape) |
//                     string('\n').map((_) => SourceNot.newLine))
//                 .cast<SourceNot>())
//             .map((v) => StringCharacter.source(value: v)) |
//         (string('\\u') & pattern('0-9A-Fa-f').repeat(4, 4)).map((l) {
//           return Unicode();
//         }).map((v) => StringCharacter.unicode(value: v)) |
//         (string('\\') & escapedCharacter)
//             .map((l) {
//               return Escaped(
//                 char: l[1] as String,
//               );
//             })
//             .trim()
//             .map((v) => StringCharacter.escaped(value: v)))
//     .cast<StringCharacter>());

// abstract class StringCharacter {
//   const StringCharacter._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory StringCharacter.source({
//     required String value,
//   }) = StringCharacterSource;
//   const factory StringCharacter.unicode({
//     required Unicode value,
//   }) = StringCharacterUnicode;
//   const factory StringCharacter.escaped({
//     required Escaped value,
//   }) = StringCharacterEscaped;

//   Object get value;

//   _T when<_T>({
//     required _T Function(String value) source,
//     required _T Function(Unicode value) unicode,
//     required _T Function(Escaped value) escaped,
//   }) {
//     final v = this;
//     if (v is StringCharacterSource) {
//       return source(v.value);
//     } else if (v is StringCharacterUnicode) {
//       return unicode(v.value);
//     } else if (v is StringCharacterEscaped) {
//       return escaped(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(String value)? source,
//     _T Function(Unicode value)? unicode,
//     _T Function(Escaped value)? escaped,
//   }) {
//     final v = this;
//     if (v is StringCharacterSource) {
//       return source != null ? source(v.value) : orElse.call();
//     } else if (v is StringCharacterUnicode) {
//       return unicode != null ? unicode(v.value) : orElse.call();
//     } else if (v is StringCharacterEscaped) {
//       return escaped != null ? escaped(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(StringCharacterSource value) source,
//     required _T Function(StringCharacterUnicode value) unicode,
//     required _T Function(StringCharacterEscaped value) escaped,
//   }) {
//     final v = this;
//     if (v is StringCharacterSource) {
//       return source(v);
//     } else if (v is StringCharacterUnicode) {
//       return unicode(v);
//     } else if (v is StringCharacterEscaped) {
//       return escaped(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(StringCharacterSource value)? source,
//     _T Function(StringCharacterUnicode value)? unicode,
//     _T Function(StringCharacterEscaped value)? escaped,
//   }) {
//     final v = this;
//     if (v is StringCharacterSource) {
//       return source != null ? source(v) : orElse.call();
//     } else if (v is StringCharacterUnicode) {
//       return unicode != null ? unicode(v) : orElse.call();
//     } else if (v is StringCharacterEscaped) {
//       return escaped != null ? escaped(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isSource => this is StringCharacterSource;
//   bool get isUnicode => this is StringCharacterUnicode;
//   bool get isEscaped => this is StringCharacterEscaped;

//   static StringCharacter fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is StringCharacter) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'source':
//         return StringCharacterSource.fromJson(map);
//       case 'unicode':
//         return StringCharacterUnicode.fromJson(map);
//       case 'escaped':
//         return StringCharacterEscaped.fromJson(map);
//       default:
//         throw Exception('Invalid discriminator for StringCharacter.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class StringCharacterSource extends StringCharacter {
//   final String value;

//   const StringCharacterSource({
//     required this.value,
//   }) : super._();

//   StringCharacterSource copyWith({
//     String? value,
//   }) {
//     return StringCharacterSource(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is StringCharacterSource) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static StringCharacterSource fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is StringCharacterSource) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return StringCharacterSource(
//       value: map['value'] as String,
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'source',
//       'value': value,
//     };
//   }
// }

// class StringCharacterUnicode extends StringCharacter {
//   final Unicode value;

//   const StringCharacterUnicode({
//     required this.value,
//   }) : super._();

//   StringCharacterUnicode copyWith({
//     Unicode? value,
//   }) {
//     return StringCharacterUnicode(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is StringCharacterUnicode) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static StringCharacterUnicode fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is StringCharacterUnicode) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return StringCharacterUnicode(
//       value: Unicode.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'unicode',
//       'value': value.toJson(),
//     };
//   }
// }

// class StringCharacterEscaped extends StringCharacter {
//   final Escaped value;

//   const StringCharacterEscaped({
//     required this.value,
//   }) : super._();

//   StringCharacterEscaped copyWith({
//     Escaped? value,
//   }) {
//     return StringCharacterEscaped(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is StringCharacterEscaped) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static StringCharacterEscaped fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is StringCharacterEscaped) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return StringCharacterEscaped(
//       value: Escaped.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'escaped',
//       'value': value.toJson(),
//     };
//   }
// }

// class SourceNot {
//   final String _inner;

//   const SourceNot._(this._inner);

//   static const doubleQuote = SourceNot._('"');
//   static const escape = SourceNot._('\\');
//   static const newLine = SourceNot._('\n');

//   static const values = [
//     SourceNot.doubleQuote,
//     SourceNot.escape,
//     SourceNot.newLine,
//   ];

//   static SourceNot fromJson(Object? json) {
//     if (json == null) {
//       throw Error();
//     }
//     for (final v in values) {
//       if (json.toString() == v._inner) {
//         return v;
//       }
//     }
//     throw Error();
//   }

//   String toJson() {
//     return _inner;
//   }

//   @override
//   String toString() {
//     return _inner;
//   }

//   @override
//   bool operator ==(Object other) {
//     return other is SourceNot &&
//         other.runtimeType == runtimeType &&
//         other._inner == _inner;
//   }

//   @override
//   int get hashCode => _inner.hashCode;

//   bool get isDoubleQuote => this == SourceNot.doubleQuote;
//   bool get isEscape => this == SourceNot.escape;
//   bool get isNewLine => this == SourceNot.newLine;

//   _T when<_T>({
//     required _T Function() doubleQuote,
//     required _T Function() escape,
//     required _T Function() newLine,
//   }) {
//     switch (this._inner) {
//       case '"':
//         return doubleQuote();
//       case '\\':
//         return escape();
//       case '\n':
//         return newLine();
//     }
//     throw Error();
//   }

//   _T maybeWhen<_T>({
//     _T Function()? doubleQuote,
//     _T Function()? escape,
//     _T Function()? newLine,
//     required _T Function() orElse,
//   }) {
//     _T Function()? c;
//     switch (this._inner) {
//       case '"':
//         c = doubleQuote;
//         break;
//       case '\\':
//         c = escape;
//         break;
//       case '\n':
//         c = newLine;
//         break;
//     }
//     return (c ?? orElse).call();
//   }
// }

// class Unicode {
//   @override
//   String toString() {
//     return '\\u0-9A-Fa-f';
//   }

//   const Unicode();

//   Unicode copyWith() {
//     return const Unicode();
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Unicode) {
//       return true;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => const Unicode().hashCode;

//   static Unicode fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Unicode) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return const Unicode();
//   }

//   Map<String, dynamic> toJson() {
//     return {};
//   }
// }

// class Escaped {
//   final String char;

//   @override
//   String toString() {
//     return '\\${char}';
//   }

//   const Escaped({
//     required this.char,
//   });

//   Escaped copyWith({
//     String? char,
//   }) {
//     return Escaped(
//       char: char ?? this.char,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Escaped) {
//       return this.char == other.char;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => char.hashCode;

//   static Escaped fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Escaped) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Escaped(
//       char: map['char'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'char': char,
//     };
//   }
// }

// final escapedCharacter = ((char('"') |
//         string('\\') |
//         char('/') |
//         char('b') |
//         char('f') |
//         char('n') |
//         char('r') |
//         char('t')))
//     .flatten();

// final stringValue = ((char('"') & stringCharacter.star() & char('"')).map((l) {
//           return Line(
//             str: l[1] as List<StringCharacter>?,
//           );
//         }).map((v) => StringValue.line(value: v)) |
//         (string('"""') & blockStringCharacter & string('"""')).map((l) {
//           return Block(
//             str: l[1] as BlockStringCharacter,
//           );
//         }).map((v) => StringValue.block(value: v)))
//     .cast<StringValue>();

// abstract class StringValue {
//   const StringValue._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory StringValue.line({
//     required Line value,
//   }) = stringValueLine;
//   const factory StringValue.block({
//     required Block value,
//   }) = stringValueBlock;

//   Object get value;

//   _T when<_T>({
//     required _T Function(Line value) line,
//     required _T Function(Block value) block,
//   }) {
//     final v = this;
//     if (v is stringValueLine) {
//       return line(v.value);
//     } else if (v is stringValueBlock) {
//       return block(v.value);
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function(Line value)? line,
//     _T Function(Block value)? block,
//   }) {
//     final v = this;
//     if (v is stringValueLine) {
//       return line != null ? line(v.value) : orElse.call();
//     } else if (v is stringValueBlock) {
//       return block != null ? block(v.value) : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(stringValueLine value) line,
//     required _T Function(stringValueBlock value) block,
//   }) {
//     final v = this;
//     if (v is stringValueLine) {
//       return line(v);
//     } else if (v is stringValueBlock) {
//       return block(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(stringValueLine value)? line,
//     _T Function(stringValueBlock value)? block,
//   }) {
//     final v = this;
//     if (v is stringValueLine) {
//       return line != null ? line(v) : orElse.call();
//     } else if (v is stringValueBlock) {
//       return block != null ? block(v) : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isLine => this is stringValueLine;
//   bool get isBlock => this is stringValueBlock;

//   static StringValue fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is StringValue) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'line':
//         return stringValueLine.fromJson(map);
//       case 'block':
//         return stringValueBlock.fromJson(map);
//       default:
//         throw Exception('Invalid discriminator for StringValue.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class stringValueLine extends StringValue {
//   final Line value;

//   const stringValueLine({
//     required this.value,
//   }) : super._();

//   stringValueLine copyWith({
//     Line? value,
//   }) {
//     return stringValueLine(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is stringValueLine) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static stringValueLine fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is stringValueLine) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return stringValueLine(
//       value: Line.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'line',
//       'value': value.toJson(),
//     };
//   }
// }

// class stringValueBlock extends StringValue {
//   final Block value;

//   const stringValueBlock({
//     required this.value,
//   }) : super._();

//   stringValueBlock copyWith({
//     Block? value,
//   }) {
//     return stringValueBlock(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is stringValueBlock) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static stringValueBlock fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is stringValueBlock) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return stringValueBlock(
//       value: Block.fromJson(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'block',
//       'value': value.toJson(),
//     };
//   }
// }

// class Line {
//   final List<StringCharacter>? str;

//   @override
//   String toString() {
//     return '"${str == null ? "" : "${str!.join(" ")}"}"';
//   }

//   const Line({
//     this.str,
//   });

//   Line copyWith({
//     List<StringCharacter>? str,
//   }) {
//     return Line(
//       str: str ?? this.str,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Line) {
//       return this.str == other.str;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => str.hashCode;

//   static Line fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Line) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Line(
//       str: map['str'] == null
//           ? null
//           : List.fromJson<StringCharacter>(map['str']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'str': str?.toJson(),
//     };
//   }
// }

// class Block {
//   final BlockStringCharacter str;

//   @override
//   String toString() {
//     return '"""${str}"""';
//   }

//   const Block({
//     required this.str,
//   });

//   Block copyWith({
//     BlockStringCharacter? str,
//   }) {
//     return Block(
//       str: str ?? this.str,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is Block) {
//       return this.str == other.str;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => str.hashCode;

//   static Block fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is Block) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return Block(
//       str: BlockStringCharacter.fromJson(map['str']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'str': str.toJson(),
//     };
//   }
// }

// final blockStringCharacter = ((sourceCharacter
//             .butNot((string('"""')
//                         .map((_) => SourceNotBlock.tripleDoubleQuote) |
//                     string('\"""')
//                         .map((_) => SourceNotBlock.escapedTripleDoubleQuote))
//                 .cast<SourceNotBlock>())
//             .map((v) => BlockStringCharacter.source(value: v)) |
//         string('\"""').map(
//             (v) => BlockStringCharacter.escapedTripleDoubleQuote(value: v)))
//     .cast<BlockStringCharacter>());

// abstract class BlockStringCharacter {
//   const BlockStringCharacter._();

//   @override
//   String toString() {
//     return value.toString();
//   }

//   const factory BlockStringCharacter.source({
//     required String value,
//   }) = BlockStringCharacterSource;
//   const factory BlockStringCharacter.escapedTripleDoubleQuote({
//     required String value,
//   }) = BlockStringCharacterEscapedTripleDoubleQuote;

//   String get value;

//   _T when<_T>({
//     required _T Function() source,
//     required _T Function() escapedTripleDoubleQuote,
//   }) {
//     final v = this;
//     if (v is BlockStringCharacterSource) {
//       return source();
//     } else if (v is BlockStringCharacterEscapedTripleDoubleQuote) {
//       return escapedTripleDoubleQuote();
//     }
//     throw Exception();
//   }

//   _T maybeWhen<_T>({
//     required _T Function() orElse,
//     _T Function()? source,
//     _T Function()? escapedTripleDoubleQuote,
//   }) {
//     final v = this;
//     if (v is BlockStringCharacterSource) {
//       return source != null ? source() : orElse.call();
//     } else if (v is BlockStringCharacterEscapedTripleDoubleQuote) {
//       return escapedTripleDoubleQuote != null
//           ? escapedTripleDoubleQuote()
//           : orElse.call();
//     }
//     throw Exception();
//   }

//   _T map<_T>({
//     required _T Function(BlockStringCharacterSource value) source,
//     required _T Function(BlockStringCharacterEscapedTripleDoubleQuote value)
//         escapedTripleDoubleQuote,
//   }) {
//     final v = this;
//     if (v is BlockStringCharacterSource) {
//       return source(v);
//     } else if (v is BlockStringCharacterEscapedTripleDoubleQuote) {
//       return escapedTripleDoubleQuote(v);
//     }
//     throw Exception();
//   }

//   _T maybeMap<_T>({
//     required _T Function() orElse,
//     _T Function(BlockStringCharacterSource value)? source,
//     _T Function(BlockStringCharacterEscapedTripleDoubleQuote value)?
//         escapedTripleDoubleQuote,
//   }) {
//     final v = this;
//     if (v is BlockStringCharacterSource) {
//       return source != null ? source(v) : orElse.call();
//     } else if (v is BlockStringCharacterEscapedTripleDoubleQuote) {
//       return escapedTripleDoubleQuote != null
//           ? escapedTripleDoubleQuote(v)
//           : orElse.call();
//     }
//     throw Exception();
//   }

//   bool get isSource => this is BlockStringCharacterSource;
//   bool get isEscapedTripleDoubleQuote =>
//       this is BlockStringCharacterEscapedTripleDoubleQuote;

//   static BlockStringCharacter fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is BlockStringCharacter) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     switch (map['runtimeType'] as String) {
//       case 'source':
//         return BlockStringCharacterSource.fromJson(map);
//       case 'escapedTripleDoubleQuote':
//         return BlockStringCharacterEscapedTripleDoubleQuote.fromJson(map);
//       default:
//         throw Exception(
//             'Invalid discriminator for BlockStringCharacter.fromJson '
//             '${map["runtimeType"]}. Input map: $map');
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// class BlockStringCharacterSource extends BlockStringCharacter {
//   final String value;

//   const BlockStringCharacterSource({
//     required this.value,
//   }) : super._();

//   BlockStringCharacterSource copyWith({
//     String? value,
//   }) {
//     return BlockStringCharacterSource(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is BlockStringCharacterSource) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static BlockStringCharacterSource fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is BlockStringCharacterSource) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return BlockStringCharacterSource(
//       value: map['value'] as String,
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'source',
//       'value': value,
//     };
//   }
// }

// class BlockStringCharacterEscapedTripleDoubleQuote
//     extends BlockStringCharacter {
//   final String value;

//   const BlockStringCharacterEscapedTripleDoubleQuote({
//     required this.value,
//   }) : super._();

//   BlockStringCharacterEscapedTripleDoubleQuote copyWith({
//     String? value,
//   }) {
//     return BlockStringCharacterEscapedTripleDoubleQuote(
//       value: value ?? this.value,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (other is BlockStringCharacterEscapedTripleDoubleQuote) {
//       return this.value == other.value;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => value.hashCode;

//   static BlockStringCharacterEscapedTripleDoubleQuote fromJson(Object? _map) {
//     final Map<String, dynamic> map;
//     if (_map is BlockStringCharacterEscapedTripleDoubleQuote) {
//       return _map;
//     } else if (_map is String) {
//       map = jsonDecode(_map) as Map<String, dynamic>;
//     } else {
//       map = (_map! as Map).cast();
//     }

//     return BlockStringCharacterEscapedTripleDoubleQuote(
//       value: map['value'] as String,
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'runtimeType': 'escapedTripleDoubleQuote',
//       'value': value,
//     };
//   }
// }

// class SourceNotBlock {
//   final String _inner;

//   const SourceNotBlock._(this._inner);

//   static const tripleDoubleQuote = SourceNotBlock._('"""');
//   static const escapedTripleDoubleQuote = SourceNotBlock._('\"""');

//   static const values = [
//     SourceNotBlock.tripleDoubleQuote,
//     SourceNotBlock.escapedTripleDoubleQuote,
//   ];

//   static SourceNotBlock fromJson(Object? json) {
//     if (json == null) {
//       throw Error();
//     }
//     for (final v in values) {
//       if (json.toString() == v._inner) {
//         return v;
//       }
//     }
//     throw Error();
//   }

//   String toJson() {
//     return _inner;
//   }

//   @override
//   String toString() {
//     return _inner;
//   }

//   @override
//   bool operator ==(Object other) {
//     return other is SourceNotBlock &&
//         other.runtimeType == runtimeType &&
//         other._inner == _inner;
//   }

//   @override
//   int get hashCode => _inner.hashCode;

//   bool get isTripleDoubleQuote => this == SourceNotBlock.tripleDoubleQuote;
//   bool get isEscapedTripleDoubleQuote =>
//       this == SourceNotBlock.escapedTripleDoubleQuote;

//   _T when<_T>({
//     required _T Function() tripleDoubleQuote,
//     required _T Function() escapedTripleDoubleQuote,
//   }) {
//     switch (this._inner) {
//       case '"""':
//         return tripleDoubleQuote();
//       case '\"""':
//         return escapedTripleDoubleQuote();
//     }
//     throw Error();
//   }

//   _T maybeWhen<_T>({
//     _T Function()? tripleDoubleQuote,
//     _T Function()? escapedTripleDoubleQuote,
//     required _T Function() orElse,
//   }) {
//     _T Function()? c;
//     switch (this._inner) {
//       case '"""':
//         c = tripleDoubleQuote;
//         break;
//       case '\"""':
//         c = escapedTripleDoubleQuote;
//         break;
//     }
//     return (c ?? orElse).call();
//   }
// }
// void main() {
//   final r = definition.parse('''
//   { de: d3s (cc : 2, ll : \$s, cc: -1.3) @ fef }
  
//   ''');

//   print(r);

//   const f = Definition(
//     executable: ExecutableDefinition(
//       operation: OperationDefinition.op(
//         value: Op(
//           operationType: OpOperationType.subscription,
//           name: 'de',
//           selection: SelectionSet(
//             selection: [
//               Selection.field(
//                 value: Field(
//                   name: 'name',
//                   arguments: Arguments(
//                     arguments: [
//                       Argument(
//                         name: 'vvv',
//                         value: Value.boolean(
//                           value: BoolValue.true_,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Selection.fragmentSpread(
//                 value: FragmentSpread(
//                   name: 'da',
//                   directives: Directives(
//                     directives: [Directive(name: 'da')],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
//   print(f);
// }
