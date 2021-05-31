import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/fields/base_fields.dart';
import 'package:snippet_generator/fields/button_select_field.dart';
import 'package:snippet_generator/globals/option.dart';
import 'package:snippet_generator/notifiers/collection_notifier/map_notifier.dart';
import 'package:snippet_generator/parsers/sql/data_type_model.dart';
import 'package:snippet_generator/utils/extensions.dart';

class SqlTypeField extends HookWidget {
  const SqlTypeField({
    Key? key,
    required this.value,
    required this.onChange,
  }) : super(key: key);

  final SqlType value;
  final void Function(SqlType) onChange;

  @override
  Widget build(BuildContext context) {
    final typeEnum = useState<TypeSqlType>(value.typeEnum);
    final typeMap = useMemoized(() {
      final _m = MapNotifier<TypeSqlType, SqlType>();
      _m[value.typeEnum] = value;
      return _m;
    });
    final _numVariants = value is SqlTypeEnumeration
        ? (value as SqlTypeEnumeration).variants.length
        : 1;
    final _createdVariants = useMemoized(
      () => Iterable.generate(_numVariants).toList(),
      [_numVariants],
    );
    useListenable(typeMap);

    void setValue(SqlType newType) {
      typeMap[typeEnum.value] = newType;
    }

    final __value = typeMap[typeEnum.value]!;

    Widget _form() {
      switch (typeEnum.value) {
        case TypeSqlType.integer:
          final _value = __value as SqlTypeInteger;
          final _options = SqlType.sqlIntegerBytes.entries.toList();
          return Column(
            children: [
              ButtonSelect<MapEntry<String, int>>(
                alwaysButtons: true,
                wrapHorizontal: true,
                selected: _options.firstWhere((e) => e.value == _value.bytes),
                asString: (e) => '${e.key}INT(${e.value})',
                onChange: (e) {
                  setValue(_value.copyWith(bytes: e.value));
                },
                options: _options,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('zerofill'),
                  Checkbox(
                    value: _value.zerofill,
                    onChanged: (value) {
                      setValue(_value.copyWith(zerofill: value));
                    },
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('unsigned'),
                  Checkbox(
                    value: _value.unsigned,
                    onChanged: (value) {
                      setValue(_value.copyWith(unsigned: value));
                    },
                  ),
                ],
              ),
            ],
          );
        case TypeSqlType.decimal:
          final _value = __value as SqlTypeDecimal;
          return Column(
            children: [
              ButtonSelect<SqlDecimalType>(
                alwaysButtons: true,
                wrapHorizontal: true,
                selected: _value.type,
                asString: (e) => e.toEnumString(),
                onChange: (e) {
                  final newValue = _value.copyWith(type: e);
                  if (_value.hasDefaultNumDigits()) {
                    setValue(newValue.copyWithDefaults());
                  } else {
                    setValue(newValue);
                  }
                },
                options: SqlDecimalType.values,
              ),
              if (_value.type == SqlDecimalType.FIXED) ...[
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('precision and scale'),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: IntInput(
                        label: 'total digits',
                        onChanged: (v) {
                          if (v != null && v >= 0) {
                            setValue(_value.copyWith(digitsTotal: v));
                          }
                        },
                        value: _value.digitsTotal,
                      ),
                    ),
                    Expanded(
                      child: IntInput(
                        label: 'decimal digits',
                        onChanged: (v) {
                          if (v != null && v >= 0) {
                            setValue(_value.copyWith(digitsDecimal: v));
                          }
                        },
                        value: _value.digitsDecimal,
                      ),
                    ),
                  ],
                )
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('zerofill'),
                  Checkbox(
                    value: _value.zerofill,
                    onChanged: (value) {
                      setValue(_value.copyWith(zerofill: value));
                    },
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('unsigned'),
                  Checkbox(
                    value: _value.unsigned,
                    onChanged: (value) {
                      setValue(_value.copyWith(unsigned: value));
                    },
                  ),
                ],
              ),
            ],
          );
        case TypeSqlType.json:
          return const SizedBox();
        case TypeSqlType.date:
          final _value = __value as SqlTypeDate;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ButtonSelect<SqlDateVariant>(
                alwaysButtons: true,
                wrapHorizontal: true,
                selected: _value.type,
                asString: (e) => e.toEnumString(),
                onChange: (e) {
                  setValue(_value.copyWith(type: e));
                },
                options: SqlDateVariant.values,
              ),
              if (!const [SqlDateVariant.DATE, SqlDateVariant.YEAR]
                  .contains(_value.type)) ...[
                const SizedBox(height: 12),
                const Text('Fractional Seconds'),
                ButtonSelect<int>(
                  alwaysButtons: true,
                  wrapHorizontal: true,
                  selected: _value.fractionalSeconds ?? 0,
                  asString: (e) => e.toString(),
                  onChange: (e) {
                    setValue(_value.copyWith(fractionalSeconds: Some(e)));
                  },
                  options: const [0, 1, 2, 3, 4, 5, 6],
                ),
              ],
            ],
          );
        case TypeSqlType.string:
          final _value = __value as SqlTypeString;
          return Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('binary'),
                  Checkbox(
                    value: _value.binary,
                    onChanged: (value) {
                      setValue(_value.copyWith(binary: value));
                    },
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('variable size'),
                  Checkbox(
                    value: _value.variableSize,
                    onChanged: (value) {
                      setValue(_value.copyWith(variableSize: value));
                    },
                  ),
                ],
              ),
              IntInput(
                label: 'size (${_value.binary ? "bytes" : "characters"})',
                onChanged: (v) {
                  if (v != null && v > 0) {
                    setValue(_value.copyWith(size: v));
                  }
                },
                value: _value.size,
              ),
            ],
          );
        case TypeSqlType.enumeration:
          final _value = __value as SqlTypeEnumeration;
          return Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('multiple values'),
                  Checkbox(
                    value: _value.allowMultipleValues,
                    onChanged: (value) {
                      setValue(_value.copyWith(allowMultipleValues: value));
                    },
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ..._value.variants.mapIndex(
                      (e, index) => Row(
                        key: ValueKey(_createdVariants[index]),
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: e,
                              autofocus: index == _value.variants.length - 1,
                              onChanged: (s) {
                                final _variants = [..._value.variants];
                                _variants[index] = s;
                                setValue(_value.copyWith(variants: _variants));
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: _value.variants.length == 1
                                ? null
                                : () {
                                    final _variants = [..._value.variants];
                                    _variants.removeAt(index);
                                    _createdVariants.removeAt(index);
                                    setValue(
                                        _value.copyWith(variants: _variants));
                                  },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _createdVariants.add(_createdVariants.last + 1);
                  setValue(_value.copyWith(variants: [..._value.variants, '']));
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          );
      }
    }

    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ButtonSelect<TypeSqlType>(
            alwaysButtons: true,
            wrapHorizontal: true,
            onChange: (v) {
              if (!typeMap.containsKey(v)) {
                typeMap[v] = SqlType.defaultSqlTypes[v]!;
              }
              typeEnum.value = v;
            },
            selected: typeEnum.value,
            options: TypeSqlType.values,
            asString: (v) => v.toEnumString(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8.0),
            child: _form(),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(top: 15),
            child: OutlinedButton(
              onPressed: () {
                onChange(__value);
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
