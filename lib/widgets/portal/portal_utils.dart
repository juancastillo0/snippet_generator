import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:snippet_generator/globals/option.dart';
import 'package:snippet_generator/utils/extensions.dart';

class PortalNotifier {
  final ValueNotifier<bool> showNotifier;
  const PortalNotifier({
    required this.showNotifier,
  });

  void hide() {
    showNotifier.value = false;
  }

  void show() {
    showNotifier.value = true;
  }

  void toggle() {
    showNotifier.value = !showNotifier.value;
  }
}

typedef PortalBundler = Widget Function({
  required Widget child,
  required Widget portal,
  required bool show,
});

class PortalParams {
  final void Function()? onTapOutside;
  final Color? backgroundColor;
  final Alignment? childAnchor;
  final Alignment? portalAnchor;
  final Alignment? alignment;
  final Widget Function(BuildContext, Widget)? portalWrapper;
  final double screenMargin;

  const PortalParams({
    this.onTapOutside,
    this.backgroundColor,
    this.childAnchor,
    this.portalAnchor,
    this.alignment,
    this.portalWrapper,
    this.screenMargin = 0,
  }) : assert((portalAnchor == null) == (childAnchor == null));

  PortalParams copyWith({
    Option<void Function()?>? onTapOutside,
    Option<Color?>? backgroundColor,
    Option<Alignment?>? childAnchor,
    Option<Alignment?>? portalAnchor,
    Option<Alignment?>? alignment,
    Option<Widget Function(BuildContext, Widget)?>? portalWrapper,
    double? margin,
  }) {
    return PortalParams(
      onTapOutside:
          onTapOutside != null ? onTapOutside.valueOrNull : this.onTapOutside,
      backgroundColor: backgroundColor != null
          ? backgroundColor.valueOrNull
          : this.backgroundColor,
      childAnchor:
          childAnchor != null ? childAnchor.valueOrNull : this.childAnchor,
      portalAnchor:
          portalAnchor != null ? portalAnchor.valueOrNull : this.portalAnchor,
      alignment: alignment != null ? alignment.valueOrNull : this.alignment,
      portalWrapper: portalWrapper != null
          ? portalWrapper.valueOrNull
          : this.portalWrapper,
      screenMargin: margin ?? this.screenMargin,
    );
  }

  @override
  String toString() {
    return 'PortalParams(onTapOutside: $onTapOutside, backgroundColor: $backgroundColor, childAnchor: $childAnchor, '
        'portalAnchor: $portalAnchor, alignment: $alignment, screenMargin: $screenMargin, portalWrapper: $portalWrapper)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PortalParams &&
        other.onTapOutside == onTapOutside &&
        other.backgroundColor == backgroundColor &&
        other.childAnchor == childAnchor &&
        other.portalAnchor == portalAnchor &&
        other.alignment == alignment &&
        other.screenMargin == screenMargin &&
        other.portalWrapper == portalWrapper;
  }

  @override
  int get hashCode {
    return hashValues(
      onTapOutside,
      backgroundColor,
      childAnchor,
      portalAnchor,
      alignment,
      screenMargin,
      portalWrapper,
    );
  }
}

Widget makePositioned({
  required GlobalKey childKey,
  required GlobalKey portalKey,
  required Widget Function(BuildContext) portalBuilder,
  PortalParams params = const PortalParams(),
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      final onTapOutside = params.onTapOutside;

      Widget widget = GestureDetector(
        onTap: onTapOutside == null ? null : () {},
        child: KeyedSubtree(
          key: portalKey,
          child: params.portalWrapper != null
              ? params.portalWrapper!(context, portalBuilder(context))
              : portalBuilder(context),
        ),
      );

      final childAnchor = params.childAnchor;
      final portalAnchor = params.portalAnchor;
      if (childAnchor != null && portalAnchor != null) {
        final mq = MediaQuery.of(context);
        final bounds = childKey.currentContext?.globalPaintBounds ?? Rect.zero;
        final boundsPortal =
            portalKey.currentContext?.globalPaintBounds ?? Rect.zero;

        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          final _new = portalKey.currentContext?.globalPaintBounds ?? Rect.zero;
          final _inter = _new.intersect(boundsPortal);
          if (_inter.width < _new.width * 0.99 ||
              _inter.height < _new.height * 0.99) {
            setState(() {});
          }
        });

        final pos = childAnchor.withinRect(bounds) -
            portalAnchor.alongSize(boundsPortal.size);
        final margin = params.screenMargin;
        widget = Positioned(
          top: pos.dy.clamp(
            margin,
            mq.size.height - boundsPortal.height - margin,
          ),
          left: pos.dx.clamp(
            margin,
            mq.size.width - boundsPortal.width - margin,
          ),
          // bottom: mq.size.height - bounds.top,
          // left: bounds.topCenter.dx - boundsPortal.width / 2,
          child: Visibility(
            visible: portalKey.currentContext?.globalPaintBounds != null,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: widget,
          ),
        );
      } else if (params.alignment != null) {
        widget = Align(
          alignment: params.alignment!,
          child: widget,
        );
      }

      if (onTapOutside != null) {
        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: onTapOutside,
              child: DecoratedBox(
                // constraints: const BoxConstraints.expand(),
                decoration: BoxDecoration(
                  color: params.backgroundColor ?? Colors.black26,
                ),
              ),
            ),
            widget,
          ],
        );
      }

      return widget;
    },
  );
}
