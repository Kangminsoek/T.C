import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isNameUnique = false; // 중복 체크 결과 저장 변수

  Future<void> _signUp() async {
    if (!_isNameUnique) {
      _showSnackBar('닉네임 중복 확인을 해주세요.');
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await userCredential.user?.updateDisplayName(_nameController.text);

      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showSnackBar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showSnackBar('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        _showSnackBar('The email address is not valid.');
      } else {
        _showSnackBar(e.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  Future<void> _checkNameUnique() async {
    // 닉네임 중복 체크 로직 구현 (예: Firestore 등에서 닉네임을 조회)
    String name = _nameController.text;

    if (name.isEmpty) {
      _showSnackBar('닉네임을 입력해주세요.');
      return;
    }

    // 임시로 모든 닉네임이 사용 가능하다고 가정하는 로직
    setState(() {
      _isNameUnique = true;
    });

    _showSnackBar('사용 가능한 닉네임입니다.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        top: 100,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '회원가입',
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 10),
                            Image.asset(
                              'assets/images/heart.png',
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 50,
                        right: 20,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
                            prefixIcon: Icon(Icons.email_outlined),
                            hintText: '이메일을 입력해주세요',
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
                            hintText: '비밀번호를 입력해주세요',
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
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline),
                                  hintText: '닉네임을 입력해주세요',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _checkNameUnique,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                backgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                '중복 확인',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB9EF45),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
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
