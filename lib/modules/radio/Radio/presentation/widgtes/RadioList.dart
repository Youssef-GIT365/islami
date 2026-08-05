import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/modules/radio/Radio/presentation/controller/Radio_controller.dart';
import 'package:islami/modules/radio/Radio/presentation/controller/Radio_state.dart';
import 'package:islami/modules/radio/Radio/presentation/servies/service_locator.dart';

import 'package:islami/modules/radio/Radio/presentation/widgtes/radio_widget.dart';

class RadioList extends StatelessWidget {
  const RadioList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<Radiocubit>()..getRadio(),
      child: BlocBuilder<Radiocubit, RadioState>(
        builder: (context, state) {
          if (state is RadioLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RadioSuccess) {
            return ListView.builder(
              itemCount: state.radios.length,
              itemBuilder: (context, index) {
                return RadioCard(radio: state.radios[index]);
              },
            );
          } else if (state is RadioError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}