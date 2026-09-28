import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/di/injection.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/core/routes/app_routes.dart';
import 'package:islami/modules/quran/presentation/controller/quran_history_cubit.dart';
import 'package:islami/modules/quran/presentation/controller/quran_history_state.dart';
import 'package:islami/modules/quran/presentation/ui/most_recently_strip.dart';
import 'package:islami/modules/quran/suras/sura_item.dart';
import 'package:islami/modules/quran/suras/sura_model.dart';

class QuranView extends StatefulWidget {
  const QuranView({super.key});

  @override
  State<QuranView> createState() => _QuranViewState();
}

/// Rebuilds [QuranView]'s history whenever the reading view is popped back to this screen.
///
/// The reading view is pushed on top of the layout route that hosts the Quran screen, so that
/// screen stays mounted and its `initState` does not re-run. Without this the strip would keep
/// showing the history as it stood *before* the reader opened a sura, and a strip tap would
/// then open the previously recorded verse rather than the one just read
/// (FR-002, SC-001, SC-007).
///
/// Subscribing by hand rather than through `ModalRoute.of(context)` is deliberate: [QuranView]
/// sits in the layout's body, not directly in a route builder, so the framework never
/// subscribes it automatically.
mixin _RefreshesOnRouteReturn on State<QuranView> implements RouteAware {
  ModalRoute<Object?>? _observedRoute;

  /// The Cubit created by this state's `BlocProvider`, captured so route callbacks can reach
  /// it. `context.read` cannot be used here: the state's context is an ancestor of the
  /// provider it creates.
  QuranHistoryCubit? _cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ModalRoute<Object?>? current = ModalRoute.of(context);
    if (identical(current, _observedRoute)) return;
    if (_observedRoute != null) AppRoutes.observer.unsubscribe(this);
    _observedRoute = current;
    if (current != null) AppRoutes.observer.subscribe(this, current);
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    // The State's own `context` sits above the `BlocProvider` that this state creates, so
    // reading the Cubit from it would throw. The created Cubit is captured instead.
    //
    // `refresh` is deliberately not awaited: this callback fires while the route is settling
    // and cannot suspend the transition. The Cubit emits its new state as soon as the read
    // completes, which rebuilds the strip on a normal frame.
    _cubit?.refresh();
  }

  @override
  void didPush() {}

  @override
  void didPushNext() {}

  @override
  void didPop() {}

  @override
  void dispose() {
    if (_observedRoute != null) AppRoutes.observer.unsubscribe(this);
    _observedRoute = null;
    _cubit = null;
    super.dispose();
  }
}

class _QuranViewState extends State<QuranView> with _RefreshesOnRouteReturn {
  List<int> filteredIndices = List.generate(arabicAuranSuras.length, (i) => i);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Re-read the history after the first frame so a sura opened in a previous session, or
    // recorded by another entry point, is reflected. The strip's first frame uses the value
    // preloaded in DI, so there is no loading state in between (FR-014, research.md R-005).
    // Returning from the reading view is handled by [_RefreshesOnRouteReturn.didPopNext].
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cubit?.refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredIndices = List.generate(arabicAuranSuras.length, (i) => i);
      } else {
        List<int> result = [];
        for (int i = 0; i < arabicAuranSuras.length; i++) {
          final nameAr = arabicAuranSuras[i].toLowerCase();
          final nameEn = englishQuranSurahs[i].toLowerCase();

          if (nameAr.contains(query) || nameEn.contains(query)) {
            result.add(i);
          }
        }

        filteredIndices = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuranHistoryCubit>(
      create: (BuildContext context) {
        final QuranHistoryCubit cubit = sl<QuranHistoryCubit>();
        _cubit = cubit;
        return cubit;
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.firstScreeenBackground.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
        child: Column(
          children: [
            Assets.images.firstScreenLogo.image(),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                _onSearch(value);
              },
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Assets.images.quranSvgrepoCom1.svg(
                    width: 28,
                    height: 28,
                  ),
                ),
                hintText: "sura name",
                hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.white,
                  fontSize: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.Gold),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.Gold, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Most Recently ",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
            BlocBuilder<QuranHistoryCubit, QuranHistoryState>(
              builder: (BuildContext context, QuranHistoryState state) {
                return MostRecentlyStrip(entries: state.entries);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "Suras List",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredIndices.length,
                itemBuilder: (BuildContext context, int index) {
                  final originalIndex = filteredIndices[index];
                  return SuraItem(
                    sura: SuraModel(
                      id: (originalIndex + 1).toString(),
                      surahNumber: originalIndex + 1,
                      nameAr: arabicAuranSuras[originalIndex],
                      nameEn: englishQuranSurahs[originalIndex],
                      verses: AyaNumber[originalIndex],
                    ),
                  );
                },
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
