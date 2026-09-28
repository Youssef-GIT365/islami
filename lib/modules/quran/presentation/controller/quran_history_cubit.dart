import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/usecases/get_reading_history.dart';
import 'package:islami/modules/quran/presentation/controller/quran_history_state.dart';

/// Owns the state of the "Most Recently" strip.
///
/// The initial state is derived synchronously from [preloaded], the value the composition
/// root already read during startup, so this Cubit never emits a loading state and the strip
/// is painted correctly on its first frame (FR-014, research.md R-005). [refresh] performs
/// later reads, for example when the reader returns from a sura they just opened.
class QuranHistoryCubit extends Cubit<QuranHistoryState> {
  QuranHistoryCubit({
    required GetReadingHistory getReadingHistory,
    required ReadingHistory preloaded,
  }) : _getReadingHistory = getReadingHistory,
       super(_resolve(preloaded));

  final GetReadingHistory _getReadingHistory;

  /// Reloads the history, resolving any empty or failed read to the fallback state.
  ///
  /// Never throws and never emits a loading state: an unreadable history is presented the
  /// same way as an empty one, because the reader-visible outcome is identical (FR-015).
  Future<void> refresh() async {
    try {
      emit(_resolve(await _getReadingHistory()));
    } on Failure {
      emit(QuranHistoryState.fallback());
    }
  }

  static QuranHistoryState _resolve(ReadingHistory history) {
    if (history.isEmpty) return QuranHistoryState.fallback();
    return QuranHistoryState.resolved(history.entries);
  }
}
