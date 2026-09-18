import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/shared/utils/bloc_refresh.dart';

class _ProbeEvent {
  const _ProbeEvent();
}

class _ProbeBloc extends Bloc<_ProbeEvent, int> {
  _ProbeBloc() : super(0) {
    on<_ProbeEvent>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 20));
      if (isClosed) return;
      emit(1);
    });
  }
}

void main() {
  test('returns immediately without adding the event when the bloc is already closed', () async {
    final bloc = _ProbeBloc();
    await bloc.close();

    await refreshAndSettle(bloc: bloc, event: const _ProbeEvent(), isSettled: (s) => s == 1);

    expect(bloc.state, 0);
  });

  test('completes once the bloc reaches the settled state', () async {
    final bloc = _ProbeBloc();

    await refreshAndSettle(bloc: bloc, event: const _ProbeEvent(), isSettled: (s) => s == 1);

    expect(bloc.state, 1);
    await bloc.close();
  });

  test('swallows the StateError when the bloc closes mid-refresh', () async {
    final bloc = _ProbeBloc();

    final future = refreshAndSettle(bloc: bloc, event: const _ProbeEvent(), isSettled: (s) => s == 1);
    await Future.delayed(const Duration(milliseconds: 5));
    await bloc.close();

    await expectLater(future, completes);
  });
}
