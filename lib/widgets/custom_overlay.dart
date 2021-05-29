import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:snippet_generator/utils/extensions.dart';

class _Ref {
  Widget widget;
  _Ref(this.widget);
}

class PortalParams {
  final ValueNotifier<bool> showNotifier;
  const PortalParams({
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

class CustomOverlayButton extends HookWidget {
  final Widget Function(PortalParams) portalBuilder;
  final Widget child;

  const CustomOverlayButton({
    required this.portalBuilder,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final show = useState(false);

    final toggle = useMemoized(() {
      return () {
        show.value = !show.value;
      };
    });

    final _portalParams = useMemoized(
      () => PortalParams(
        showNotifier: show,
      ),
    );

    return CustomOverlay(
      show: show.value,
      portal: portalBuilder(_portalParams),
      onTapOutside: toggle,
      child: TextButton(
        onPressed: toggle,
        child: child,
      ),
    );
  }
}

class CustomOverlay extends HookWidget {
  final bool show;
  final Widget portal;
  final Widget child;
  final void Function()? onTapOutside;
  final Color? backgroundColor;

  const CustomOverlay({
    required this.show,
    required this.portal,
    required this.child,
    this.onTapOutside,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overlay = Overlay.of(context);
    final mq = MediaQuery.of(context);

    final _keyPortal = useMemoized(() => GlobalKey());
    final _keyChild = useMemoized(() => GlobalKey());
    final _portalRef = useMemoized(() => _Ref(portal));
    _portalRef.widget = portal;

    final entry = useMemoized(
        () => OverlayEntry(
              builder: (context) {
                final bounds = _keyChild.currentContext?.globalPaintBounds;
                final boundsPortal =
                    _keyPortal.currentContext?.globalPaintBounds;

                final widget = Positioned(
                  bottom: mq.size.height - (bounds?.top ?? 0),
                  left: (bounds?.left ?? 0) - (boundsPortal?.width ?? 0) / 2,
                  child: GestureDetector(
                    onTap: onTapOutside == null ? null : () {},
                    child: Visibility(
                      visible: boundsPortal != null,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: KeyedSubtree(
                        key: _keyPortal,
                        child: _portalRef.widget,
                      ),
                    ),
                  ),
                );

                if (onTapOutside != null) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: onTapOutside,
                        child: DecoratedBox(
                          // constraints: const BoxConstraints.expand(),
                          decoration: BoxDecoration(
                            color: backgroundColor ?? Colors.black26,
                          ),
                        ),
                      ),
                      widget,
                    ],
                  );
                }

                return widget;
              },
            ),
        [onTapOutside, backgroundColor]);

    void _tryRebuildEntry() {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        if (show && entry.mounted) {
          entry.markNeedsBuild();
        }
      });
    }

    useEffect(() {
      if (show && overlay != null) {
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          if (show) {
            overlay.insert(entry);
            _tryRebuildEntry();
          }
        });
        return () {
          entry.remove();
        };
      }
    }, [show, overlay, entry]);

    useEffect(() {
      _tryRebuildEntry();
    }, [portal]);

    return KeyedSubtree(key: _keyChild, child: child);
  }
}
