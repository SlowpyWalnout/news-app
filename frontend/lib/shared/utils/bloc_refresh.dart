import 'package:flutter_bloc/flutter_bloc.dart';

/// Shared `RefreshIndicator.onRefresh` body: dispatch [event] and wait for
/// the bloc to leave its loading state. Swallows the `StateError` that
/// `stream.firstWhere` throws when the tab (and its bloc) gets closed mid
/// pull-to-refresh — there's nothing left to show or fail in that case.
Future<void> refreshAndSettle<E, S>({
  required Bloc<E, S> bloc,
  required E event,
  required bool Function(S state) isSettled,
}) async {
  if (bloc.isClosed) return;
  bloc.add(event);
  try {
    await bloc.stream.firstWhere(isSettled);
  } on StateError {
    // Tab cerrada a mitad del refresh: el bloc se cerró antes de un estado
    // terminal. No hay nada que mostrar ni que fallar.
  }
}
