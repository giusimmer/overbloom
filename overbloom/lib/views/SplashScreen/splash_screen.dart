import 'package:flutter/material.dart';
import 'package:overbloom/components/base_screen.dart';
import 'package:overbloom/controller/splash_controller.dart';
import '../Welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final SplashController _splashController = SplashController();

  @override
  void initState() {
    super.initState();
    _splashController.init(this, () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      fundo: "base_fundo.png",
      child: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _splashController.controller,
              child: Image.asset(
                'assets/images/name_app.png',
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _splashController.controller,
            builder: (context, child) {
              double screenWidth = MediaQuery.of(context).size.width;
              double screenHeight = MediaQuery.of(context).size.height;

              double leftPosition = screenWidth * 0.25 + _splashController.moveRight.value;

              double topPosition = screenHeight * 0.75 + _splashController.jump.value;

              return Positioned(
                left: leftPosition,
                top: topPosition,
                child: Image.asset(
                  'assets/images/coelho.png',
                  width: 150,
                  height: 150,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}