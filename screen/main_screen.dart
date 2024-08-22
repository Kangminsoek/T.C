import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cppick/screen/splash_screen.dart';
import 'package:cppick/screen/login_screen.dart';
import 'package:cppick/screen/main_screen.dart';
import 'package:cppick/screen/user_profile_screen.dart';
import 'package:cppick/screen/ai_date_course_screen.dart';
import 'package:cppick/screen/category_screen.dart';
import 'package:cppick/screen/mbti_screen.dart'; // MBTI 화면 임포트
import 'package:cppick/screen/event_screen.dart'; // 행사 정보 화면 임포트
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // Kakao Flutter SDK 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  KakaoSdk.init(
    nativeAppKey: '0d90b4bbc01e9f6e7cff02480b530dc1', // 이 부분을 수정하세요
    javaScriptAppKey: '5e52a7ca89401d250c83806290f49717', // 이 부분을 수정하세요
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/mbti': (context) => MBTIScreen(), // MBTI 화면 라우트 추가
        '/event': (context) => EventScreen(), // 행사 정보 화면 라우트 추가
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer.periodic(Duration(seconds: 3), (Timer timer) {
        if (_currentPage < 2) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeIn,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFeatureButtonPressed(String feature) {
    if (feature == 'AI 데이터 코스 추천') {
      Navigator.pushNamed(context, '/aiDateCourse'); // AI 데이터 코스 추천 화면으로 이동
    } else if (feature == '카테고리 별 코스 추천') {
      Navigator.pushNamed(context, '/category'); // 카테고리별 코스 추천 화면으로 이동
    } else if (feature == 'MBTI 별 코스 추천') {
      Navigator.pushNamed(context, '/mbti'); // MBTI별 코스 추천 화면으로 이동
    } else if (feature == '행사 정보') {
      Navigator.pushNamed(context, '/event'); // 행사 정보 화면으로 이동
    } else {
      print('$feature 버튼이 눌렸습니다.');
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('앱 종료'),
        content: Text('앱을 종료하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('예'),
          ),
        ],
      ),
    )) ?? false;
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, '/userProfile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Couplelypick'), // 상단에 텍스트 추가
          actions: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        endDrawer: Drawer(
          child: Column(
            children: <Widget>[
              Container(
                color: Color(0xFFB9EF45),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    '메뉴',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFD7F8B0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '환경설정',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 10),
              ListTile(
                title: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFD7F8B0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '코스 내역',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Spacer(),
              ListTile(
                leading: Icon(Icons.arrow_back),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(14.0),
          children: [
            Container(
              padding: EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Color(0xFFB9EF45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset('assets/images/a.png', height: 50),
                  Image.asset('assets/images/b.png', height: 50),
                  Image.asset('assets/images/c.png', height: 50),
                  Image.asset('assets/images/d.png', height: 50),
                ],
              ),
            ),
            SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '단 하나의 픽 커플리픽',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFB9EF45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildFeatureButton('AI 데이터 코스 추천', 'assets/images/ai.png'),
                  _buildFeatureButton('카테고리 별 코스 추천', 'assets/images/category.png'),
                  _buildFeatureButton('MBTI 별 코스 추천', 'assets/images/mbti.png'),
                  _buildFeatureButton('행사 정보', 'assets/images/event.png'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 150,
              child: PageView(
                controller: _pageController,
                children: [
                  _buildFestivalCard('assets/images/eve.png'),
                  _buildFestivalCard('assets/images/eve.png'),
                  _buildFestivalCard('assets/images/eve.png'),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, color: Colors.redAccent),
              label: 'Pick',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'MY',
            ),
          ],
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildFeatureButton(String title, String assetPath) {
    return GestureDetector(
      onTap: () => _onFeatureButtonPressed(title),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(assetPath, height: 80),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFestivalCard(String assetPath) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(assetPath, fit: BoxFit.cover),
      ),
    );
  }
}
