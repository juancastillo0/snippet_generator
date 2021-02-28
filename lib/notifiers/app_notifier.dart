import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:snippet_generator/models/rebuilder.dart';
import 'package:snippet_generator/models/serializer.dart';

class AppNotifier<T> implements ValueListenable<T > {
  String get name => observable.name;

  final bool required;
  final Observable<T > observable;
  final _subs = <void Function(), void Function()>{};

  @override
  T get value {
    RebuilderGlobalScope.instance.addToScope(this);
    return observable.value;
  }

  set value(T value) => runInAction(
        () => observable.value = value,
        name: "${name}Setter",
      );

  void set(T value) => this.value = value;

  AppNotifier(
    T value, {
    dynamic parent,
    String? name,
    bool? required,
  })  : required = required ?? true,
        observable = Observable(value, name: name) {
    // parent?.registerValue(this);
  }

  Object? toJson() {
    return Serializers.toJson<T>(this.value);
  }

  bool trySetFromMap(Map<String, dynamic> map, {bool mutate = true}) {
    if (map.containsKey(this.name)) {
      return this._trySet(map[this.name], mutate: mutate);
    }
    return !this.required;
  }

  bool _trySet(dynamic value, {bool mutate = true}) {
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
  void addListener(VoidCallback listener) {
    if (!_subs.containsKey(listener)) {
      final cancel = observable.observe((_) {
        listener();
      });
      _subs[listener] = cancel;
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    _subs.remove(listener)?.call();
  }
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
    dynamic parent,
    String? name,
    bool? required,
  })  : controller = TextEditingController(text: initialText),
        super(initialText ?? '', name: name, required: required) {
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
  String get text => controller.text;
}
