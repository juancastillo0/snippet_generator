abstract class AsyncState<R, S, E> {
  const AsyncState._();

  const factory AsyncState.loading(
    R request, {
    S? previous,
  }) = _Loading;
  const factory AsyncState.idle() = _Idle;
  const factory AsyncState.success(
    S value, {
    required R request,
  }) = _Success;
  const factory AsyncState.error(
    E error,
  ) = _Error;

  _T when<_T>({
    required _T Function(R request, S? previous) loading,
    required _T Function() idle,
    required _T Function(S value, R request) success,
    required _T Function(E error) error,
  }) {
    final v = this;
    if (v is _Loading<R, S, E>) {
      return loading(v.request, v.previous);
    } else if (v is _Idle<R, S, E>) {
      return idle();
    } else if (v is _Success<R, S, E>) {
      return success(v.value, v.request);
    } else if (v is _Error<R, S, E>) {
      return error(v.error);
    }
    throw Exception();
  }

  _T maybeWhen<_T>({
    required _T Function() orElse,
    _T Function(R request, S? previous)? loading,
    _T Function()? idle,
    _T Function(S value, R request)? success,
    _T Function(E error)? error,
  }) {
    final v = this;
    if (v is _Loading<R, S, E>) {
      return loading != null ? loading(v.request, v.previous) : orElse.call();
    } else if (v is _Idle<R, S, E>) {
      return idle != null ? idle() : orElse.call();
    } else if (v is _Success<R, S, E>) {
      return success != null ? success(v.value, v.request) : orElse.call();
    } else if (v is _Error<R, S, E>) {
      return error != null ? error(v.error) : orElse.call();
    }
    throw Exception();
  }

  _T map<_T>({
    required _T Function(_Loading<R, S, E> value) loading,
    required _T Function(_Idle<R, S, E> value) idle,
    required _T Function(_Success<R, S, E> value) success,
    required _T Function(_Error<R, S, E> value) error,
  }) {
    final v = this;
    if (v is _Loading<R, S, E>) {
      return loading(v);
    } else if (v is _Idle<R, S, E>) {
      return idle(v);
    } else if (v is _Success<R, S, E>) {
      return success(v);
    } else if (v is _Error<R, S, E>) {
      return error(v);
    }
    throw Exception();
  }

  _T maybeMap<_T>({
    required _T Function() orElse,
    _T Function(_Loading<R, S, E> value)? loading,
    _T Function(_Idle<R, S, E> value)? idle,
    _T Function(_Success<R, S, E> value)? success,
    _T Function(_Error<R, S, E> value)? error,
  }) {
    final v = this;
    if (v is _Loading<R, S, E>) {
      return loading != null ? loading(v) : orElse.call();
    } else if (v is _Idle<R, S, E>) {
      return idle != null ? idle(v) : orElse.call();
    } else if (v is _Success<R, S, E>) {
      return success != null ? success(v) : orElse.call();
    } else if (v is _Error<R, S, E>) {
      return error != null ? error(v) : orElse.call();
    }
    throw Exception();
  }

  bool get isLoading => this is _Loading;
  bool get isIdle => this is _Idle;
  bool get isSuccess => this is _Success;
  bool get isError => this is _Error;

  AsyncState<_T, S, E> mapGenericR<_T>(_T Function(R) mapper) {
    return map(
      loading: (v) =>
          AsyncState.loading(mapper(v.request), previous: v.previous),
      idle: (v) => AsyncState.idle(),
      success: (v) => AsyncState.success(v.value, request: mapper(v.request)),
      error: (v) => AsyncState.error(v.error),
    );
  }

  AsyncState<R, _T, E> mapGenericS<_T>(_T Function(S) mapper) {
    return map(
      loading: (v) => AsyncState.loading(v.request,
          previous: v.previous == null ? null : mapper(v.previous!)),
      idle: (v) => AsyncState.idle(),
      success: (v) => AsyncState.success(mapper(v.value), request: v.request),
      error: (v) => AsyncState.error(v.error),
    );
  }

  AsyncState<R, S, _T> mapGenericE<_T>(_T Function(E) mapper) {
    return map(
      loading: (v) => AsyncState.loading(v.request, previous: v.previous),
      idle: (v) => AsyncState.idle(),
      success: (v) => AsyncState.success(v.value, request: v.request),
      error: (v) => AsyncState.error(mapper(v.error)),
    );
  }
}

class _Loading<R, S, E> extends AsyncState<R, S, E> {
  final S? previous;
  final R request;

  const _Loading(
    this.request, {
    this.previous,
  }) : super._();
}

class _Idle<R, S, E> extends AsyncState<R, S, E> {
  const _Idle() : super._();
}

class _Success<R, S, E> extends AsyncState<R, S, E> {
  final S value;
  final R request;

  const _Success(
    this.value, {
    required this.request,
  }) : super._();
}

class _Error<R, S, E> extends AsyncState<R, S, E> {
  final E error;

  const _Error(
    this.error,
  ) : super._();
}
