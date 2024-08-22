import 'package:flutter/material.dart';

class MBTIScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MBTI별 추천'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMBTIButton(context, 'E', 'assets/images/e.png'),
            _buildMBTIButton(context, 'I', 'assets/images/i.png'),
            _buildMBTIButton(context, 'S', 'assets/images/s.png'),
            _buildMBTIButton(context, 'N', 'assets/images/n.png'),
            _buildMBTIButton(context, 'F', 'assets/images/f.png'),
            _buildMBTIButton(context, 'T', 'assets/images/t.png'),
            _buildMBTIButton(context, 'P', 'assets/images/p.png'),
            _buildMBTIButton(context, 'J', 'assets/images/j.png'),
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

  Widget _buildMBTIButton(BuildContext context, String letter, String imagePath) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFD7F8B0),
        shape: CircleBorder(),
        padding: EdgeInsets.all(24),
      ),
      onPressed: () {
        // Handle button press here
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
