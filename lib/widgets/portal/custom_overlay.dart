import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/globals/option.dart';
import 'package:snippet_generator/widgets/globals.dart';
import 'package:snippet_generator/widgets/portal/portal_utils.dart';

class CustomOverlayButton extends HookWidget {
  final Widget Function(PortalNotifier) portalBuilder;
  final Widget child;
  final PortalBundler? builder;
  final PortalParams params;

  const CustomOverlayButton({
    required this.portalBuilder,
    required this.child,
    this.params = const PortalParams(),
    this.builder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final show = useState(false);

    final _portalNotifier = useMemoized(
      () => PortalNotifier(
        showNotifier: show,
      ),
    );

    final _portalKey = useMemoized(() => GlobalKey());
    final _childKey = useMemoized(() => GlobalKey());
    final toggle = _portalNotifier.toggle;

    if (builder != null) {
      return builder!(
        show: show.value,
        portal: Inherited(
          data: _portalNotifier,
          child: makePositioned(
            portalBuilder: (context) => portalBuilder(_portalNotifier),
            childKey: _childKey,
            portalKey: _portalKey,
            params: params.copyWith(
              onTapOutside: Some(() {
                toggle();
                params.onTapOutside?.call();
              }),
            ),
          ),
        ),
        child: KeyedSubtree(
          key: _childKey,
          child: TextButton(
            onPressed: toggle,
            child: child,
          ),
        ),
      );
    }

    return CustomOverlay(
      show: show.value,
      portal: portalBuilder(_portalNotifier),
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

    final _keyPortal = useMemoized(() => GlobalKey());
    final _keyChild = useMemoized(() => GlobalKey());
    final _portalRef = useMemoized(() => _Ref(portal));
    _portalRef.widget = portal;

    final entry = useMemoized(
      () => OverlayEntry(
        builder: (context) => makePositioned(
          childKey: _keyChild,
          portalKey: _keyPortal,
          portalBuilder: (context) => _portalRef.widget,
          params: PortalParams(
            backgroundColor: backgroundColor,
            onTapOutside: onTapOutside,
          ),
        ),
      ),
      [onTapOutside, backgroundColor],
    );

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

class _Ref {
  Widget widget;
  _Ref(this.widget);
}
