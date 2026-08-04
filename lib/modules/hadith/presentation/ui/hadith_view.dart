import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/modules/hadith/data/data_source.dart';
import 'package:islami/modules/hadith/presentation/controller/HadithBloc.dart';
import 'package:islami/modules/hadith/presentation/controller/HadithEvent.dart';
import 'package:islami/modules/hadith/presentation/controller/HadithState.dart';
import 'package:islami/modules/hadith/presentation/ui/hadith_screen.dart';

class HadithView extends StatelessWidget {
  const HadithView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HadithBloc(dataSource: HadithRemoteDataSourceImpl(dio: Dio()))
            ..add(FetchHadiths(page: 1)),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.images.secoundScreenBackground.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Assets.images.firstScreenLogo.image(
                      height: 130,
                      width: 291,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BlocBuilder<HadithBloc, HadithState>(
                    builder: (context, state) {
                      if (state is HadithLoading || state is HadithInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.Gold,
                          ),
                        );
                      } else if (state is HadithSuccess) {
                        return PageView.builder(
                          itemCount: state.hadiths.length,
                          itemBuilder: (context, index) {
                            final hadith = state.hadiths[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HadithScreen(hadith: hadith),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.Gold,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: AppColors.Gold,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Assets.images.leftCorner
                                                .image(width: 80),
                                          ),
                                        ),
                                        Text(
                                          hadith.dynamicTitle,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.Black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Assets.images.rightCorner
                                                .image(width: 80),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Text(
                                          hadith.hadithArabic,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: AppColors.Black,
                                            height: 1.6,
                                          ),
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.rtl,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Assets.images.mosque022.image(
                                      fit: BoxFit.contain,
                                      alignment: Alignment.bottomCenter,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is HadithError) {
                        print(state.message);
                        return const Center(
                          child: Text(
                            "Error",
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
