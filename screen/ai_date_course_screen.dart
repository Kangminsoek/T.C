import 'package:cppick/screen/recommended_course_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  LatLng _selectedLatLng = LatLng(37.5665, 126.9780); // 서울 시청 기준 초기값 설정

  @override
  void initState() {
    super.initState();
    _selectedImages = List.generate(_selectedOptions.length, (_) => null);
  }

  // 옵션 추가 메서드 정의
  void _addOption() {
    if (_selectedOptions.length < 5) {
      setState(() {
        _selectedOptions.add(_selectedOptions.length + 1);
        _selectedImages.add(null);
      });
    }
  }

  // 이미지 토글 메서드 정의
  void _toggleImage(int optionIndex, int imageIndex) {
    setState(() {
      if (_selectedImages[optionIndex] == imageIndex) {
        _selectedImages[optionIndex] = null;
      } else {
        _selectedImages[optionIndex] = imageIndex;
      }
    });
  }

  // 옵션 제거 메서드 정의
  void _removeOption(int index) {
    setState(() {
      _selectedOptions.removeAt(index);
      _selectedImages.removeAt(index);
    });
  }

  // 전체 화면 지도 표시 메서드 정의
  void _showAddressInput() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('위치 선택'),
            backgroundColor: Colors.black54,
          ),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLatLng,
              zoom: 12.0,
            ),
            onTap: (LatLng latLng) {
              setState(() {
                _selectedLatLng = latLng;
              });
            },
            markers: {
              Marker(
                markerId: MarkerId('selected-location'),
                position: _selectedLatLng,
                draggable: true,
                onDragEnd: (LatLng latLng) {
                  setState(() {
                    _selectedLatLng = latLng;
                  });
                },
              ),
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _selectedAddress =
                    '위도: ${_selectedLatLng.latitude}, 경도: ${_selectedLatLng.longitude}';
              });
              Navigator.pop(context);
            },
            label: Text('위치 선택'),
            icon: Icon(Icons.check),
            backgroundColor: Color(0xFFB9EF45),
          ),
        ),
      ),
    );
  }

  void _navigateToRecommendedCourseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendedCourseScreen(
          selectedAddress: _selectedAddress,
          selectedOptions: _selectedOptions,
          selectedImages: _selectedImages,
          distanceValue: _distanceValue,
          budgetValue: _budgetValue,
        ),
      ),
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
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
    const options = ['먹기', '마시기', '놀기', '보기', '걷기'];
    const imagePaths = [
      'assets/images/eat.png',
      'assets/images/drink.png',
      'assets/images/play.png',
      'assets/images/see.png',
      'assets/images/walk.png',
    ];

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
                children: List.generate(options.length, (index) {
                  return GestureDetector(
                    onTap: () => _toggleImage(optionIndex, index),
                    child: Column(
                      children: [
                        Image.asset(
                          _selectedImages[optionIndex] == index
                              ? 'assets/images/heart.png'
                              : imagePaths[index],
                          height: 30,
                        ),
                        Text(options[index]),
                      ],
                    ),
                  );
                }),
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
          _buildSliderRow(
            '반경(도보 기준)',
            '약 ${_distanceValue.toInt()}분(${(_distanceValue * 70).toInt()}m)',
            _distanceValue,
            (value) => setState(() => _distanceValue = value),
          ),
          SizedBox(height: 10),
          _buildSliderRow(
            '예산(1인)',
            '${_budgetValue.toInt()}만원이내',
            _budgetValue,
            (value) => setState(() => _budgetValue = value),
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

  Widget _buildSliderRow(
      String label, String valueText, double value, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(valueText),
          ],
        ),
        Slider(
          value: value,
          min: label == '반경(도보 기준)' ? 5 : 1,
          max: label == '반경(도보 기준)' ? 30 : 100,
          divisions: label == '반경(도보 기준)' ? 5 : 10,
          label: '$value',
          activeColor: Colors.redAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
