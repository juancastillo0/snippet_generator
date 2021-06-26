import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/utils/download_json.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/widgets/portal/custom_overlay.dart';
import 'package:snippet_generator/widgets/portal/global_stack.dart';
import 'package:snippet_generator/widgets/portal/portal_utils.dart';
import 'package:url_launcher/url_launcher.dart';

ButtonStyle _actionButton(BuildContext context) {
  final theme = Theme.of(context);
  return TextButton.styleFrom(
    primary: Colors.white,
    onSurface: Colors.white,
    disabledMouseCursor: MouseCursor.defer,
    enabledMouseCursor: SystemMouseCursors.click,
  ).copyWith(
    textStyle: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return theme.textTheme.button!.copyWith(fontWeight: FontWeight.bold);
      }
      return theme.textTheme.button;
    }),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  );
}

ButtonStyle _actionButtonPadded(BuildContext context) =>
    _actionButton(context).copyWith(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      ),
    );

const appTabsTitles = {
  AppTabs.ui: 'Widgets',
  AppTabs.types: 'Types',
  AppTabs.theme: 'Themes',
  AppTabs.database: 'Data',
  AppTabs.parsers: 'Parsers',
};

class TabButton extends HookWidget {
  const TabButton({
    required this.tab,
    Key? key,
  }) : super(key: key);

  final AppTabs tab;

  @override
  Widget build(BuildContext context) {
    final rootStore = useRootStore(context);

    return Observer(builder: (context) {
      final isSelected = tab == rootStore.selectedTab;
      return TextButton(
        style: _actionButton(context),
        onPressed: isSelected
            ? null
            : () {
                rootStore.setSelectedTab(tab);
              },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onBackground
                      : Colors.transparent,
                  width: 3,
                ),
                top: const BorderSide(
                  color: Colors.transparent,
                  width: 3,
                )),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(child: Text(appTabsTitles[tab]!)),
        ),
      );
    });
  }
}

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomePageAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = RootStore.of(context);

    return LayoutBuilder(builder: (context, box) {
      final showTitle = box.maxWidth > 1000;
      final showButtons = box.maxWidth > 1200;
      final topButtonStyle = _actionButtonPadded(context);
      final buttonStyle = showButtons
          ? topButtonStyle
          : _actionButtonPadded(context).copyWith(
              foregroundColor: MaterialStateProperty.resolveWith(
                (states) {
                  final base = Theme.of(context).colorScheme.onSurface;
                  return base;
                },
              ),
              backgroundColor: MaterialStateProperty.resolveWith(
                (states) {
                  final base = Theme.of(context).colorScheme.primary;
                  return states.contains(MaterialState.hovered)
                      ? base.withOpacity(0.2)
                      : null;
                },
              ),
            );

      final persistenceActions = [
        TextButton.icon(
          style: topButtonStyle,
          onPressed: rootStore.saveHive,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
        TextButton.icon(
          style: buttonStyle,
          onPressed: () async {
            final jsonString = await importFromClient();
            if (jsonString != null) {
              rootStore.importJson(jsonString);
            }
          },
          icon: const Icon(Icons.file_upload),
          label: const Text('Import'),
        ),
        TextButton.icon(
          style: buttonStyle,
          onPressed: () {
            rootStore.downloadJson();
          },
          icon: const Icon(Icons.file_download),
          label: const Text('Export'),
        ),
      ];

      return AppBar(
        title: SizedBox(
          height: 46,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showTitle)
                const Center(
                  child: Text('Flutter Snippet Generator'),
                ),
              if (showTitle) const SizedBox(width: 30),
              const TabButton(tab: AppTabs.types),
              const TabButton(tab: AppTabs.ui),
              const TabButton(tab: AppTabs.theme),
              const TabButton(tab: AppTabs.database),
              const TabButton(tab: AppTabs.parsers),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Dark Mode'),
              rootStore.themeModeNotifier.rebuild(
                (mode) => Switch(
                  value: rootStore.themeModeNotifier.value == ThemeMode.dark,
                  onChanged: (value) {
                    rootStore.themeModeNotifier.value =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          if (showButtons)
            ...persistenceActions
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                persistenceActions.first,
                CustomOverlayButton(
                  builder: StackPortal.make,
                  params: PortalParams(
                    childAnchor: Alignment.bottomRight,
                    portalAnchor: Alignment.topRight,
                    portalWrapper:
                        makeDefaultPortalWrapper(padding: EdgeInsets.zero),
                    backgroundColor: Colors.transparent,
                  ),
                  portalBuilder: (p) => Column(
                    children: [...persistenceActions.skip(1)],
                  ),
                  child: Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                )
              ],
            ),
          IconButton(
            splashRadius: 24,
            onPressed: () {
              launch('https://github.com/juancastillo0/snippet_generator');
            },
            icon: Image.asset(
              'assets/images/GitHub-Mark-64px.png',
              height: 32,
              color: Colors.white,
            ),
            tooltip: 'Github Repository',
          ),
          const SizedBox(width: 10),
        ],
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(46);
}
