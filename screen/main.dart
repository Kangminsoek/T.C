import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core import
import 'package:cppick/screen/splash_screen.dart';
import 'package:cppick/screen/login_screen.dart';
import 'package:cppick/screen/main_screen.dart';
import 'package:cppick/screen/user_profile_screen.dart';
import 'package:cppick/screen/ai_date_course_screen.dart';
import 'package:cppick/screen/category_screen.dart';
import 'package:cppick/screen/mbti_screen.dart'; // MBTI 화면 임포트
import 'package:cppick/screen/event_screen.dart'; // 행사 정보 화면 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couplelypick',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(),
        '/userProfile': (context) => UserProfileScreen(),
        '/aiDateCourse': (context) => AiDateCourseScreen(),
        '/category': (context) => CategoryScreen(),
        '/mbti': (context) => MBTIScreen(),
        '/event': (context) => EventScreen(),
      },
    );
  }
}