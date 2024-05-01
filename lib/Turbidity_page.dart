import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TurbidityPage extends StatefulWidget {
  @override
  _TurbidityPageState createState() => _TurbidityPageState();
}

class _TurbidityPageState extends State<TurbidityPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late User _user;
  late String _selectedFishType = '';
  double _currentTurbidity = 0.0; // Initial turbidity level
  double _minTurbidity = 0.0;
  double _maxTurbidity = 100.0;
  double _turbidityThreshold = 0.0; // Turbidity threshold for the selected fish

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchSelectedFishType();
    _database.child('Turbidity').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _currentTurbidity =
              double.parse(event.snapshot.value.toString()) / 34;
        });
      }
    });
  }

  Future<void> _fetchSelectedFishType() async {
    try {
      DataSnapshot snapshot =
          await _database.child('users/${_user.uid}/selectedFishType').get();
      if (snapshot.value != null) {
        setState(() {
          _selectedFishType = snapshot.value.toString();
        });
        _fetchTurbidityThreshold();
      }
    } catch (error) {
      print('Error fetching selected fish type: $error');
    }
  }

  Future<void> _fetchTurbidityThreshold() async {
    try {
      DataSnapshot snapshot =
          await _database.child('Fish/$_selectedFishType/Turbidity').get();
      if (snapshot.value != null) {
        setState(() {
          _turbidityThreshold = double.parse(snapshot.value.toString());
        });
      }
    } catch (error) {
      print('Error fetching turbidity threshold: $error');
    }
  }

  String getTurbidityMessage() {
    if (_currentTurbidity >= _turbidityThreshold) {
      return 'Turbidity level is higher for $_selectedFishType. Take action to lower it !';
    } else {
      return 'Turbidity level is within the acceptable range.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Turbidity',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 175, 175, 175),
                ),
              ),
            ),
            SizedBox(height: 30.0),
            Center(
              child: Text(_selectedFishType,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 215, 215, 215),
                  )),
            ),
            SizedBox(height: 50.0),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200.0,
                    height: 200.0,
                    // child: CircularProgressIndicator(
                    //   strokeWidth: 5.0,
                    //   value: _currentTurbidity / _maxTurbidity,
                    //   backgroundColor: Color.fromARGB(255, 164, 164, 164),
                    //   // valueColor: AlwaysStoppedAnimation<Color>(
                    //   //   Color.fromARGB(255, 34, 71, 255),
                    //   // ),
                    // ),
                  ),
                  GestureDetector(
                    // onPanUpdate: (details) {
                    //   setState(() {
                    //     double sensitivity = 1.0;
                    //     _currentTurbidity -= details.delta.dy * sensitivity;
                    //     if (_currentTurbidity < _minTurbidity) {
                    //       _currentTurbidity = _minTurbidity;
                    //     } else if (_currentTurbidity > _maxTurbidity) {
                    //       _currentTurbidity = _maxTurbidity;
                    //     }
                    //   });
                    // },
                    child: Container(
                      width: 180.0,
                      height: 180.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 0, 0, 0),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 255, 255, 255)
                                .withOpacity(0.3),
                            spreadRadius: 16,
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${_currentTurbidity.toStringAsFixed(1)} NTU',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: Text(
                'Maximum Turbidity Level',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                'Good for $_selectedFishType',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: Text('${_turbidityThreshold.toStringAsFixed(1)} NTU',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 215, 215, 215),
                  )),
            ),
            SizedBox(height: 50),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 100,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 24, 24, 24).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          Color.fromARGB(255, 203, 203, 203).withOpacity(0.5)),
                ),
                child: Text(
                  getTurbidityMessage(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
