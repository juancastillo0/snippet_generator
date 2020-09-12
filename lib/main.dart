import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/models.dart';
import 'package:snippet_generator/templates.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final typeConfig = useMemoized(() => TypeConfig());

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 150,
            child: ListView(
              children: [
                FlatButton(
                  onPressed: () {},
                  child: const Text("Class"),
                )
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RowTextField(
                    label: "Type Name",
                    controller: typeConfig.name,
                  ),
                  Row(
                    children: {
                      "Data Value": typeConfig.isDataValue,
                      "Listenable": typeConfig.isListenable,
                      "Serializable": typeConfig.isSerializable,
                      "Sum Type": typeConfig.isSumType
                    }
                        .entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: RowBoolField(
                              label: e.key,
                              notifier: e.value,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  typeConfig.classes.rebuild(
                    (classes) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: classes
                          .map((e) => ClassPropertiesTable(data: e))
                          .toList(),
                    ),
                  ),
                  typeConfig.isSumType.rebuild(
                    (isSumType) => isSumType
                        ? RaisedButton.icon(
                            onPressed: () =>
                                typeConfig.classes.add(ClassConfig(typeConfig)),
                            icon: const Icon(Icons.add),
                            label: const Text("Add Class"),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CodeGenerated(
                typeConfig: typeConfig,
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => properties.add,
      //   tooltip: 'Add',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

class RowBoolField extends StatelessWidget {
  const RowBoolField({
    Key key,
    @required this.notifier,
    @required this.label,
  }) : super(key: key);

  final AppNotifier<bool> notifier;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        notifier.rebuild(
          (value) => Checkbox(
            value: value,
            onChanged: notifier.set,
          ),
        ),
      ],
    );
  }
}

class RowTextField extends StatelessWidget {
  const RowTextField({
    Key key,
    @required this.controller,
    @required this.label,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 15),
        SizedBox(
          width: 150,
          child: TextField(
            controller: controller,
          ),
        ),
      ],
    );
  }
}

class ClassPropertiesTable extends StatelessWidget {
  const ClassPropertiesTable({Key key, @required this.data}) : super(key: key);
  final ClassConfig data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          data.typeConfig.isSumType.rebuild(
            (isSumType) => isSumType
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RowTextField(
                        controller: data.name,
                        label: "Class Name",
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: RowBoolField(
                          label: "Private", 
                          notifier: data.isPrivate,
                        ),
                      ),
                      RaisedButton.icon(
                        onPressed: () => data.typeConfig.classes.remove(data),
                        icon: const Icon(Icons.delete),
                        label: const Text("Remove Class"),
                      )
                    ],
                  )
                : const SizedBox(),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: data.properties.rebuild(
                  (properties) => DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text('Name'),
                      ),
                      DataColumn(
                        label: Text('Type'),
                      ),
                      DataColumn(
                        label: Text('Required'),
                      ),
                      DataColumn(
                        label: Text('Positional'),
                      ),
                    ],
                    rows: properties.map(_makeRow).toList(),
                  ),
                ),
              ),
            ),
          ),
          RaisedButton.icon(
            onPressed: () => data.properties.add(PropertyField()),
            icon: const Icon(Icons.add),
            label: const Text("Add Field"),
          )
        ],
      ),
    );
  }

  DataRow _makeRow(PropertyField property) {
    const _contraints = BoxConstraints(minWidth: 100, maxWidth: 200);
    return DataRow(
      cells: <DataCell>[
        DataCell(ConstrainedBox(
          constraints: _contraints,
          child: TextField(
            controller: property.name,
          ),
        )),
        DataCell(ConstrainedBox(
          constraints: _contraints,
          child: TextField(
            controller: property.type,
          ),
        )),
        DataCell(
          Center(
            child: property.isRequired.rebuild(
              (isRequired) => Checkbox(
                value: isRequired,
                onChanged: property.isRequired.set,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: property.isPositional.rebuild(
              (isPositional) => Checkbox(
                value: isPositional,
                onChanged: property.isPositional.set,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CodeGenerated extends HookWidget {
  const CodeGenerated({
    Key key,
    @required this.typeConfig,
  }) : super(key: key);
  final TypeConfig typeConfig;

  @override
  Widget build(BuildContext context) {
    useListenable(typeConfig.deepListenable);

    String sourceCode;
    if (typeConfig.isSumType.value) {
      sourceCode = templateSumType(typeConfig);
    } else {
      final _class = typeConfig.classes.value[0];
      sourceCode = templateClass(_class);
    }
    return Column(
      children: [
        RaisedButton.icon(
          onPressed: () => Clipboard.setData(ClipboardData(text: sourceCode)),
          icon: const Icon(Icons.copy),
          label: const Text("Copy Source Code"),
        ),
        const SizedBox(height: 10),
        Text(sourceCode),
      ],
    );
  }
}
