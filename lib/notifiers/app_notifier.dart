import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart' hide Listenable;
import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/notifiers/rebuilder.dart';
import 'package:snippet_generator/globals/serializer.dart';
import 'package:snippet_generator/fields/fields.dart';

class AppNotifier<T>
    with ListenableFromObservable
    implements ValueListenable<T>, SerializableProp, PropClass<T> {
  @override
  String get name => observable.name;
  @override
  Type get type => T;

  final bool isRequired;
  final Observable<T> observable;

  @override
  T get value {
    RebuilderGlobalScope.instance.addToScope(this);
    return observable.value;
  }

  set value(T value) {
    runInAction(
      () => observable.value = value,
      name: "${name}Setter",
    );
  }

  @override
  void set(T value) => this.value = value;

  AppNotifier(
    T value, {
    dynamic parent,
    String? name,
    bool? isRequired,
  })  : isRequired = isRequired ?? false,
        observable = Observable(value, name: name) {
    // parent?.registerValue(this);
  }

  static AppNotifierWithDefault<T> withDefault<T>(
    T Function() computeDefault, {
    required String name,
  }) =>
      AppNotifierWithDefault<T>(computeDefault: computeDefault, name: name);

  @override
  Object? toJson() {
    return Serializers.toJson<T>(this.value);
  }

  // bool trySetFromMap(Map<String, dynamic> map, {bool mutate = true}) {
  //   if (map.containsKey(this.name)) {
  //     return this._trySet(map[this.name], mutate: mutate);
  //   }
  //   return !this.isRequired;
  // }

  @override
  bool trySetFromJson(Object? value, {bool mutate = true}) {
    try {
      final _value = Serializers.fromJson<T>(value);
      if (mutate) {
        this.value = _value;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void Function() Function(void Function(dynamic)) get observeFunction =>
      observable.observe;
}

mixin ListenableFromObservable implements Listenable {
  void Function() Function(void Function(dynamic)) get observeFunction;

  final _subsListenableFromObservable = <void Function(), _ListenerCount>{};

  @override
  void addListener(VoidCallback listener) {
    final cancel = observeFunction((_) {
      listener();
    });
    final count =
        _subsListenableFromObservable[listener] ?? _ListenerCount(cancel, 0);
    count.count += 1;
    _subsListenableFromObservable[listener] = count;
  }

  @override
  void removeListener(VoidCallback listener) {
    final count = _subsListenableFromObservable[listener];
    if (count != null) {
      count.count -= 1;
      if (count.count == 0) {
        count.cancel();
        _subsListenableFromObservable.remove(listener);
      }
    }
  }
}

class _ListenerCount {
  int count;
  final void Function() cancel;

  _ListenerCount(
    this.cancel,
    this.count,
  );
}

class AppNotifierWithDefault<T> extends AppNotifier<T?> {
  final T Function() computeDefault;
  AppNotifierWithDefault({
    required String name,
    required this.computeDefault,
  }) : super(null, name: name);

  @override
  T get value => computedValue.value;

  @override
  void Function() Function(void Function(dynamic)) get observeFunction =>
      computedValue.observe;

  late final Computed<T> computedValue = Computed<T>(() {
    final _def = computeDefault();
    return this.observable.value ?? _def;
  });
}
// extension ValueNotifierSetter<T> on ValueNotifier<T> {
//   void set(T value) {
//     this.value = value;
//   }

//   Computed<B> map<B>(B Function(T) mapper) {
//     return Computed<B>(() => mapper(value), [this]);
//   }
// }

class TextNotifier extends AppNotifier<String> {
  TextNotifier({
    String? initialText,
    TextEditingController? controller,
    dynamic parent,
    String? name,
    bool? isRequired,
  })  : controller = controller ?? TextEditingController(text: initialText),
        super(controller?.text ?? initialText ?? '', name: name, isRequired: isRequired) {
    _init();
  }

  void _init() {
    controller.addListener(() {
      if (this.value != controller.text) {
        this.value = controller.text;
      }
    });
    this.addListener(() {
      if (this.value != controller.text) {
        controller.value = controller.value.copyWith(text: this.value);
      }
    });
  }

  final TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  AppNotifier<String> get textNotifier => this;
  String get text => value;
}
