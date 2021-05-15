
import 'package:flutter/material.dart';
import 'package:snippet_generator/utils/extensions.dart';

class HorizontalItemList<T> extends StatelessWidget {
  const HorizontalItemList({
    Key? key,
    required this.items,
    required this.onSelected,
    required this.selected,
    required this.buildItem,
  }) : super(key: key);

  final List<T> items;
  final void Function(T, int) onSelected;
  final T? selected;
  final Widget Function(T) buildItem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 35,
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 3,
            spreadRadius: 1,
          )
        ],
        color: colorScheme.surface,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...items.mapIndex(
            (e, index) => TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    selected == e ? colorScheme.primary.withOpacity(0.2) : null,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                onSelected(e, index);
              },
              child: buildItem(e),
            ),
          )
        ],
      ),
    );
  }
}