import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/main.dart';
import 'package:snippet_generator/utils/extensions.dart';

const _iconSize = 20.0;
const _scrollIconPadding = EdgeInsets.all(0);

class MultiScrollController {
  MultiScrollController({
    ScrollController vertical,
    ScrollController horizontal,
    void Function(double) setScale,
    @required BuildContext context,
    this.canScale = false,
  })  : vertical = vertical ?? ScrollController(),
        horizontal = horizontal ?? ScrollController(),
        _setScale = setScale,
        _context = context;
  final ScrollController vertical;
  final ScrollController horizontal;
  final void Function(double) _setScale;
  final BuildContext _context;
  final bool canScale;

  final scaleNotifier = ValueNotifier<double>(1);
  double get scale => scaleNotifier.value;

  final sizeNotifier = ValueNotifier<Size>(const Size(1, 1));
  Size get size => sizeNotifier.value;

  Offset toCanvasOffset(Offset offset) {
    final _canvasOffset = offset + offset - globalPaintBounds.topLeft;
    return _canvasOffset / scale;
  }

  Offset get translateOffset =>
      Offset(size.width / 2, size.height / 2) * (scale - 1);

  void onDrag(Offset delta) {
    if (delta.dx != 0) {
      final hp = horizontal.position;
      final dx = (horizontal.offset - delta.dx).clamp(0.0, hp.maxScrollExtent)
          as double;
      horizontal.jumpTo(dx);
    }

    if (delta.dy != 0) {
      final vp = vertical.position;
      final dy =
          (vertical.offset - delta.dy).clamp(0.0, vp.maxScrollExtent) as double;
      vertical.jumpTo(dy);
    }
  }

  Offset get offset => Offset(
        horizontal.offset,
        vertical.offset,
      );
  Rect get globalPaintBounds => _context.globalPaintBounds;

  void onScale(double newScale) {
    if (!canScale) {
      return;
    }
    scaleNotifier.value = newScale.clamp(0.4, 2.5) as double;
    _setScale?.call(scale);
    notifyAll();
  }

  void setSize(Size newSize) {
    if (newSize != size) {
      sizeNotifier.value = newSize;
      notifyAll();
    }
  }

  void notifyAll() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (horizontal.hasClients) {
        final multiplerH = horizontal.offset <= 0.01 ? 1 : -1;
        horizontal.jumpTo(horizontal.offset + multiplerH * 0.0001);
      }
      if (vertical.hasClients) {
        final multiplerV = vertical.offset <= 0.01 ? 1 : -1;
        vertical.jumpTo(vertical.offset + multiplerV * 0.0001);
      }
    });
  }

  Widget sizer() {
    return _DummySizer(onBuild: setSize);
  }

  void dispose() {
    vertical.dispose();
    horizontal.dispose();
  }
}

class MultiScrollable extends StatefulWidget {
  const MultiScrollable({
    this.builder,
    this.listenable,
    Key key,
  }) : super(key: key);
  final Widget Function(
    BuildContext context,
    MultiScrollController controller,
  ) builder;
  final Listenable listenable;

  @override
  _MultiScrollableState createState() => _MultiScrollableState();
}

class _MultiScrollableState extends State<MultiScrollable> with RouteAware {
  MultiScrollController controller;
  double innerWidth;
  double innerHeight;

  @override
  void initState() {
    super.initState();
    controller = MultiScrollController(context: context);
    widget.listenable?.addListener(_rebuild);
    _rebuild();
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant MultiScrollable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      widget.listenable?.addListener(_rebuild);
      oldWidget.listenable?.removeListener(_rebuild);
      _rebuild();
    }
  }

  void _rebuild() {
    controller.notifyAll();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(context, controller);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      if (innerWidth != box.maxWidth ||
                          innerHeight != box.maxHeight) {
                        setState(() {
                          innerWidth = box.maxWidth;
                          innerHeight = box.maxHeight;
                        });
                      }
                    });
                    return child;
                  },
                ),
              ),
              ButtonScrollbar(
                controller: controller.vertical,
                horizontal: false,
                maxSize: innerHeight,
              ),
            ],
          ),
        ),
        ButtonScrollbar(
          controller: controller.horizontal,
          horizontal: true,
          maxSize: innerWidth,
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    controller.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
    super.didPopNext();
  }
}

class ButtonScrollbar extends HookWidget {
  const ButtonScrollbar({
    Key key,
    @required this.controller,
    @required this.maxSize,
    @required this.horizontal,
  }) : super(key: key);

  final ScrollController controller;
  final bool horizontal;
  final double maxSize;

  void onPressedScrollButtonStart() {
    controller.jumpTo(max(controller.offset - 20, 0));
  }

