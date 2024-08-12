import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cppick/screen/signup_screen.dart';
import 'package:cppick/screen/main_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // Kakao Flutter SDK
import 'package:flutter_naver_login/flutter_naver_login.dart'; // Naver Login SDK

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    void _showSnackBar(BuildContext context, String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }

    Future<void> _loginWithEmail() async {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          _showSnackBar(context, 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          _showSnackBar(context, 'Wrong password provided.');
        }
      }
    }

    Future<void> _loginWithGoogle() async {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }

    Future<void> _loginWithKakao() async {
      try {
        if (await isKakaoTalkInstalled()) {
          try {
            await UserApi.instance.loginWithKakaoTalk();
            _showSnackBar(context, '카카오톡으로 로그인 성공');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } catch (error) {
            _showSnackBar(context, '카카오톡으로 로그인 실패 $error');

            if (error is PlatformException && error.code == 'CANCELED') {
              return;
            }

            try {
              await UserApi.instance.loginWithKakaoAccount();
              _showSnackBar(context, '카카오계정으로 로그인 성공');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            } catch (error) {
              _showSnackBar(context, '카카오계정으로 로그인 실패 $error');
            }
          }
        } else {
          try {
            await UserApi.instance.loginWithKakaoAccount();
            _showSnackBar(context, '카카오계정으로 로그인 성공');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } catch (error) {
            _showSnackBar(context, '카카오계정으로 로그인 실패 $error');
          }
        }
      } catch (error) {
        _showSnackBar(context, '카카오 로그인 오류: $error');
      }
    }

    Future<void> _loginWithNaver() async {
      try {
        final NaverLoginResult result = await FlutterNaverLogin.logIn();

        if (result.status == NaverLoginStatus.loggedIn) {
          _showSnackBar(context, '네이버 로그인 성공');
          print('accessToken = ${result.accessToken}');
          print('id = ${result.account.id}');
          print('email = ${result.account.email}');
          print('name = ${result.account.name}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          _showSnackBar(context, '네이버 로그인 실패: ${result.errorMessage}');
        }
      } catch (error) {
        _showSnackBar(context, '네이버 로그인 오류: $error');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 230,
                      ),
                      Positioned(
                        top: -40,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          'assets/images/Ellipse 3.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 55,
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/heart.png', height: 70),
                            SizedBox(height: 7),
                            Text(
                              'Couplelypick',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: '사용자 이름 또는 이메일',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            hintText: '비밀번호',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                                );
                              },
                              child: Text(
                                '회원가입',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _loginWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB9EF45),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _loginWithGoogle,
                              child: Image.asset(
                                'assets/images/google.png',
                                height: 50,
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: _loginWithKakao,
                              child: Image.asset(
                                'assets/images/kakao.png',
                                height: 50,
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: _loginWithNaver,
                              child: Image.asset(
                                'assets/images/naver.png',
                                height: 50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: Image.asset(
              'assets/images/battom_bar.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
