import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 패키지

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _nameController;
  String _profileImageUrl = 'assets/images/profile_image.png'; // 기본 프로필 이미지 경로

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '홀란드'); // 초기 닉네임 설정
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _changeProfileImage() async {
    // 프로필 사진 변경 기능 추가
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImageUrl = image.path; // 새로운 이미지 경로 설정
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut(); // 로그아웃
    Navigator.of(context).pushReplacementNamed('/login'); // 로그인 화면으로 전환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '내 프로필',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImageUrl.contains('http')
                      ? NetworkImage(_profileImageUrl) as ImageProvider
                      : AssetImage(_profileImageUrl),
                ),
                Positioned(
                  bottom: 0,
                  right: 10,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _changeProfileImage, // 프로필 사진 변경
                    child: Icon(Icons.camera_alt, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '닉네임을 입력하세요',
              ),
            ),
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.grey[700]),
                title: Text('프로필 편집'),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[700], size: 16),
                onTap: () {
                  // 프로필 편집 화면으로 이동
                },
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.help_outline, color: Colors.grey[700]),
                title: Text('도움말 및 지원'),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[700], size: 16),
                onTap: () {
                  // 도움말 화면으로 이동
                },
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
                title: Text('알림 설정'),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[700], size: 16),
                onTap: () {
                  // 알림 설정 화면으로 이동
                },
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.settings_outlined, color: Colors.grey[700]),
                title: Text('앱 설정'),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[700], size: 16),
                onTap: () {
                  // 설정 화면으로 이동
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout, // 로그아웃 기능
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                '로그아웃',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
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
      ),
    );
  }
}
