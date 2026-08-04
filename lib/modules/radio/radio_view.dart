import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/modules/radio/presentation/controller/Radio_controller.dart';
import 'package:islami/modules/radio/presentation/controller/Radio_state.dart';
import 'package:islami/modules/radio/presentation/servies/service_locator.dart';
import 'package:islami/modules/radio/presentation/widgtes/radio_widget.dart';

class RadioView extends StatelessWidget {
  const RadioView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => sl<Radiocubit>()..getRadio(),
      child: BlocBuilder<Radiocubit, RadioState>(
        builder: (context, state) {
          if (state is RadioLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RadioSuccess) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,  
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.07,
                      decoration: BoxDecoration(
                        color: AppColors.Gold,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "Radio",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),

                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.07,
                      decoration: BoxDecoration(
                        color: AppColors.Gold,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "Reciters",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.radios.length,
                    itemBuilder: (context, index) {
                      return RadioCard(radio: state.radios[index]);
                    },
                  ),
                ),
              ],
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
