import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:snippet_generator/models/props_serializable.dart';
import 'package:snippet_generator/models/rebuilder.dart';
import 'package:snippet_generator/models/serializer.dart';

class AppNotifier<T> implements ValueListenable<T>, SerializableProp {
  @override
  String get name => observable.name;

  final bool isRequired;
  final Observable<T> observable;
  final _subs = <void Function(), _ListenerCount>{};

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
    bool? isRequired,
  })  : isRequired = isRequired ?? false,
        observable = Observable(value, name: name) {
    // parent?.registerValue(this);
  }

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
  void addListener(VoidCallback listener) {
    final cancel = observable.observe((_) {
      listener();
    });
    final count = _subs[listener] ?? _ListenerCount(cancel, 0);
    count.count += 1;
    _subs[listener] = count;
  }

  @override
  void removeListener(VoidCallback listener) {
    final count = _subs[listener];
    if (count != null) {
      count.count -= 1;
      if (count.count == 0) {
        count.cancel();
        _subs.remove(listener);
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
    bool? isRequired,
  })  : controller = TextEditingController(text: initialText),
        super(initialText ?? '', name: name, isRequired: isRequired) {
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
