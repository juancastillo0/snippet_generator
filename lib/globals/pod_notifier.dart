import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PodValue<T> implements ValueListenable<T> {
  // ignore: avoid_setters_without_getters
  set value(T newValue);
}

class PodValueListenable<T> implements PodValue<T> {
  final ValueNotifier<T> listenable;

  PodValueListenable(this.listenable);

  @override
  void addListener(VoidCallback listener) {
    listenable.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listenable.removeListener(listener);
  }

  @override
  T get value => listenable.value;

  @override
  set value(T newValue) {
    listenable.value = newValue;
  }
}

class Pod<T> {
  final PodValue<T> Function() create;
  final bool autoDispose;

  const Pod(this.create, {this.autoDispose = false});

  factory Pod.notifier(T initialValue) {
    return Pod(() => PodValueListenable(ValueNotifier(initialValue)));
  }

  PodValue<T> subscribe(BuildContext context) {
    return RootProviderState.of(context, this);
  }
}

class RootNotifier extends StatelessWidget {
  const RootNotifier({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: RootProviderState.updatedStream.stream,
      initialData: true,
      builder: (context, snapshot) {
        return _RootNotifierInherited(
          updated: RootProviderState.updated(),
          child: child,
        );
      },
    );
  }
}

class PodSubscription<T> {
  final Set<BuildContext> subs = {};
  final PodValue<T> podValue;

  PodSubscription(this.podValue);
}

class RootProviderState {
  static final updatedStream = StreamController<bool>();

  static Set<Pod> _toUpdate = {};

  static Set<Pod> updated() {
    final _updated = _toUpdate;
    _toUpdate = {};
    return _updated;
  }

  static final _subsMap = <Pod, PodSubscription>{};

  static bool _isMounted(BuildContext context) {
    bool mounted = false;
    try {
      context.widget;
      mounted = true;
    } catch (_) {}
    return mounted;
  }

  static PodSubscription<T> _subscribe<T>(Pod<T> pod) {
    final __sub = _subsMap[pod] as PodSubscription<T>?;
    if (__sub != null) {
      if (!pod.autoDispose || __sub.subs.any(_isMounted)) {
        return __sub;
      }
      // TODO: autoDispose
    }
    final _sub = PodSubscription(pod.create());

    void _callback() {
      if (_toUpdate.contains(pod)) {
        return;
      }
      final List<BuildContext> _toDelete =
          _sub.subs.where((context) => !_isMounted(context)).toList();
      _sub.subs.removeAll(_toDelete);

      if (_sub.subs.isNotEmpty) {
        _toUpdate.add(pod);
        updatedStream.add(true);
      } else {
        _subsMap.remove(pod);
        _sub.podValue.removeListener(_callback);
      }
    }

    _subsMap[pod] = _sub;
    _sub.podValue.addListener(_callback);
    return _sub;
  }

  static PodValue<T> of<T>(BuildContext context, Pod<T> pod) {
    InheritedModel.inheritFrom<_RootNotifierInherited>(
      context,
      aspect: pod,
    )!;

    final _sub = _subscribe<T>(pod);
    _sub.subs.add(context);
    return _sub.podValue;
  }
}

class _RootNotifierInherited extends InheritedModel<Pod> {
  const _RootNotifierInherited({
    required this.updated,
    required Widget child,
    Key? key,
  }) : super(child: child, key: key);

  final Set<Pod> updated;

  @override
  InheritedModelElement<Pod> createElement() => InheModel<Pod>(this);

  @override
  bool updateShouldNotify(_RootNotifierInherited oldWidget) {
    return updated.isNotEmpty;
  }

  @override
  bool updateShouldNotifyDependent(
      _RootNotifierInherited oldWidget, Set<Pod> dependencies) {
    return dependencies.any((dep) => updated.contains(dep));
  }
}

class InheModel<T> extends InheritedModelElement<T> {
  InheModel(InheritedModel<T> widget) : super(widget);

  final Map<Element, Object?> __dependents = HashMap<Element, Object?>();

  Map<Element, Object?> get _dependents {
    print("__dependents");
    return __dependents;
  }
}
