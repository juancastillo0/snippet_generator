import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/types/root_store.dart';

class DbConnectionForm extends HookWidget {
  const DbConnectionForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useRootStore(context).databaseStore.connectionStore;
    final showForm = useState(true);
    useListenable(store.connectionState);

    final connectionState = store.connectionState.value;

    final _stateInfo = Container(
      padding: const EdgeInsets.all(6) + const EdgeInsets.only(left: 6),
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: connectionState.map(
                loading: (_) => const Text('Connecting...'),
                idle: (_) => const Text('No Database Connection'),
                success: (state) {
                  final settings = state.request;
                  return Text(
                    "Connected to: '${settings.user}:******@${settings.host}:${settings.port}/${settings.db}'",
                  );
                },
                error: (error) {
                  final theme = Theme.of(context);
                  return Card(
                    color: theme.colorScheme.error,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Error: ${error.error}',
                              style: theme.textTheme.bodyText1!.copyWith(
                                color: theme.colorScheme.onError,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              primary: theme.colorScheme.onError,
                            ),
                            onPressed: () {
                              store.connectionState.idle();
                            },
                            child: const Text('Hide'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          OutlinedButton(
            onPressed: connectionState.isLoading
                ? null
                : () {
                    if (!showForm.value) {
                      showForm.value = true;
                      store.host.focusNode.requestFocus();
                    } else {
                      store.connect();
                    }
                  },
            child: const Text('CONNECT'),
          )
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: !showForm.value
              ? _stateInfo
              : Column(
                  children: [
                    _stateInfo,
                    const DbConnectionInputs(),
                  ],
                ),
        ),
        IconButton(
          splashRadius: 24,
          onPressed: () {
            showForm.value = !showForm.value;
          },
          tooltip: showForm.value
              ? 'Hide database connection form'
              : 'Show database connection form',
          icon: showForm.value
              ? const Icon(Icons.keyboard_arrow_up_rounded)
              : const Icon(Icons.keyboard_arrow_down_rounded),
          // label: const Text("Hide"),
        ),
      ],
    );
  }
}

class DbConnectionInputs extends HookWidget {
  const DbConnectionInputs({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useRootStore(context).databaseStore.connectionStore;
    return FocusTraversalGroup(
      child: Wrap(
        spacing: 5,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          SizedBox(
            width: 130,
            child: TextField(
              decoration: const InputDecoration(labelText: 'Host'),
              controller: store.host.controller,
              focusNode: store.host.focusNode,
            ),
          ),
          SizedBox(
            width: 70,
            child: TextField(
              decoration: const InputDecoration(labelText: 'Port'),
              controller: store.port.controller,
              focusNode: store.port.focusNode,
            ),
          ),
          SizedBox(
            width: 130,
            child: TextField(
              decoration: const InputDecoration(labelText: 'User'),
              controller: store.user.controller,
              focusNode: store.user.focusNode,
            ),
          ),
          SizedBox(
            width: 130,
            child: TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              controller: store.password.controller,
              focusNode: store.password.focusNode,
            ),
          ),
          SizedBox(
            width: 130,
            child: TextField(
              decoration: const InputDecoration(labelText: 'Database'),
              controller: store.db.controller,
              focusNode: store.db.focusNode,
            ),
          ),
        ],
      ),
    );
  }
}
