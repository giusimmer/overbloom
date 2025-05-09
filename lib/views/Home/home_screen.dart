import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overbloom/views/Calendar/calendar_screen.dart';
import 'package:overbloom/views/Initial/initial_screen.dart';
import 'package:overbloom/views/Ranking/ranking_screen.dart';
import '../../components/bottom_buttons.dart';
import '../../service/message_badge.dart';
import '../ReceivedMessages/received_messages_screen.dart';
import 'HomeContent/home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Widget _currentContent = const HomeContent();
  String? userId = FirebaseAuth.instance.currentUser?.uid;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/fundo/principal_fundo.png',
            fit: BoxFit.cover,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => InitialScreen()),
                        );
                      },
                      icon: Image.asset(
                        'assets/images/icon/arrow_back.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Positioned(
                        left: 4,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Image.asset(
                            'assets/images/cenario/name_app.png',
                            width: 250,
                            color: Colors.white.withOpacity(0.9),
                            colorBlendMode: BlendMode.srcATop,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/cenario/name_app.png',
                        width: 250,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: _currentContent),
          ],
        ),
        BottomButtons(
          onTap1: () {
            MessageBadge.hasNewMessage.value = false;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReceivedMessagesScreen(currentUserId: userId),
              ),
            );
          },
          onTap2: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RankingScreen()),
            );
          },
          onTap3: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalendarScreen(userId: userId,)),
            );
          },
        ),
      ]),
    );
  }
}
