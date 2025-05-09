import 'package:flutter/material.dart';

class SplashController {
  late AnimationController controller;
  late Animation<double> moveRight;
  late Animation<double> jump;

  void init(TickerProvider vsync, VoidCallback onFinish) {
    controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 3),
    );

    moveRight = Tween<double>(begin: -140, end: 300).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear),
    );

    jump = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -50), weight: 10),
      TweenSequenceItem(tween: Tween<double>(begin: -50, end: -50), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: -80, end: 0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    controller.forward();

    Future.delayed(const Duration(seconds: 3), onFinish);
  }

  void dispose() {
    controller.dispose();
  }
}
