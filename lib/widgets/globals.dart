import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

export 'package:stack_portal/stack_portal.dart' show Inherited;

class GlobalKeyboardListener {
  static final focusNode = FocusNode();
  static final Set<void Function(RawKeyEvent event)> _listeners = {};
  static final Set<void Function(TapDownDetails event)> _tapDownListeners = {};

  static final gestures = {
    AllowMultipleGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<AllowMultipleGestureRecognizer>(
      () => AllowMultipleGestureRecognizer(),
      (instance) {
        instance.onTapDown = GlobalKeyboardListener.onTapDown;
      },
    )
  };

  static void addKeyListener(void Function(RawKeyEvent) callback) {
    _listeners.add(callback);
  }

  static void removeKeyListener(void Function(RawKeyEvent) callback) {
    _listeners.remove(callback);
  }

  static void addTapListener(void Function(TapDownDetails) callback) {
    _tapDownListeners.add(callback);
  }

  static void removeTapListener(void Function(TapDownDetails) callback) {
    _tapDownListeners.remove(callback);
  }

  static void onKey(RawKeyEvent event) {
    for (final callback in _listeners) {
      callback(event);
    }
  }

  static void onTapDown(TapDownDetails event) {
    for (final callback in _tapDownListeners) {
      callback(event);
    }
  }

  static Widget wrapper({required Widget child}) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: GlobalKeyboardListener.focusNode,
      onKey: GlobalKeyboardListener.onKey,
      child: RawGestureDetector(
        behavior: HitTestBehavior.translucent,
        gestures: GlobalKeyboardListener.gestures,
        child: child,
      ),
    );
  }
}

class AllowMultipleGestureRecognizer extends TapGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
