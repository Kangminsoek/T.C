import 'package:cppick/screen/recommended_course_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AiDateCourseScreen extends StatefulWidget {
  @override
  _AiDateCourseScreenState createState() => _AiDateCourseScreenState();
}

class _AiDateCourseScreenState extends State<AiDateCourseScreen> {
  List<int> _selectedOptions = [1, 2];
  double _distanceValue = 15;
  double _budgetValue = 10;
  late List<int?> _selectedImages;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedImages = List.generate(_selectedOptions.length, (_) => null);
  }

  void _addOption() {
    if (_selectedOptions.length < 5) {
      setState(() {
        _selectedOptions.add(_selectedOptions.length + 1);
        _selectedImages.add(null);
      });
    }
  }

  void _removeOption(int index) {
    setState(() {
      _selectedOptions.removeAt(index);
      _selectedImages.removeAt(index);
    });
  }

  void _toggleImage(int optionIndex, int imageIndex) {
    setState(() {
      if (_selectedImages.contains(imageIndex)) return;
      _selectedImages[optionIndex] = imageIndex;
    });
  }

  void _showAddressInput() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black54,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '주소 입력',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '주소를 입력하세요',
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _selectedAddress = value;
                    });
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB9EF45),
                  ),
                  child: Text('확인'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToRecommendedCourseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecommendedCourseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 데이트 추천코스'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.grey.shade200,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _selectedAddress == null
                                ? Text('추천받고 싶은 지역을 선택해주세요.')
                                : Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(_selectedAddress!),
                            ),
                            ElevatedButton(
                              onPressed: _showAddressInput,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFB9EF45),
                              ),
                              child: Text('주소검색'),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: _selectedOptions
                              .asMap()
                              .entries
                              .map((entry) => _buildOptionRow(entry.key))
                              .toList(),
                        ),
                        SizedBox(height: 10),
                        if (_selectedOptions.length < 5)
                          IconButton(
                            icon: Icon(Icons.add_circle_outline, size: 40),
                            onPressed: _addOption,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildFixedSection(),
        ],
      ),
    );
  }

  Widget _buildOptionRow(int optionIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => _toggleImage(optionIndex, 0),
                    child: Column(
                      children: [
                        Image.asset(
                          _selectedImages[optionIndex] == 0
                              ? 'assets/images/heart.png'
                              : 'assets/images/eat.png',
                          height: 30,
                        ),
                        Text('먹기'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _toggleImage(optionIndex, 1),
                    child: Column(
                      children: [
                        Image.asset(
                          _selectedImages[optionIndex] == 1
                              ? 'assets/images/heart.png'
                              : 'assets/images/drink.png',
                          height: 30,
                        ),
                        Text('마시기'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _toggleImage(optionIndex, 2),
                    child: Column(
                      children: [
                        Image.asset(
                          _selectedImages[optionIndex] == 2
                              ? 'assets/images/heart.png'
                              : 'assets/images/play.png',
                          height: 30,
                        ),
                        Text('놀기'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _toggleImage(optionIndex, 3),
                    child: Column(
                      children: [
                        Image.asset(
                          _selectedImages[optionIndex] == 3
                              ? 'assets/images/heart.png'
                              : 'assets/images/see.png',
                          height: 30,
                        ),
                        Text('보기'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _toggleImage(optionIndex, 4),
                    child: Column(
                      children: [
                        Image.asset(
                          _selectedImages[optionIndex] == 4
                              ? 'assets/images/heart.png'
                              : 'assets/images/walk.png',
                          height: 30,
                        ),
                        Text('걷기'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => _removeOption(optionIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('원하시는 거리와 예산을 선택해주세요.'),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('반경(도보 기준)'),
              Text('약 ${_distanceValue.toInt()}분(${(_distanceValue * 70).toInt()}m)'),
            ],
          ),
          Slider(
            value: _distanceValue,
            min: 5,
            max: 30,
            divisions: 5,
            label: '$_distanceValue분',
            activeColor: Colors.redAccent, // 레이팅바 색상 변경
            onChanged: (value) {
              setState(() {
                _distanceValue = value;
              });
            },
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('예산(1인)'),
              Text('${_budgetValue.toInt()}만원이내'),
            ],
          ),
          Slider(
            value: _budgetValue,
            min: 1,
            max: 100,
            divisions: 10,
            label: '$_budgetValue만원',
            activeColor: Colors.redAccent, // 레이팅바 색상 변경
            onChanged: (value) {
              setState(() {
                _budgetValue = value;
              });
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _navigateToRecommendedCourseScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB9EF45),
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              '코스 추천받기',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
