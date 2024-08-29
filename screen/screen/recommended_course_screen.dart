import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendedCourseScreen extends StatefulWidget {
  final String? selectedAddress;
  final List<int> selectedOptions;
  final List<int?> selectedImages;
  final double distanceValue;
  final double budgetValue;

  RecommendedCourseScreen({
    required this.selectedAddress,
    required this.selectedOptions,
    required this.selectedImages,
    required this.distanceValue,
    required this.budgetValue,
  });

  @override
  _RecommendedCourseScreenState createState() => _RecommendedCourseScreenState();
}

class _RecommendedCourseScreenState extends State<RecommendedCourseScreen> {
  final LatLng _initialPosition = LatLng(37.206821, 127.033268);
  List<Map<String, dynamic>> _nearbyPlaces = [];
  bool _isLoading = false;
  String? _responseMessage;

  @override
  void initState() {
    super.initState();
    _fetchNearbyPlaces();
    _submitCourseData();  // Submit data to the server on screen load
  }

  Future<void> _fetchNearbyPlaces() async {
    final apiKey = 'AIzaSyDzaQ9ENGoB3rL2rqbBNybRx17Dv6x4mzo'; // Replace with your actual API key
    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_initialPosition.latitude},${_initialPosition.longitude}'
        '&radius=1500&type=restaurant&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final places = data['results'] as List;

        setState(() {
          _nearbyPlaces = places.map((place) {
            return {
              'name': place['name'],
              'address': place['vicinity'],
            };
          }).toList();
        });
      } else {
        print('Failed to fetch nearby places');
      }
    } catch (e) {
      print('Error fetching nearby places: $e');
    }
  }

  Future<void> _submitCourseData() async {
    final String apiUrl = "http://your-server-ip:3000/api/course";  // Node.js server address

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "selectedAddress": widget.selectedAddress,
          "selectedOptions": widget.selectedOptions,
          "selectedImages": widget.selectedImages,
          "distanceValue": widget.distanceValue,
          "budgetValue": widget.budgetValue,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _responseMessage = json.decode(response.body)['message'];
        });
      } else {
        setState(() {
          _responseMessage = 'Failed to submit course data';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 데이트 추천코스'),
        backgroundColor: Color(0xFFB9EF45),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              '코스 편집',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMapSection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(),
                        SizedBox(height: 20),
                        Text(
                          '주변 추천 장소',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF070707),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildPlaceList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_responseMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _responseMessage!,
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFFB9EF45),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
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

  Widget _buildMapSection() {
    return Container(
      height: 250,
      child: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              markers: _createMarkers(),
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return {
      Marker(
        markerId: MarkerId('start'),
        position: _initialPosition,
        infoWindow: InfoWindow(title: '출발 지점'),
      ),
      Marker(
        markerId: MarkerId('end'),
        position: LatLng(37.206821, 127.033268),
        infoWindow: InfoWindow(title: '도착 지점'),
      ),
    };
  }

  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Color(0xFFE6FFE1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildInfoRow('주소', widget.selectedAddress ?? '알 수 없음'),
          _buildInfoRow('예상 거리', '${widget.distanceValue.toInt()}분 (${(widget.distanceValue * 70).toInt()}m)'),
          _buildInfoRow('예산', '${widget.budgetValue.toInt()}만원 이내'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF000000))),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildPlaceList() {
    if (_nearbyPlaces.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: _nearbyPlaces.map((place) {
        return _buildPlaceCard(place['name'], place['address']);
      }).toList(),
    );
  }
  Widget _buildPlaceCard(String title, String description) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.place, color: Color(0xFFB9EF45), size: 40),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 5),
                Text(description, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
