import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/modules/radio/domain/entities/entitie.dart';
import 'package:islami/modules/radio/presentation/controller/Radio_controller.dart';
import 'package:islami/modules/radio/presentation/controller/Radio_state.dart';

class RadioCard extends StatelessWidget {
  final RadioEntity radio;

  const RadioCard({super.key, required this.radio});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Radiocubit, RadioState>(
      builder: (context, state) {
        final cubit = context.read<Radiocubit>();
        final isPlaying =
            cubit.currentlyPlayingUrl == radio.url && cubit.isPlaying;
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
            children: [
              Text(
                radio.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.Black,
                ),
              ),
              IconButton(
                iconSize: 36,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  cubit.playOrPause(radio.url);
                },
              ),
              IconButton(
                iconSize: 36,
                icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                onPressed: () {
                  isMuted = !isMuted;
                  cubit.muteAudio(isMuted);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
