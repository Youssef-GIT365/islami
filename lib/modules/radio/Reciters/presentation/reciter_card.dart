import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/modules/radio/Reciters/domain/entities/reciters_entitie.dart';
import 'package:islami/modules/radio/Reciters/presentation/controller/reciters_cubit.dart';
import 'package:islami/modules/radio/Reciters/presentation/controller/reciters_state.dart';

class recitersCard extends StatelessWidget {
  final RecitersEntitie reciters;

  const recitersCard({super.key, required this.reciters});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Reciterscubit, RecitersState>(
      builder: (context, state) {
        final cubit = context.read<Reciterscubit>();
        String formattedUrl = reciters.url.trim();
        if (formattedUrl.isNotEmpty && !formattedUrl.endsWith('.mp3')) {
          if (!formattedUrl.endsWith('/')) {
            formattedUrl += '/';
          }
          formattedUrl += '001.mp3';
        }
        final isPlaying =
            cubit.currentlyPlayingUrl == formattedUrl && cubit.isPlaying;
        bool isMuted = cubit.isMuted;
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.Gold,
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: Assets.images.mosque022.provider(),

              // fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  reciters.enName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: AppColors.Black,
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 36,
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.Black,
                    ),
                    onPressed: () {
                      cubit.playOrPause(reciters.url);
                    },
                  ),
                  IconButton(
                    iconSize: 36,
                    icon: Icon(
                      isPlaying
                          ? isMuted
                                ? Icons.volume_off
                                : Icons.volume_up
                          : Icons.volume_up,

                      color: AppColors.Black,
                    ),
                    onPressed: () {
                      isMuted = !isMuted;
                      cubit.muteAudio();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
