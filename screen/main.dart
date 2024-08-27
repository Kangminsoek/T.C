import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core import
import 'package:http/http.dart' as http; // HTTP 패키지 import
import 'dart:convert'; // JSON 디코딩을 위한 패키지 import

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
        '/courses': (context) => CourseListScreen(), // 새로운 코스 화면 추가
      },
    );
  }
}

class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  List<dynamic> _courses = [];

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    final response = await http.get(Uri.parse('http://your-server-ip:5000/api/courses'));

    if (response.statusCode == 200) {
      setState(() {
        _courses = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load courses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
      ),
      body: _courses.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_courses[index]['name']),
                  subtitle: Text(_courses[index]['description']),
                );
              },
            ),
    );
  }
}
