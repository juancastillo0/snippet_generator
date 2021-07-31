import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'models/initial_size.dart';

enum ResizeHorizontal { left, right, both }
enum ResizeVertical { top, bottom, both }

class Resizable extends StatefulWidget {
  final ResizeHorizontal? horizontal;
  final double? defaultWidth;
  final double? minWidth;

  final ResizeVertical? vertical;
  final double? defaultHeight;
  final double? minHeight;
  final int? flex;

  final Widget child;
  final Widget? handle;
  final void Function(Size)? onResize;

  const Resizable({
    this.handle,
    this.horizontal,
    this.defaultWidth,
    required this.child,
    this.minWidth,
    this.vertical,
    this.defaultHeight,
    this.minHeight,
    this.flex,
    this.onResize,
  });

  @override
  _ResizableState createState() => _ResizableState();
}

class _ResizableState extends State<Resizable> {
  double? _width;
  double? _height;

  final _childKey = GlobalKey();

  @override
  void initState() {
    _width = widget.defaultWidth;
    _height = widget.defaultHeight;
    super.initState();
  }

  void onResize() {
    widget.onResize?.call(
      Size(
        (_width ?? _childKey.currentContext?.size?.width)!,
        (_height ?? _childKey.currentContext?.size?.height)!,
      ),
    );
  }

  void Function(DragUpdateDetails) _updateSize(
    bool proportional,
    bool horizontal,
  ) {
    return horizontal
        ? (DragUpdateDetails details) {
            setState(() {
              _width = (_width ?? _childKey.currentContext?.size?.width)! +
                  (proportional ? details.delta.dx : -details.delta.dx);
              onResize();
            });
          }
        : (DragUpdateDetails details) {
            setState(() {
              _height = (_height ?? _childKey.currentContext?.size?.height)! +
                  (proportional ? details.delta.dy : -details.delta.dy);
              onResize();
            });
          };
  }

  @override
  Widget build(BuildContext ctx) {
    if (widget.vertical != null) {
      final isBottom = widget.vertical == ResizeVertical.bottom;
      final handle = GestureDetector(
        onVerticalDragUpdate: _updateSize(isBottom, false),
        behavior: HitTestBehavior.translucent,
        dragStartBehavior: DragStartBehavior.down,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeUpDown,
          child: widget.handle ?? const Separator(),
        ),
      );

      final child = Column(
        key: _childKey,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isBottom) handle,
          Expanded(child: widget.child),
          if (isBottom) handle
        ],
      );

      if (_height == null && widget.flex != null) {
        return Flexible(
          flex: widget.flex!,
          child: child,
        );
      } else {
        return SizedBox(
          height: _height,
          child: child,
        );
      }
    } else {
      final isRight = widget.horizontal == ResizeHorizontal.right;
      final handle = GestureDetector(
        onHorizontalDragUpdate: _updateSize(isRight, true),
        behavior: HitTestBehavior.translucent,
        dragStartBehavior: DragStartBehavior.down,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: widget.handle ?? const Separator(vertical: true),
        ),
      );

      final child = Row(
        key: _childKey,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isRight) handle,
          Expanded(child: widget.child),
          if (isRight) handle
        ],
      );
      if (_width == null && widget.flex != null) {
        return Flexible(
          flex: widget.flex!,
          child: child,
        );
      } else {
        return SizedBox(
          width: _width,
          child: child,
        );
      }
    }
  }
}

class ResizableFlex extends HookWidget {
  final Axis direction;
  final List<ResizableItem> children;
  const ResizableFlex({
    Key? key,
    required this.direction,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overridenSizes = useMemoized(() => <Key, double>{}, [direction]);

    return LayoutBuilder(builder: (context, box) {
      final isVertical = direction == Axis.vertical;
      final max = isVertical ? box.maxHeight : box.maxWidth;
      int withoutFlex = 0;
      int totalFlex = children.fold(
        0,
        (previousValue, element) {
          final _flex = element.initialSize
              ?.when(flex: (flex) => flex + previousValue, size: (_) {});
          if (_flex == null) {
            withoutFlex += 1;
            return previousValue;
          } else {
            return _flex;
          }
        },
      );

      return Flex(
        direction: direction,
        children: [
          ...children.map((e) {
            final _initialSize = e.initialSize;
            Widget warpSized(double size) {
              return SizedBox(
                height: isVertical ? size : null,
                width: isVertical ? null : size,
                key: e.key,
                child: e.child,
              );
            }

            if (overridenSizes.containsKey(e.key)) {
              return warpSized(overridenSizes[e.key]!);
            } else if (_initialSize != null) {
              return _initialSize.when(
                flex: (flex) => Flexible(
                  key: e.key,
                  flex: flex,
                  child: e.child,
                ),
                size: warpSized,
              );
            } else {
              return e.child;
            }
          })
        ],
      );
    });
  }
}

class ResizableItem {
  final double? minSize;
  final double? maxSize;
  final InitialSize? initialSize;
  final Key? key;
  final Widget child;

  ResizableItem({
    required this.child,
    this.initialSize,
    this.minSize,
    this.maxSize,
    this.key,
  });
}

class Separator extends StatelessWidget {
  const Separator({
    this.size = 14,
    this.color = Colors.black12,
    this.vertical = false,
    this.thickness = 1,
  });

  final double size;
  final double thickness;
  final Color color;
  final bool vertical;

  @override
  Widget build(BuildContext ctx) {
    final margin = (size - thickness) / 2;

    if (vertical) {
      return Container(
        color: color,
        margin: EdgeInsets.symmetric(horizontal: margin),
        constraints: BoxConstraints(maxWidth: thickness),
      );
    } else {
      return Container(
        color: color,
        margin: EdgeInsets.symmetric(vertical: margin),
        constraints: BoxConstraints(maxHeight: thickness),
      );
    }
  }
}
