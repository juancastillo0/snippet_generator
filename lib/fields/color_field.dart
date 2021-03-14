
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';

class ColorFieldRow extends HookWidget {
  const ColorFieldRow({
    Key? key,
    required this.name,
    required this.value,
    required this.onChanged,
  }) : super(key: key);
  final String name;
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
    final curvedAnimation = useMemoized(
      () => animationController.drive(CurveTween(curve: Curves.easeOut)),
      [animationController],
    );
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 200, child: SelectableText(name)),
        PortalEntry(
          childAnchor: Alignment.centerRight,
          portalAnchor: Alignment.centerLeft,
          closeDuration: closeDuration,
          visible: showColorPicker.value,
          portal: mouseRegion(
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
          child: mouseRegion(TextButton(
            onPressed: () => _showColorPicker(context),
            child: Container(
              height: 30,
              width: 40,
              color: value,
            ),
          )),
        ),
      ],
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

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: 400,
            width: 300,
            padding: const EdgeInsets.all(12),
            child: _picker(),
          ),
        );
      },
    );
  }
}