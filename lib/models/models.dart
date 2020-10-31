import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Globals {
  static final _map = <Type, Object>{};

  static void add<T>(T value) {
    _map[T] = value;
  }

  static T get<T>() {
    return _map[T] as T;
  }
}

// class NestedNotifier extends ChangeNotifier {
//   final _notifiers = <AppNotifier>[];
//   final _nestedNotifiers = <NestedNotifier>[];

//   Computed<Listenable> _deepListenable;
//   Listenable get deepListenable => _deepListenable?.value ?? _listenable;

//   Listenable _listenable;
//   Listenable get listenable => _listenable;

//   NestedNotifier({NestedNotifier parent}) {
//     parent?.registerNested(this);

//     _listenable = Listenable.merge([
//       isEnumNotifier,
//       isDataValueNotifier,
//       isSumTypeNotifier,
//       isSerializableNotifier,
//       isListenableNotifier,
//       nameNotifier,
//       classes,
//       defaultEnumNotifier
//     ]);
//   }

//   void register(AppNotifier notifier) {
//     _notifiers.add(notifier);
//     notifier.addListener(notifyListeners);
//   }

//   void registerNested(NestedNotifier notifier) {
//     _nestedNotifiers.add(notifier);
//     _deepListenable = Computed(_setUpDeepListenable, _nestedNotifiers);
//   }

//   var __s = <NestedNotifier, Computed<Listenable>>{};
//   Listenable _setUpDeepListenable() {
//     for (final nested in _nestedNotifiers) {
//       final _s = classes.map((e) => e._deepListenable).toSet();

//       __s.difference(_s).forEach((element) {
//         element.removeListener(_setUpDeepListenable);
//       });
//       _s.difference(__s).forEach((element) {
//         element.addListener(_setUpDeepListenable);
//       });
//       __s = _s;
//     }

//     return Listenable.merge([
//       _deepListenable,
//       _listenable,
//       ...classes.map((e) => e.deepListenable)
//     ]);
//   }
// }

class AppNotifier<T> extends ValueNotifier<T> {
  final String key;

  AppNotifier(T value, {dynamic parent, this.key}) : super(value) {
    // parent?.register(this);
  }
}

extension ValueNotifierSetter<T> on ValueNotifier<T> {
  void set(T value) {
    this.value = value;
  }

  Computed<B> map<B>(B Function(T) mapper) {
    return Computed<B>(() => mapper(value), [this]);
  }
}

extension ValueListenableBuilderExtension<T> on ValueListenable<T> {
  Widget rebuild(Widget Function(T value) fn) {
    return ValueListenableBuilder<T>(
      valueListenable: this,
      builder: (context, v, _) {
        return fn(v);
      },
    );
  }
}

extension ListenableBuilder on Listenable {
  Widget rebuild(Widget Function() fn) {
    return AnimatedBuilder(
      animation: this,
      builder: (context, _) {
        return fn();
      },
    );
  }
}

class TextNotifier {
  TextNotifier({String initialText, dynamic parent})
      : controller = TextEditingController(text: initialText) {
    textNotifier = Computed(() => controller.text, [controller]);
  }

  final TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  Computed<String> textNotifier;
  String get text => controller.text;
}

class Computed<T> extends ChangeNotifier implements ValueListenable<T> {
  Computed(
    this.computer,
    List<Listenable> dependencies,
  ) {
    _dependencies = Listenable.merge(dependencies);
  }
  final T Function() computer;
  Listenable _dependencies;
  bool _isUpToDate = false;
  bool _isListening = false;
  T _value;

  @override
  T get value {
    if (!_isUpToDate) {
      _listenDependencies();
      _updateValue(initial: true);
      _isUpToDate = true;
    }
    return _value;
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

  void _updateValue({@required bool initial}) {
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
      _dependencies.addListener(_compute);
      _isListening = true;
    }
  }

  void _stopListeningDependencies() {
    if (_isListening) {
      _dependencies.removeListener(_compute);
      _isListening = false;
    }
  }

  @override
  void dispose() {
    _stopListeningDependencies();
    super.dispose();
  }
}

abstract class Disposable {
  final Set<void Function()> _callbacks = {};

  void onDispose(void Function() callback) {
    _callbacks.add(callback);
  }

  @mustCallSuper
  void dispose() {
    for (final callback in _callbacks) {
      callback();
    }
  }
}

enum SupportedJsonType {
  // ignore: constant_identifier_names
  String,
  int,
  double,
  num,
  // ignore: constant_identifier_names
  List,
  // ignore: constant_identifier_names
  Map,
  // ignore: constant_identifier_names
  Set,
}

SupportedJsonType parseSupportedJsonType(String rawString,
    {SupportedJsonType defaultValue}) {
  for (final variant in SupportedJsonType.values) {
    if (rawString == variant.toEnumString()) {
      return variant;
    }
  }
  return defaultValue;
}

extension SupportedJsonTypeExtension on SupportedJsonType {
  String toEnumString() => toString().split(".")[1];
  String enumType() => toString().split(".")[0];

  bool get isString => this == SupportedJsonType.String;
  bool get isInt => this == SupportedJsonType.int;
  bool get isDouble => this == SupportedJsonType.double;
  bool get isNum => this == SupportedJsonType.num;
  bool get isList => this == SupportedJsonType.List;
  bool get isMap => this == SupportedJsonType.Map;
  bool get isSet => this == SupportedJsonType.Set;

  T when<T>({
    T Function() String,
    T Function() int,
    T Function() double,
    T Function() num,
    T Function() List,
    T Function() Map,
    T Function() Set,
    T Function() orElse,
  }) {
    T Function() c;
    switch (this) {
      case SupportedJsonType.String:
        c = String;
        break;
      case SupportedJsonType.int:
        c = int;
        break;
      case SupportedJsonType.double:
        c = double;
        break;
      case SupportedJsonType.num:
        c = num;
        break;
      case SupportedJsonType.List:
        c = List;
        break;
      case SupportedJsonType.Map:
        c = Map;
        break;
      case SupportedJsonType.Set:
        c = Set;
        break;

      default:
        c = orElse;
    }
    return (c ?? orElse)?.call();
  }
}

final supportedJsonTypes =
    SupportedJsonType.values.map((e) => e.toEnumString()).toSet();
