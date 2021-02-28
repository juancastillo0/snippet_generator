import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/models/rebuilder.dart';

class ComputedNotifier<T> extends ComputedNotifierBase<T> {
  ComputedNotifier(
    this._computer,
    List<Listenable> dependencies, {
    this.derivedDependencies,
  }) : super(dependencies);

  final T Function() _computer;
  @override
  final Iterable<Listenable> Function()? derivedDependencies;

  @override
  T computer() {
    return this._computer();
  }
}

T useComputed<T>(
  T Function() compute,
  List<Listenable> dependencies, [
  List<Object?> keys = const <Object>[],
]) {
  final _computed = useMemoized(
    () => ComputedNotifier<T>(compute, dependencies),
    [...dependencies, ...keys],
  );
  useListenable(_computed);
  useEffect(() {
    return _computed.dispose;
  }, [_computed]);
  return _computed.value;
}

abstract class ComputedNotifierBase<T> extends ChangeNotifier
    implements ValueListenable<T> {
  ComputedNotifierBase([List<Listenable>? _primaryDependencyList]) {
    _primaryDependencies = Listenable.merge(
      _primaryDependencyList ?? dependencies!,
    );

    if (derivedDependencies != null) {
      _calculateDependencies();
      _primaryDependencies!.addListener(_calculateDependencies);
    } else {
      _dependencies = _primaryDependencies;
    }
  }

  T computer();
  Iterable<Listenable> Function()? get derivedDependencies => null;
  List<Listenable>? get dependencies => null;

  Listenable? _primaryDependencies;
  Listenable? _dependencies;
  bool _isUpToDate = false;
  bool _isListening = false;
  T? _value;

  @override
  T get value {
    RebuilderGlobalScope.instance.addToScope(this);
    if (!_isUpToDate) {
      _listenDependencies();
      _updateValue(initial: true);
      _isUpToDate = true;
    }
    return _value!;
  }

  void _compute() {
    if (!hasListeners) {
      _isUpToDate = false;
      _stopListeningDependencies();
    } else {
      _updateValue(initial: false);
      _isUpToDate = true;
    }
  }

  @override
  void addListener(void Function() listener) {
    if (!hasListeners) {
      _listenDependencies();
    }
    super.addListener(listener);
  }

  //
  //

  void _updateValue({required bool initial}) {
    final newValue = computer();
    if (_value != newValue) {
      _value = newValue;
      if (!initial) {
        notifyListeners();
      }
    }
  }

  void _listenDependencies() {
    if (!_isListening) {
      _dependencies!.addListener(_compute);
      _isListening = true;
    }
  }

  void _stopListeningDependencies() {
    if (_isListening) {
      _dependencies!.removeListener(_compute);
      _isListening = false;
    }
  }

  void _calculateDependencies() {
    final deps = Listenable.merge(
      [_primaryDependencies, ...derivedDependencies!()],
    );
    if (_isListening) {
      _compute();
      final wasListening = _isListening;
      _stopListeningDependencies();
      _dependencies = deps;
      if (wasListening) {
        _listenDependencies();
      }
    } else {
      _dependencies = deps;
    }
  }

  @override
  void dispose() {
    _stopListeningDependencies();
    if (derivedDependencies != null) {
      _primaryDependencies!.removeListener(_calculateDependencies);
    }
    super.dispose();
  }
}
