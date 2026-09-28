import 'package:get_it/get_it.dart';
import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/quran/data/datasources/reading_history_local_datasource.dart';
import 'package:islami/modules/quran/data/repositories/reading_history_store_impl.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/repositories/reading_history_store.dart';
import 'package:islami/modules/quran/domain/usecases/get_reading_history.dart';
import 'package:islami/modules/quran/domain/usecases/record_sura_opened.dart';
import 'package:islami/modules/quran/domain/usecases/record_verse_viewed.dart';
import 'package:islami/modules/quran/presentation/controller/quran_history_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The application's central composition root (constitution II).
///
/// Registration is idempotent so a hot restart or a test can call this more than once.
/// The legacy radio locators are intentionally left untouched: they register into this
/// same `GetIt` instance from their own `setupServiceLocator` functions and are not
/// migrated here, to keep the change scoped to the Quran feature.
final GetIt sl = GetIt.instance;

/// Registers the Quran reading-history graph and performs the single startup read.
///
/// Reading the stored history once here means the UI can be built synchronously from a
/// resolved [ReadingHistory] and never has to render a loading or error state for it
/// (FR-016, FR-018). A storage failure is non-fatal: it degrades to an empty history
/// rather than surfacing an error (FR-015).
///
/// Returns the preloaded history.
Future<ReadingHistory> configureDependencies() async {
  if (!sl.isRegistered<SharedPreferencesAsync>()) {
    sl.registerLazySingleton<SharedPreferencesAsync>(SharedPreferencesAsync.new);
  }

  if (!sl.isRegistered<ReadingHistoryLocalDataSource>()) {
    sl.registerLazySingleton<ReadingHistoryLocalDataSource>(
      () => ReadingHistoryLocalDataSource(sl<SharedPreferencesAsync>()),
    );
  }

  if (!sl.isRegistered<ReadingHistoryStore>()) {
    sl.registerLazySingleton<ReadingHistoryStore>(
      () => ReadingHistoryStoreImpl(sl<ReadingHistoryLocalDataSource>()),
    );
  }

  if (!sl.isRegistered<GetReadingHistory>()) {
    sl.registerFactory<GetReadingHistory>(
      () => GetReadingHistory(sl<ReadingHistoryStore>()),
    );
  }

  if (!sl.isRegistered<RecordSuraOpened>()) {
    sl.registerFactory<RecordSuraOpened>(
      () => RecordSuraOpened(sl<ReadingHistoryStore>()),
    );
  }

  if (!sl.isRegistered<RecordVerseViewed>()) {
    sl.registerFactory<RecordVerseViewed>(
      () => RecordVerseViewed(sl<ReadingHistoryStore>()),
    );
  }

  if (!sl.isRegistered<QuranHistoryCubit>()) {
    sl.registerFactory<QuranHistoryCubit>(
      () => QuranHistoryCubit(
        getReadingHistory: sl<GetReadingHistory>(),
        preloaded: sl<ReadingHistory>(),
      ),
    );
  }

  if (sl.isRegistered<ReadingHistory>()) {
    return sl<ReadingHistory>();
  }

  final ReadingHistory preloaded = await _preloadReadingHistory();
  sl.registerSingleton<ReadingHistory>(preloaded);
  return preloaded;
}

Future<ReadingHistory> _preloadReadingHistory() async {
  try {
    return await GetReadingHistory(sl<ReadingHistoryStore>())();
  } on Failure {
    return ReadingHistory.empty();
  }
}
