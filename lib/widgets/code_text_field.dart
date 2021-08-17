import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stack_portal/stack_portal.dart';

class CodeTextField extends HookWidget {
  const CodeTextField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final text = useSelectListenable(controller, () => controller.text);

    return LayoutBuilder(
      builder: (context, box) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Builder(
            builder: (context) {
              final list = text.split('\n');
              final _maxCharacters = list.isEmpty
                  ? 100
                  : list
                      .reduce(
                        (value, element) =>
                            value.length > element.length ? value : element,
                      )
                      .length;
              final _w = _maxCharacters * 8 + 20.0;
              return SizedBox(
                width: box.maxWidth > _w ? box.maxWidth : _w,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  style: GoogleFonts.cousine(fontSize: 13),
                  controller: controller,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
