import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/modules/radio/Radio/presentation/servies/service_locator.dart';
import 'package:islami/modules/radio/Reciters/presentation/controller/reciters_cubit.dart';
import 'package:islami/modules/radio/Reciters/presentation/controller/reciters_state.dart';
import 'package:islami/modules/radio/Reciters/presentation/reciter_card.dart';

class RecitersView extends StatelessWidget {
  const RecitersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<Reciterscubit>()..getreciters(),
      child: BlocBuilder<Reciterscubit, RecitersState>(
        builder: (context, state) {
          if (state is RecitersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecitersSuccess) {
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: state.Reciterss.length,
              itemBuilder: (context, index) {
                return recitersCard(reciters: state.Reciterss[index]);
              },
            );
          } else if (state is RecitersError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
