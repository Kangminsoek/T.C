import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카테고리별 추천코스'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCategoryButton(context, '오늘은 야외로~!', 'assets/images/outdoor.png'),
            _buildCategoryButton(context, '오늘은 실내로~!', 'assets/images/indoor.png'),
            _buildCategoryButton(context, '교양 데이트', 'assets/images/culture.png'),
            _buildCategoryButton(context, '맛집 탐방 어때?', 'assets/images/food.png'),
            _buildCategoryButton(context, '쇼핑/시장', 'assets/images/shopping.png'),
            _buildCategoryButton(context, '6월 축제/이벤트', 'assets/images/festival.png'),
            _buildCategoryButton(context, '너의 취미가 뭐니?', 'assets/images/hobby.png'),
            _buildCategoryButton(context, '힐링 데이트 어때?', 'assets/images/healing.png'),
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
        onTap: (index) {
          if (index == 1) {
            Navigator.popUntil(context, ModalRoute.withName('/main_screen'));
          }
        },
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String text, String imagePath) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFD7F8B0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        // Handle button press here
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 80, fit: BoxFit.contain),
          SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
