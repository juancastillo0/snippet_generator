import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:snippet_generator/globals/models.dart';
import 'package:snippet_generator/notifiers/rebuilder.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/parsers/widget_parsers/widget_parser.dart';
import 'package:snippet_generator/utils/persistence.dart';
import 'package:snippet_generator/parsers/type_parser.dart';
import 'package:snippet_generator/utils/set_up_globals.dart';
import 'package:snippet_generator/utils/theme.dart';
import 'package:snippet_generator/widgets/app_bar.dart';
import 'package:snippet_generator/widgets/globals.dart';
import 'package:snippet_generator/parsers/views/parsers_view.dart';
import 'package:snippet_generator/themes/themes_tab_view.dart';
import 'package:snippet_generator/types/views/types_tab_view.dart';
import 'package:url_strategy/url_strategy.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

Future<void> main() async {
  setPathUrlStrategy();
  LicenseRegistry.addLicense(() async* {
    final licenseCousine =
        await rootBundle.loadString('google_fonts/LICENSE.txt');
    final licenseNunitoSans =
        await rootBundle.loadString('google_fonts/OFL.txt');

    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseCousine);
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseNunitoSans);
  });

  setUpGlobals();
  JsonTypeParser.init();
  WidgetParser.init();
  await initHive();

  final rootStore = RootStore();
  Globals.add(rootStore);
  rootStore.loadHive();
  runApp(const MyApp());
}

class MyApp extends HookWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    final rootStore = Globals.get<RootStore>();
    useListenable(rootStore.themeModeNotifier);

    return RootStoreProvider(
      rootStore: rootStore,
      child: Portal(
        child: GlobalKeyboardListener.wrapper(
          child: MaterialApp(
            title: 'Snippet Generator',
            debugShowCheckedModeBanner: false,
            theme: lightTheme(),
            darkTheme: darkTheme(),
            themeMode: rootStore.themeModeNotifier.value,
            scrollBehavior: const ScrollBehavior().copyWith(
              scrollbars: false,
              overscroll: false,
            ),
            navigatorObservers: [routeObserver],
            home: const MyHomePage(),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootStore = Globals.get<RootStore>();
    return Scaffold(
      appBar: const HomePageAppBar(),
      body: RootStoreMessager(
        rootStore: rootStore,
        child: Rebuilder(
          builder: (context) {
            return IndexedStack(
              index: rootStore.selectedTab.index,
              children: const [
                TypesTabView(),
                ParsersView(),
                ThemesTabView(),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum SnackbarType {
  error,
  info,
}

class RootStoreMessager extends HookWidget {
  const RootStoreMessager({
    Key? key,
    required this.child,
    required this.rootStore,
  }) : super(key: key);
  final Widget child;
  final RootStore rootStore;

  @override
  Widget build(BuildContext context) {
    final messager = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    useEffect(() {
      void _showSnackbar(
        String content, {
        SnackbarType type = SnackbarType.info,
      }) {
        messager.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 350,
            backgroundColor:
                type == SnackbarType.error ? theme.colorScheme.error : null,
            content: Text(
              content,
              style: theme.textTheme.bodyText1!.copyWith(
                color: type == SnackbarType.error
                    ? theme.colorScheme.onError
                    : theme.colorScheme.onBackground,
              ),
            ),
          ),
        );
      }

      final subs = rootStore.messageEvents.listen((messageEvent) {
        switch (messageEvent) {
          case MessageEvent.sourceCodeCopied:
            return _showSnackbar("Source code copied");
          case MessageEvent.typeCopied:
            return _showSnackbar("Type copied");
          case MessageEvent.typesSaved:
            return _showSnackbar("Types saved");
          case MessageEvent.errorImportingTypes:
            return _showSnackbar("Invalid json file", type: SnackbarType.error);
        }
      });
      return subs.cancel;
    }, [rootStore]);

    return child;
  }
}
