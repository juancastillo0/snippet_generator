import 'package:flutter/foundation.dart';
import 'package:snippet_generator/globals/models.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/notifiers/collection_notifier/collection_notifier.dart';

class NestedNotifier extends ChangeNotifier {
  final _notifiers = <AppNotifier>[];
  final _nestedNotifiers = <NestedNotifier>[];
  final _collectionNotifiers = <EventConsumer>[];

  final String? propKey;

  NestedNotifier({
    NestedNotifier? parent,
    String? key,
    String? parentKey,
    this.propKey,
  }) {
    parent?.registerNested(this);
    if (key != null) {
      final children = Globals.popNested(key);
      if (children != null) {
        for (final child in children) {
          if (child is AppNotifier) {
            _notifiers.add(child);
          } else if (child is NestedNotifier) {
            _nestedNotifiers.add(child);
          } else if (child is EventConsumer) {
            _collectionNotifiers.add(child);
          }
        }
      }
    }
    if (parentKey != null) {
      Globals.addNested(parentKey, this);
    }
  }

  Map<String?, dynamic> toJson() {
    return Map.fromEntries(
      _notifiers
          .map(
            (e) => MapEntry(e.name, e.toJson()),
          )
          .followedBy(
            _nestedNotifiers.map(
              (e) => MapEntry(e.propKey!, e.toJson()),
            ),
          )
          .followedBy(
            _collectionNotifiers.map(
              (e) => MapEntry(e.propKey!, e.toJson()),
            ),
          ),
    );
  }

  void fromJson(Map<String, dynamic>? json) {
    for (final notifier in _notifiers) {
      if (json!.containsKey(notifier.name)) {
        notifier.trySetFromJson(json[notifier.name]);
      }
    }

    for (final notifier in _nestedNotifiers) {
      if (json!.containsKey(notifier.propKey)) {
        notifier.fromJson(json[notifier.propKey!] as Map<String, dynamic>?);
      }
    }

    for (final notifier in _collectionNotifiers) {
      if (json!.containsKey(notifier.propKey)) {
        notifier.trySetFromJson(json[notifier.propKey!]);
      }
    }
  }

  void registerValue(AppNotifier notifier) {
    _notifiers.add(notifier);
  }

  void registerNested(NestedNotifier notifier) {
    _nestedNotifiers.add(notifier);
  }

  void registerCollection(EventConsumer notifier) {
    _collectionNotifiers.add(notifier);
  }
}
