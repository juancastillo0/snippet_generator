import 'package:flutter/material.dart';

class RebuilderGlobalScope {
  static final RebuilderGlobalScope instance = RebuilderGlobalScope._();
  RebuilderGlobalScope._();

  final List<Set<Listenable>> _scopes = [];

  void pushScope() {
    _scopes.add({});
  }

  Set<Listenable> popScope() {
    return _scopes.removeLast();
  }

  void addToScope(Listenable listenable) {
    if (_scopes.isNotEmpty) {
      _scopes.last.add(listenable);
    }
  }
}

class Rebuilder extends StatefulWidget {
  final Widget Function(BuildContext) builder;

  const Rebuilder({Key? key, required this.builder}) : super(key: key);
  @override
  _RebuilderState createState() => _RebuilderState();
}

class _RebuilderState extends State<Rebuilder> {
  Set<Listenable> listenables = {};

  void callback() {
    setState(() {});
  }

  void executeDiff(Set<Listenable> newListenables) {
    for (final l in newListenables.difference(listenables)) {
      l.addListener(callback);
    }
    for (final l in listenables.difference(newListenables)) {
      l.removeListener(callback);
    }
    listenables = newListenables;
  }

  @override
  Widget build(BuildContext context) {
    RebuilderGlobalScope.instance.pushScope();
    final child = widget.builder(context);
    final newListenables = RebuilderGlobalScope.instance.popScope();
    executeDiff(newListenables);
    return child;
  }
}
