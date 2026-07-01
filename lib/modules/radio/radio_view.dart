import 'package:flutter/material.dart';
import 'package:islami/core/gen/assets.gen.dart';

class RadioView extends StatelessWidget {
  const RadioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.radioBackground.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Assets.images.firstScreenLogo.image(height: 171, width: 291),
          ],
        ),
      ),
    );
  }
}
