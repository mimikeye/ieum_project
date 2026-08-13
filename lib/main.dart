import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ieum_project/calender_main.dart';
import 'package:ieum_project/pray_time.dart';

import 'firebase_options.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const IeumApp());
}

class IeumApp extends StatelessWidget {
  const IeumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: '이음',

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: false,
        fontFamily: 'Pretendard',
      ),

      home: const PrayerTimerPage(
        uid: 'test_uid',
      ),
    );
  }
}