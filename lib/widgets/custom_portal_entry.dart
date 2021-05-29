import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'package:snippet_generator/utils/extensions.dart';

class CustomPortalEntry extends HookWidget {
  const CustomPortalEntry({
    Key? key,
    required this.child,
    required this.portal,
  }) : super(key: key);

  final Widget child;
  final Widget portal;

  @override
  Widget build(BuildContext context) {
    final showPortal = useState(false);
    final isInside = useState(false);
    const closeDuration = Duration(milliseconds: 130);
    final animationController = useAnimationController(
      duration: closeDuration,
    );
    final verticalOffset = useState(0.0);
    final horizontalOffset = useState(0.0);
    final curvedAnimation = useMemoized(
      () => animationController.drive(CurveTween(curve: Curves.easeOut)),
      [animationController],
    );
    const cardHeight = 360.0;
    const cardWidth = 370.0;
    useValueChanged<bool, void>(showPortal.value, (_previous, _result) {
      if (showPortal.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    });
    useEffect(() {
      Timer? timer;
      if (isInside.value && !showPortal.value) {
        timer = Timer(const Duration(milliseconds: 400), () {
          showPortal.value = true;
        });
      } else if (!isInside.value && showPortal.value) {
        timer = Timer(const Duration(milliseconds: 300), () {
          showPortal.value = false;
        });
      }
      return timer?.cancel;
    }, [isInside.value, showPortal.value]);

    Widget mouseRegion(Widget child) {
      return MouseRegion(
        onEnter: (_) {
          isInside.value = true;
        },
        onExit: (_) {
          isInside.value = false;
        },
        child: child,
      );
    }

    return PortalEntry(
      childAnchor: horizontalOffset.value != 0
          ? Alignment.topCenter
          : Alignment.centerRight,
      portalAnchor: horizontalOffset.value != 0
          ? Alignment.bottomCenter
          : Alignment.centerLeft,
      closeDuration: closeDuration,
      visible: showPortal.value,
      portal: Padding(
        padding: EdgeInsets.only(
          top: verticalOffset.value > 0 ? verticalOffset.value * 2 : 0,
          bottom: verticalOffset.value < 0 ? verticalOffset.value * -2 : 0,
          left: horizontalOffset.value > 0 ? horizontalOffset.value * 2 : 0,
          right: horizontalOffset.value < 0 ? horizontalOffset.value * -2 : 0,
        ),
        child: mouseRegion(
          AnimatedBuilder(
            animation: curvedAnimation,
            builder: (context, snapshot) {
              return Opacity(
                opacity: curvedAnimation.value,
                child: portal,
              );
            },
          ),
        ),
      ),
      child: mouseRegion(
        TextButton(
          onPressed: () => showPortal.value = true,
          child: Builder(
            builder: (context) {
              final mq = MediaQuery.of(context);
              final screenHeight = mq.size.height;
              final screenWidth = mq.size.width;
              if (showPortal.value) {
                SchedulerBinding.instance!.addPostFrameCallback(
                  (timeStamp) {
                    final bounds = context.globalPaintBounds;
                    if (bounds != null) {
                      const minMargin = 10.0;

                      final deltaTop =
                          bounds.centerRight.dy - cardHeight / 2 - minMargin;
                      final deltaBottom = screenHeight -
                          (bounds.centerRight.dy + cardHeight / 2 + minMargin);
                      if (deltaTop < 0) {
                        verticalOffset.value = -deltaTop;
                      } else if (deltaBottom < 0) {
                        verticalOffset.value = deltaBottom;
                      } else {
                        verticalOffset.value = 0;
                      }

                      final deltaLeft = bounds.centerRight.dx - minMargin;
                      final deltaRight = screenWidth -
                          (bounds.centerRight.dx + cardWidth + minMargin);
                      if (deltaLeft < 0) {
                        horizontalOffset.value = -deltaLeft;
                      } else if (deltaRight < 0) {
                        horizontalOffset.value = deltaRight;
                      } else {
                        horizontalOffset.value = 0;
                      }
                    }
                  },
                );
              }
              return child;
            },
          ),
        ),
      ),
    );
  }
}

