import 'package:flutter/material.dart';

class AnimatedCurrencyCounter extends StatelessWidget {
  final int value;
  final String currencyIcon;

  const AnimatedCurrencyCounter({
    super.key,
    required this.value,
    required this.currencyIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      builder: (context, val, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(currencyIcon, height: 24),
            const SizedBox(width: 5),
            Text(
              val.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }
}
