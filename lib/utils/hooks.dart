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

T useSelectListenable<T>(
  Listenable listenable,
  T Function() select, [
  List<Object?> keys = const [],
]) {
  final state = useState<T>(select());
  useEffect(() {
    void _callback() {
      state.value = select();
    }

    listenable.addListener(_callback);
    return () {
      listenable.removeListener(_callback);
    };
  }, [listenable, ...keys]);
  return state.value;
}
