import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useValueListenableEffect<T>(
  void Function(T) callback,
  ValueListenable<T> listenable, [
  List<Object>? keys,
]) {
  useEffect(
    () {
      void _c() {
        callback(listenable.value);
      }

      listenable.addListener(_c);
      return () => listenable.removeListener(_c);
    },
    keys,
  );
}

void useStreamEffect<T>(
  void Function(T) callback,
  Stream<T> listenable, [
  List<Object>? keys,
]) {
  useEffect(
    () {
      final subs = listenable.listen(callback);
      return subs.cancel;
    },
    keys,
  );
}