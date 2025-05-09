import 'package:flutter/material.dart';
import 'package:overbloom/controller/welcome_controller.dart';
import 'package:overbloom/components/base_screen.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final WelcomeController _controller = WelcomeController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      fundo: "welcome_fundo.png",
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: Image.asset(
              'assets/images/cenario/name_app.png',
            ),
          ),
          const SizedBox(height: 150),
          Align(
            alignment: const Alignment(0, -0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _controller.goToLogin(context),
                  child: Image.asset(
                    'assets/images/buttons/login_button.png',
                    width: 250,
                    height: 75,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _controller.goToRegister(context),
                  child: Image.asset(
                    'assets/images/buttons/register_button.png',
                    width: 250,
                    height: 75,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}