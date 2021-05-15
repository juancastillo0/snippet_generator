import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_generator/database/database_store.dart';
import 'package:snippet_generator/types/root_store.dart';

class DatabaseTabView extends HookWidget {
  const DatabaseTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final root = useRootStore(context);
    final DatabaseStore store = root.databaseStore;
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              style: GoogleFonts.cousine(fontSize: 13),
              controller: store.rawTableDefinition.controller,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Observer(
            builder: (context) {
              final parseResult = store.parsedTableDefinition.value;
              return Column(
                children: [
                  Expanded(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Nullable')),
                        DataColumn(label: Text('Default')),
                      ],
                      rows: [],
                    ),
                  ),
                  Expanded(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Nullable')),
                        DataColumn(label: Text('Default')),
                      ],
                      rows: [],
                    ),
                  ),
                  Expanded(child: Text(parseResult.toString())),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}