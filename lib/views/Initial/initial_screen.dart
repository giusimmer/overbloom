import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overbloom/components/base_screen.dart';
import 'package:overbloom/controller/auth_controller.dart';
import 'package:overbloom/views/Home/home_screen.dart';
import 'package:overbloom/views/Welcome/welcome_screen.dart';

import '../../service/notification_service.dart';

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
                onPressed: () {
                  _showExitConfirmationDialog();
                },
                icon: Image.asset(
                  'assets/images/icon/sair.png',
                  fit: BoxFit.cover,
                  width: 65,
                  height: 50,
                ),
              ),
              Stack(
                children: [
                  Image.asset(
                    'assets/images/cenario/component_coracao.png',
                    width: 230,
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/cenario/name_app.png'),
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
                    'assets/images/buttons/comecar_button.png',
                    width: 280,
                    height: 95,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContainer(
      {required String text, required double fontSize}) {
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

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFE2FBF7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/icon/sair.png',
                  width: 70,
                  height: 70,
                ),
                SizedBox(height: 20),
                Text(
                  'Deseja sair?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF365782),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tem certeza que deseja sair?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF365782),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF365782),
                          side: BorderSide(color: Color(0xFF365782)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF365782),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          if (!kIsWeb) {
                            if (Platform.isAndroid) {
                              await NotificationService.cancelListening();
                            }
                          }
                          await _controller.signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => WelcomeScreen(),
                            ),
                          );
                        },
                        child: Text('Sair'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
