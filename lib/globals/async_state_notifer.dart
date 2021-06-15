import 'package:snippet_generator/globals/async_state.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';

class AsyncStateNotifier<R, T, E> extends AppNotifier<AsyncState<R, T, E>> {
  AsyncStateNotifier([AsyncState<R, T, E> value = const AsyncState.idle()])
      : super(value);

  void loading(R request, {T? previous}) {
    value = AsyncState.loading(request, previous: previous);
  }

  void idle() {
    value = const AsyncState.idle();
  }

  void success(T success, {required R request}) {
    value = AsyncState.success(success, request: request);
  }

  void error(E error) {
    value = AsyncState.error(error);
  }
}
