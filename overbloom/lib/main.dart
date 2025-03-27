import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:overbloom/Service/presence_service.dart';
import 'package:overbloom/views/Home/home_screen.dart';
import 'package:overbloom/views/Initial/initial_screen.dart';
import 'package:overbloom/views/SplashScreen/splash_screen.dart';

import 'firebase_options.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OverBloom',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final String userId = snapshot.data!.uid;
            PresenceService(userId).setOnline();
            return HomeScreen();
          } else {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}
