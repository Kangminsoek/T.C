import 'package:flutter/material.dart';
import
class RecommendedCourseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 데이트 추천코스'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              '코스편집',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 250,
                    color: Colors.grey.shade200,
                    child: Stack(
                      children: [
                        // 여기서 지도를 추가합니다
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/map.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // 경로 표시
                        Positioned(
                          top: 50,
                          left: 50,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_pin, color: Colors.red),
                                  SizedBox(width: 10),
                                  Text('1분', style: TextStyle(color: Colors.green)),
                                  SizedBox(width: 10),
                                  Icon(Icons.location_pin, color: Colors.red),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoCard('1인 예산 비용', '약 2만원대'),
                            _buildInfoCard('장소 소요 시간', '1시간 30분'),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text('주변 추천장소', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        _buildPlaceList(),
                      ],
                    ),
                  ),
                ],
              ),
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
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 5),
          Text(content, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlaceList() {
    return Column(
      children: [
        _buildPlaceCard('딜리버리맨(연극)', '상상 그 이상의 극한 배달이 시작됐다! 당신이 원하는 것은 무엇이든 배달해주는, 발칙 배달 강탈 코미디'),
        _buildPlaceCard('해화랑', '전통 항아리 와인의 이색적인 조화! 현지 최고의 소믈리에와 와인 리스트가 있는 고품격 레스토랑'),
        _buildPlaceCard('도시락테마카페', '여러분의 점심을 100% 내 손으로 만들어 갈 수 있는 테마 카페입니다.'),
      ],
    );
  }

  Widget _buildPlaceCard(String title, String description) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/place_holder.png', height: 50),  // 이미지 추가
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(description, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
