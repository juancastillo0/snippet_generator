import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:snippet_generator/utils/extensions.dart';

class ColorFieldRow extends HookWidget {
  const ColorFieldRow({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
    this.width = 180,
  }) : super(key: key);
  final String name;
  final Color value;
  final double width;
  final void Function(Color) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorHoverButton(
          onChanged: onChanged,
          value: value,
        ),
        SizedBox(width: width, child: SelectableText(name)),
      ],
    );
  }
}

class ColorHoverButton extends HookWidget {
  const ColorHoverButton({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final Color value;
  final void Function(Color) onChanged;

  @override
  Widget build(BuildContext context) {
    final showColorPicker = useState(false);
    final isInside = useState(false);
    const closeDuration = Duration(milliseconds: 130);
    final animationController = useAnimationController(
      duration: closeDuration,
    );
    final verticalOffset = useState(0.0);
    final curvedAnimation = useMemoized(
      () => animationController.drive(CurveTween(curve: Curves.easeOut)),
      [animationController],
    );
    const cardHeight = 360.0;
    useValueChanged<bool, void>(showColorPicker.value, (_previous, _result) {
      if (showColorPicker.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    });
    useEffect(() {
      Timer? timer;
      if (isInside.value && !showColorPicker.value) {
        timer = Timer(const Duration(milliseconds: 400), () {
          showColorPicker.value = true;
        });
      } else if (!isInside.value && showColorPicker.value) {
        timer = Timer(const Duration(milliseconds: 300), () {
          showColorPicker.value = false;
        });
      }
      return timer?.cancel;
    }, [isInside.value, showColorPicker.value]);

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
      childAnchor: Alignment.centerRight,
      portalAnchor: Alignment.centerLeft,
      closeDuration: closeDuration,
      visible: showColorPicker.value,
      portal: Padding(
        padding: EdgeInsets.only(
          top: verticalOffset.value > 0 ? verticalOffset.value * 2 : 0,
          bottom: verticalOffset.value < 0 ? verticalOffset.value * -2 : 0,
        ),
        child: mouseRegion(
          AnimatedBuilder(
            animation: curvedAnimation,
            builder: (context, snapshot) {
              return Opacity(
                opacity: curvedAnimation.value,
                child: _picker(),
              );
            },
          ),
        ),
      ),
      child: mouseRegion(
        TextButton(
          onPressed: () => showColorPicker.value = true,
          child: Container(
            height: 25,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color: value,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 1, 
              // color: Theme.of(context).shadowColor.withOpacity(0.2),
              ),
            ),
            child: Builder(
              builder: (context) {
                final screenHeight = MediaQuery.of(context).size.height;
                if (showColorPicker.value) {
                  SchedulerBinding.instance!.addPostFrameCallback(
                    (timeStamp) {
                      final bounds = context.globalPaintBounds;
                      if (bounds != null) {
                        const minMargin = 10.0;
                        final deltaTop =
                            bounds.centerRight.dy - cardHeight / 2 - minMargin;
                        final deltaBottom = screenHeight -
                            (bounds.centerRight.dy +
                                cardHeight / 2 +
                                minMargin);
                        if (deltaTop < 0) {
                          verticalOffset.value = -deltaTop;
                        } else if (deltaBottom < 0) {
                          verticalOffset.value = deltaBottom;
                        } else {
                          verticalOffset.value = 0;
                        }
                      }
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _picker() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(left: 8),
      child: Container(
        width: 274,
        height: 360,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Builder(
          builder: (context) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(size: Size(250, mq.size.height)),
              child: ColorPicker(
                pickerColor: value,
                onColorChanged: onChanged,
                colorPickerWidth: 250.0,
                displayThumbColor: true,
                paletteType: PaletteType.hsv,
                pickerAreaBorderRadius:
                    const BorderRadius.all(Radius.circular(3)),
                showLabel: true,
                enableAlpha: true,
                pickerAreaHeightPercent: 0.7,
              ),
            );
          },
        ),
      ),
    );
  }

  // void _showColorPicker(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Dialog(
  //         child: Container(
  //           height: 400,
  //           width: 300,
  //           padding: const EdgeInsets.all(12),
  //           child: _picker(),
  //         ),
  //       );
  //     },
  //   );
  // }
}
