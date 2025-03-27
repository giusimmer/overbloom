import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:overbloom/components/base_screen.dart';
import 'package:overbloom/controller/auth_controller.dart';
import 'package:overbloom/views/Home/home_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final AuthController _controller = AuthController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      fundo: "initial_fundo.png",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _controller.signOut(),
                icon: Image.asset(
                  'assets/images/arrow_back.png',
                  width: 50,
                  height: 50,
                ),
              ),
              Stack(
                children: [
                  Image.asset(
                    'assets/images/component_coracao.png',
                    width: 230,
                  ),
                ],
              ),
            ],
          ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Image.asset('assets/images/name_app.png'),
          const SizedBox(height: 35),
          _buildMessageContainer(
            text:
                "BEM-VINDO(A) AO OVERBLOOM!\nCULTIVE SEUS HÁBITOS E FLORESÇA A CADA DIA.",
            fontSize: 17,
          ),
          const SizedBox(height: 50),
          _buildMessageContainer(
            text: "É HORA DE TRANSFORMAR SUAS\nMETAS EM CONQUISTAS.",
            fontSize: 15,
          ),
          const SizedBox(height: 70),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Image.asset(
              'assets/images/comecar_button.png',
              width: 280,
              height: 95,
            ),
          ),
        ],
      ),
            ),],
      ),
    );
  }

  Widget _buildMessageContainer({required String text, required double fontSize}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFE2FBF7),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF171638),
            offset: const Offset(-10, 20),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Color(0xFF365782),
        ),
      ),
    );
  }

}
