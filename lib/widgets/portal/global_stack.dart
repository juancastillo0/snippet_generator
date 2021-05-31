import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/widgets/globals.dart';

class GlobalStack extends HookWidget {
  final Widget child;

  static GlobalStackState of(BuildContext context) {
    return Inherited.of<GlobalStackState>(context);
  }

  const GlobalStack({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = useMemoized(() => GlobalStackState());
    useListenable(state);

    return Inherited(
      data: state,
      child: Material(
        child: Stack(
          children: [
            child,
            ...state.widgets.values,
          ],
        ),
      ),
    );
  }
}

class StackPortal extends HookWidget {
  final Widget child;
  final Widget portal;
  final bool show;

  static Widget make({
    required Widget child,
    required Widget portal,
    required bool show,
  }) {
    return StackPortal(
      portal: portal,
      show: show,
      child: child,
    );
  }

  const StackPortal({
    Key? key,
    required this.child,
    required this.portal,
    required this.show,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ref = useMemoized(() => _Ref());
    final stack = GlobalStack.of(context);

    useEffect(() {
      if (show) {
        _ref.id = stack.addWidget(portal);
      } else if (_ref.id != null) {
        stack.removeWidget(_ref.id!);
        _ref.id = null;
      }
    }, [show]);

    useEffect(() {
      if (show) {
        stack.updateWidget(_ref.id!, portal);
      }
    }, [portal]);

    return child;
  }
}

class _Ref {
  int? id;
}

class GlobalStackState extends ChangeNotifier {
  int _lastId = 0;
  int get lastId => _lastId;

  final widgets = SplayTreeMap<int, Widget>();

  int addWidget(Widget widget) {
    final id = _lastId++;
    widgets[id] = widget;
    _notify();
    return id;
  }

  void updateWidget(int id, Widget widget) {
    widgets[id] = widget;
    _notify();
  }

  void removeWidget(int id) {
    widgets.remove(id);
    _notify();
  }

  void _notify() {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }
}

// class GlobalStackInherited extends InheritedWidget {
//   final GlobalStackState state;

//   const GlobalStackInherited({
//     required this.state,
//     required Widget child,
//   }) : super(child: child);

//   @override
//   bool updateShouldNotify(GlobalStackInherited oldWidget) {
//     return oldWidget.state != state;
//   }
// }