  void onPressedScrollButtonEnd() {
    controller.jumpTo(
      min(controller.offset + 20, controller.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    useListenable(controller);
    final isPressedButton = useState(false);
    if (!controller.hasClients ||
        controller.position?.viewportDimension == null ||
        controller.position.viewportDimension < maxSize ||
        controller.position.maxScrollExtent == 0) {
      return const SizedBox(width: 0, height: 0);
    }

    Future onLongPressStartForward(LongPressStartDetails _) async {
      isPressedButton.value = true;
      while (isPressedButton.value &&
          controller.offset < controller.position.maxScrollExtent) {
        await controller.animateTo(
          min(controller.offset + 50, controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
      }
    }

    Future onLongPressStartBackward(LongPressStartDetails _) async {
      isPressedButton.value = true;
      while (isPressedButton.value && controller.offset > 0) {
        await controller.animateTo(
          max(controller.offset - 50, 0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
      }
    }

    final children = [
      _ScrollbarButton(
        isStart: true,
        horizontal: horizontal,
        onLongPressStart: onLongPressStartBackward,
        onLongPressEnd: (details) => isPressedButton.value = false,
        onPressed: onPressedScrollButtonStart,
      ),
      Expanded(
        child: MultiScrollbar(
          controller: controller,
          horizontal: horizontal,
        ),
      ),
      _ScrollbarButton(
        isStart: false,
        horizontal: horizontal,
        onLongPressStart: onLongPressStartForward,
        onLongPressEnd: (details) => isPressedButton.value = false,
        onPressed: onPressedScrollButtonEnd,
      )
    ];

    final _size = horizontal
        ? Size(maxSize ?? double.infinity, _iconSize)
        : Size(_iconSize, maxSize ?? double.infinity);

    return ConstrainedBox(
      constraints: BoxConstraints.loose(_size),
      child: Flex(
        direction: horizontal ? Axis.horizontal : Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}

class _ScrollbarButton extends StatelessWidget {
  final void Function(LongPressStartDetails) onLongPressStart;
  final void Function(LongPressEndDetails) onLongPressEnd;
  final void Function() onPressed;
  final bool horizontal;
  final bool isStart;

  const _ScrollbarButton({
    Key key,
    @required this.onLongPressStart,
    @required this.onLongPressEnd,
    @required this.onPressed,
    @required this.horizontal,
    @required this.isStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: _iconSize,
          maxWidth: _iconSize,
        ),
        child: FlatButton(
          onPressed: onPressed,
          padding: _scrollIconPadding,
          child: Icon(
            isStart
                ? (horizontal ? Icons.arrow_left : Icons.arrow_drop_up)
                : (horizontal ? Icons.arrow_right : Icons.arrow_drop_down),
            size: _iconSize,
          ),
        ),
      ),
    );
  }
}

class MultiScrollbar extends HookWidget {
  const MultiScrollbar({
    @required this.controller,
    this.horizontal = false,
    Key key,
  }) : super(key: key);
  final ScrollController controller;
  final bool horizontal;

  @override
  Widget build(BuildContext ctx) {
    final position = controller.position;
    final offset = controller.offset;
    final scrollExtent = position.maxScrollExtent + position.viewportDimension;

    return LayoutBuilder(
      builder: (ctx, box) {
        final maxSize = horizontal ? box.maxWidth : box.maxHeight;
        final handleSize = maxSize * position.viewportDimension / scrollExtent;
        final rate = (maxSize - handleSize) / position.maxScrollExtent;
        final top = rate * offset;

        return Flex(
          direction: horizontal ? Axis.horizontal : Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (horizontal) SizedBox(width: top) else SizedBox(height: top),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontal ? 0 : 3,
                vertical: horizontal ? 3 : 0,
              ),
              child: _ScrollHandle(
                horizontal: horizontal,
                handleSize: handleSize,
                controller: controller,
                rate: rate,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScrollHandle extends HookWidget {
  const _ScrollHandle({
    Key key,
    @required this.horizontal,
    @required this.handleSize,
    @required this.controller,
    @required this.rate,
  }) : super(key: key);

  final bool horizontal;
  final double handleSize;
  final ScrollController controller;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final position = controller.position;
    final hovering = useState(false);
    final dragging = useState(false);

    return MouseRegion(
      onEnter: (_) => hovering.value = true,
      onExit: (_) => hovering.value = false,
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.down,
        onPanDown: (_) => dragging.value = true,
        onPanEnd: (_) => dragging.value = false,
        onPanUpdate: (DragUpdateDetails p) {
          final _delta = horizontal ? p.delta.dx : p.delta.dy;
          final _offset = (controller.offset + _delta / rate)
              .clamp(0.0, position.maxScrollExtent) as double;
          controller.jumpTo(_offset);
        },
        child: SizedBox(
          height: horizontal ? double.infinity : handleSize,
          width: horizontal ? handleSize : double.infinity,
          child: Container(
            color: hovering.value || dragging.value
                ? Colors.black.withOpacity(0.17)
                : Colors.black12,
          ),
        ),
      ),
    );
  }
}

class _DummySizer extends SingleChildRenderObjectWidget {
  final Function(Size) onBuild;

  const _DummySizer({Key key, this.onBuild}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TRenderBox(onBuild: onBuild);
  }
}

class _TRenderBox extends RenderBox {
  _TRenderBox({this.onBuild});

  final Function(Size) onBuild;

  @override
  void paint(PaintingContext context, Offset offset) {
    final _p = parent;
    if (_p is RenderFlex && _p.hasSize) {
      onBuild(_p.size);
    }
    super.paint(context, offset);
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.smallest;
  }
}
