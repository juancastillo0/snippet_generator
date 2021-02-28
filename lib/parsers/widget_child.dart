abstract class Nested<V> {
  const Nested._();

  const factory Nested.child(
    V child,
  ) = _Child;
  const factory Nested.children(
    List<V> children,
  ) = _Children;

  T when<T>({
    required T Function(V child) child,
    required T Function(List<V> children) children,
  }) {
    final Nested<V> v = this;
    if (v is _Child<V>) return child(v.child);
    if (v is _Children<V>) return children(v.children);
    throw "";
  }

  T? maybeWhen<T>({
    T Function()? orElse,
    T Function(V child)? child,
    T Function(List<V> children)? children,
  }) {
    final Nested<V> v = this;
    if (v is _Child<V>) return child != null ? child(v.child) : orElse?.call();
    if (v is _Children<V>)
      return children != null ? children(v.children) : orElse?.call();
    throw "";
  }

  T map<T>({
    required T Function(_Child value) child,
    required T Function(_Children value) children,
  }) {
    final Nested<V> v = this;
    if (v is _Child<V>) return child(v);
    if (v is _Children<V>) return children(v);
    throw "";
  }

  T? maybeMap<T>({
    T Function()? orElse,
    T Function(_Child value)? child,
    T Function(_Children value)? children,
  }) {
    final Nested<V> v = this;
    if (v is _Child<V>) return child != null ? child(v) : orElse?.call();
    if (v is _Children<V>)
      return children != null ? children(v) : orElse?.call();
    throw "";
  }
}

class _Child<V> extends Nested<V> {
  final V child;

  const _Child(
    this.child,
  ) : super._();
}

class _Children<V> extends Nested<V> {
  final List<V> children;

  const _Children(
    this.children,
  ) : super._();
}
