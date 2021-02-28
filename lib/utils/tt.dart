// import 'package:meta/meta.dart';

// abstract class Texts<V, E> {
//   const Texts._();

//   const factory Texts.success({
//     @required V value,
//   }) = Success;
//   const factory Texts.loading({
//     V cached,
//   }) = Loading;
//   const factory Texts.error(
//     E error,
//   ) = Error;

//   _T when<_T>({
//     @required _T Function(V value) success,
//     @required _T Function(V cached) loading,
//     @required _T Function(E error) error,
//   }) {
//     final v = this;
//     if (v is Success<V, E>) return success(v.value);
//     if (v is Loading<V, E>) return loading(v.cached);
//     if (v is Error<V, E>) return error(v.error);
//     throw "";
//   }

//   _T maybeWhen<_T>({
//     @required _T Function() orElse,
//     _T Function(V value) success,
//     _T Function(V cached) loading,
//     _T Function(E error) error,
//   }) {
//     final v = this;
//     if (v is Success<V, E>)
//       return success != null ? success(v.value) : orElse.call();
//     if (v is Loading<V, E>)
//       return loading != null ? loading(v.cached) : orElse.call();
//     if (v is Error<V, E>) return error != null ? error(v.error) : orElse.call();
//     throw "";
//   }

//   _T map<_T>({
//     @required _T Function(Success<V, E> value) success,
//     @required _T Function(Loading<V, E> value) loading,
//     @required _T Function(Error<V, E> value) error,
//   }) {
//     final v = this;
//     if (v is Success<V, E>) return success(v);
//     if (v is Loading<V, E>) return loading(v);
//     if (v is Error<V, E>) return error(v);
//     throw "";
//   }

//   _T maybeMap<_T>({
//     @required _T Function() orElse,
//     _T Function(Success<V, E> value) success,
//     _T Function(Loading<V, E> value) loading,
//     _T Function(Error<V, E> value) error,
//   }) {
//     final v = this;
//     if (v is Success<V, E>) return success != null ? success(v) : orElse.call();
//     if (v is Loading<V, E>) return loading != null ? loading(v) : orElse.call();
//     if (v is Error<V, E>) return error != null ? error(v) : orElse.call();
//     throw "";
//   }

//   bool get isSuccess => this is Success;
//   bool get isLoading => this is Loading;
//   bool get isError => this is Error;

//   TypeTexts get typeEnum;

//   Texts<_T, E> mapGenericV<_T>(_T Function(V) mapper) {
//     return map(
//       success: (v) => Texts.success(value: mapper(v.value)),
//       loading: (v) => Texts.loading(cached: mapper(v.cached)),
//       error: (v) => Texts.error(v.error),
//     );
//   }

//   Texts<V, _T> mapGenericE<_T>(_T Function(E) mapper) {
//     return map(
//       success: (v) => Texts.success(value: v.value),
//       loading: (v) => Texts.loading(cached: v.cached),
//       error: (v) => Texts.error(mapper(v.error)),
//     );
//   }

//   static Texts<V, E> fromJson<V, E>(Map<String, dynamic> map) {
//     switch (map["runtimeType"] as String) {
//       case "Success":
//         return Success.fromJson<V, E>(map);
//       case "Loading":
//         return Loading.fromJson<V, E>(map);
//       case "Error":
//         return Error.fromJson<V, E>(map);
//       default:
//         return null;
//     }
//   }

//   Map<String, dynamic> toJson();
// }

// enum TypeTexts {
//   success,
//   loading,
//   error,
// }

// TypeTexts parseTypeTexts(String rawString, {TypeTexts defaultValue}) {
//   for (final variant in TypeTexts.values) {
//     if (rawString == variant.toEnumString()) {
//       return variant;
//     }
//   }
//   return defaultValue;
// }

// extension TypeTextsExtension on TypeTexts {
//   String toEnumString() => toString().split(".")[1];
//   String enumType() => toString().split(".")[0];

//   bool get isSuccess => this == TypeTexts.success;
//   bool get isLoading => this == TypeTexts.loading;
//   bool get isError => this == TypeTexts.error;

//   _T when<_T>({
//     @required _T Function() success,
//     @required _T Function() loading,
//     @required _T Function() error,
//   }) {
//     switch (this) {
//       case TypeTexts.success:
//         return success();
//       case TypeTexts.loading:
//         return loading();
//       case TypeTexts.error:
//         return error();
//     }
//     throw "";
//   }

//   _T maybeWhen<_T>({
//     _T Function() success,
//     _T Function() loading,
//     _T Function() error,
//     @required _T Function() orElse,
//   }) {
//     _T Function() c;
//     switch (this) {
//       case TypeTexts.success:
//         c = success;
//         break;
//       case TypeTexts.loading:
//         c = loading;
//         break;
//       case TypeTexts.error:
//         c = error;
//         break;
//     }
//     return (c ?? orElse).call();
//   }
// }

// class Success<V, E> extends Texts<V, E> {
//   final V value;

//   const Success({
//     @required this.value,
//   }) : super._();

//   @override
//   TypeTexts get typeEnum => TypeTexts.success;

//   static Success<V, E> fromJson<V, E>(Map<String, dynamic> map) {
//     return Success(
//       value: Serializers.fromJson<V>(map['value']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       "runtimeType": "Success",
//       "value": (value as dynamic).toJson(),
//     };
//   }
// }

// class Loading<V, E> extends Texts<V, E> {
//   final V cached;

//   const Loading({
//     this.cached,
//   }) : super._();

//   @override
//   TypeTexts get typeEnum => TypeTexts.loading;

//   static Loading<V, E> fromJson<V, E>(Map<String, dynamic> map) {
//     return Loading(
//       cached: Serializers.fromJson<V>(map['cached']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       "runtimeType": "Loading",
//       "cached": (cached as dynamic).toJson(),
//     };
//   }
// }

// class Error<V, E> extends Texts<V, E> {
//   final E error;

//   const Error(
//     this.error,
//   ) : super._();

//   @override
//   TypeTexts get typeEnum => TypeTexts.error;

//   static Error<V, E> fromJson<V, E>(Map<String, dynamic> map) {
//     return Error(
//       Serializers.fromJson<E>(map['error']),
//     );
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       "runtimeType": "Error",
//       "error": (error as dynamic).toJson(),
//     };
//   }
// }
