import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/modules/time/data/data_source/pray_time_data_source.dart';
import 'package:islami/modules/time/data/repo/pray_time_repo_imp.dart';
import 'package:islami/modules/time/domain/usecase/pray_time_usecase.dart';
import 'package:islami/modules/time/presentation/controller/prayer_time_cubit.dart';
import 'package:islami/modules/time/presentation/controller/prayer_time_state.dart';
import 'package:islami/modules/time/presentation/cutomWidget/azkar_section.dart';

class TimeView extends StatelessWidget {
  const TimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final remoteDataSource = RemoteDataSource();
    final prayTimeRepo = PrayTimeRepoImp(remoteDataSource: remoteDataSource);
    final prayTimeUsecase = PrayTimeUsecase(prayTimeRepo: prayTimeRepo);

    return BlocProvider(
      create: (BuildContext context) =>
          PrayerTimeCubit(prayTimeUsecase: prayTimeUsecase)..getPrayerTime(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.forthScreenBackground.provider(),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
              builder: (BuildContext context, state) {
                if (state is PrayerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PrayerLoaded) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final h = constraints.maxHeight;
                      final w = constraints.maxWidth;

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: h * .02),
                            Assets.images.firstScreenLogo.image(
                              height: h * .18,
                              width: w * .65,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: h * .015),
                            Container(
                              width: w * .90,
                              margin: EdgeInsets.all(h * 0.01),
                              decoration: const BoxDecoration(
                                color: Color(0xff856B3F),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35),
                                ),
                              ),
                              child: ClipRRect(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      left: w * -0.03,

                                      right: w * -0.03,
                                      child: Assets.images.prayImage2.image(
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: h * .14,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: w * .03,
                                                    top: h * .018,
                                                  ),
                                                  child: Text(
                                                    formatGregorianDate(
                                                      state
                                                          .prayerDay
                                                          .gregorianDate,
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: w * .035,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    top: h * .012,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Pray Time",
                                                        style: TextStyle(
                                                          color:
                                                              const Color(
                                                                0xff202020,
                                                              ).withValues(
                                                                alpha: .75,
                                                              ),
                                                          fontSize: w * .038,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: h * .004,
                                                      ),
                                                      Text(
                                                        "Tuesday",
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xff202020,
                                                          ),
                                                          fontSize: w * .044,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    right: w * .03,
                                                    top: h * .018,
                                                  ),
                                                  child: Text(
                                                    formatHijriDate(
                                                      state.prayerDay.hijriDate,
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: w * .035,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: h * .008),
                                        SizedBox(
                                          height: h * .24,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: w * .02,
                                            ),
                                            itemCount: state
                                                .prayerDay
                                                .prayTimeList
                                                .length,
                                            itemBuilder: (context, index) {
                                              final item = state
                                                  .prayerDay
                                                  .prayTimeList[index];
                                              final isSelected = index == 2;

                                              return Container(
                                                width: w * .25,
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: w * .01,
                                                  vertical: h * .01,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: h * .012,
                                                  horizontal: w * .015,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  gradient:
                                                      const LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          Color(0xff3D362C),
                                                          Color(0xff9E8A63),
                                                        ],
                                                      ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        item.name.toUpperCase(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: w * .035,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        formatTimeOnly(
                                                          item.time,
                                                        ),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: isSelected
                                                              ? w * .075
                                                              : w * .065,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        formatPeriodOnly(
                                                          item.time,
                                                        ),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: w * .032,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(height: h * .012),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: w * .06,
                                            vertical: h * .012,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SizedBox(width: 20),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Next Pray - ",
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xff202020,
                                                      ).withValues(alpha: .8),
                                                      fontSize: w * .036,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    "02:32",
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xff202020,
                                                      ),
                                                      fontSize: w * .038,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Icon(
                                                Icons.volume_off_rounded,
                                                color: Color(0xff202020),
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: h * .02),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * .06,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Azkar",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: w * .05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AzkarSection(),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }
}

String formatGregorianDate(String dateStr) {
  final parts = dateStr.split('-');
  if (parts.length != 3) return dateStr;

  final day = parts[0];
  final monthNum = int.tryParse(parts[1]) ?? 1;
  final year = parts[2];

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final monthName = months[monthNum - 1];

  return '$day $monthName,\n$year';
}

String formatHijriDate(String dateStr) {
  final parts = dateStr.split('-');
  if (parts.length != 3) return dateStr;

  final day = parts[0];
  final monthNum = int.tryParse(parts[1]) ?? 1;
  final year = parts[2];

  const hijriMonths = [
    'Muh',
    'Saf',
    'Rab I',
    'Rab II',
    'Jum I',
    'Jum II',
    'Raj',
    'Sha',
    'Ram',
    'Shaw',
    'Dhu Q',
    'Dhu H',
  ];

  final monthName = hijriMonths[monthNum - 1];

  return '$day $monthName,\n$year';
}

String formatTimeOnly(String time) {
  final parts = time.split(':');
  int hour = int.parse(parts[0]);
  final minute = parts[1];

  hour = hour % 12;
  if (hour == 0) hour = 12;

  return '${hour.toString().padLeft(2, '0')}:$minute';
}

String formatPeriodOnly(String time) {
  final parts = time.split(':');
  int hour = int.parse(parts[0]);
  return hour >= 12 ? 'PM' : 'AM';
}
