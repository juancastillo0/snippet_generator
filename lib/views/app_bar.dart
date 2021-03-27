import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:snippet_generator/models/rebuilder.dart';
import 'package:snippet_generator/models/root_store.dart';
import 'package:snippet_generator/utils/download_json.dart';
import 'package:snippet_generator/utils/extensions.dart';

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
        const EdgeInsets.symmetric(horizontal: 17),
      ),
    );

const appTabsTitles = {
  AppTabs.ui: "Widgets",
  AppTabs.types: "Types",
  AppTabs.theme: "Themes",
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
    // print(Platform.resolvedExecutable);

    return AppBar(
      title: Rebuilder(builder: (context) {
        return SizedBox(
          height: 46,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Center(child: Text('Flutter Snippet Generator')),
              SizedBox(width: 30),
              TabButton(tab: AppTabs.types),
              TabButton(tab: AppTabs.ui),
              TabButton(tab: AppTabs.theme),
            ],
          ),
        );
      }),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Dark Mode"),
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
        TextButton.icon(
          style: _actionButtonPadded(context),
          onPressed: rootStore.saveHive,
          icon: const Icon(Icons.save),
          label: const Text("Save"),
        ),
        TextButton.icon(
          style: _actionButtonPadded(context),
          onPressed: () async {
            final jsonString = await importFromClient();
            if (jsonString != null) {
              rootStore.importJson(jsonString);
            }
          },
          icon: const Icon(Icons.file_upload),
          label: const Text("Import"),
        ),
        TextButton.icon(
          style: _actionButtonPadded(context),
          onPressed: () {
            rootStore.downloadJson();
          },
          icon: const Icon(Icons.file_download),
          label: const Text("Export"),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(46);
}
