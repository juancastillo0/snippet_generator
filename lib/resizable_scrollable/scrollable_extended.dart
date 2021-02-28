import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/resizable_scrollable/scrollable.dart';

class CustomScrollGestures extends HookWidget {
  const CustomScrollGestures({
    Key? key,
    required this.child,
    required this.controller,
    this.allowDrag = true,
  }) : super(key: key);
  final Widget child;
  final MultiScrollController controller;
  final bool allowDrag;

  @override
  Widget build(BuildContext ctx) {
    final prevPoint = useState(const Offset(0, 0));
    final initScale = useState(controller.scale);

    return LayoutBuilder(
      builder: (ctx, box) {
        void onScaleUpdate(ScaleUpdateDetails d) {
          if (d.scale != 1) {
            // print(
            //     "graphCanvas.toCanvasOffset(d.focalPoint) ${graphCanvas.toCanvasOffset2(d.focalPoint)}");
            // print(
            //     "graphCanvas.toCanvasOffset(prevPoint.value) ${graphCanvas.toCanvasOffset2(prevPoint.value)}");
            final _p = controller.toCanvasOffset(prevPoint.value);
            final _prev = controller.scale;
            controller.onScale(d.scale * initScale.value);
            final _p2 = controller.toCanvasOffset(prevPoint.value);
            print("$_p $_p2");
            final center = Offset(box.maxWidth / 2, box.maxHeight / 2);
            final fromCenter =
                (prevPoint.value - center) * _prev / controller.scale;
            controller.onDrag((_p2 - _p) * controller.scale);
            prevPoint.value = d.localFocalPoint;
          } else {
            controller.onDrag(d.localFocalPoint - prevPoint.value);
            prevPoint.value = d.localFocalPoint;
          }
        }

        return GestureDetector(
          onScaleStart: (details) {
            initScale.value = controller.scale;
            prevPoint.value = details.localFocalPoint;
          },
          dragStartBehavior: DragStartBehavior.down,
          onScaleUpdate: allowDrag ? onScaleUpdate : null,
          child: SingleChildScrollView(
            controller: controller.horizontal,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SingleChildScrollView(
              controller: controller.vertical,
              physics: const NeverScrollableScrollPhysics(),
              child: _CustomMultiScrollView(
                controller: controller,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomMultiScrollView extends StatelessWidget {
  const _CustomMultiScrollView({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final MultiScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    useListenable(controller.sizeNotifier);
    useListenable(controller.scaleNotifier);

    final multiplier = controller.scale;
    final _height = controller.size.height * multiplier;
    final _width = controller.size.width * multiplier;

    return SizedBox(
      height: _height,
      width: _width,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0.0,
          minHeight: 0.0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Transform.translate(
            offset: controller.translateOffset,
            child: Transform.scale(
              scale: controller.scale,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class MouseScrollListener extends StatefulWidget {
  const MouseScrollListener({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);
  final MultiScrollController controller;
  final Widget child;

  @override
  _MouseScrollListenerState createState() => _MouseScrollListenerState();
}

class _MouseScrollListenerState extends State<MouseScrollListener> {
  final _focusNode = FocusNode();
  bool isShiftPressed = false;
  bool isCtrlPressed = false;

  MultiScrollController get controller => widget.controller;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      if (isCtrlPressed) {
        final newScale = controller.scale - pointerSignal.scrollDelta.dy / 400;
        controller.onScale(newScale);
      } else if (isShiftPressed) {
        controller.onDrag(Offset(-pointerSignal.scrollDelta.dy, 0));
      } else {
        controller.onDrag(Offset(0, -pointerSignal.scrollDelta.dy));
      }
    }
  }

  void _onKey(RawKeyEvent event) {
    setState(() {
      isShiftPressed = event.data.isShiftPressed;
      isCtrlPressed = event.data.isControlPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _focusNode.requestFocus(),
      onExit: (_) => _focusNode.unfocus(
          disposition: UnfocusDisposition.previouslyFocusedChild),
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: _focusNode,
        onKey: _onKey,
        child: Listener(
          onPointerSignal: _onPointerSignal,
          child: widget.child,
        ),
      ),
    );
  }
}
