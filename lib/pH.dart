import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Ph extends StatefulWidget {
  @override
  _PhPageState createState() => _PhPageState();
}

class _PhPageState extends State<Ph> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late User _user;
  late String _selectedFishType = '';
  double _currentPh = 0.0;
  double updatedph = 0.0; // Initial pH
  double _minPh = 0.0;
  double _maxPh = 14.0;
  double _phThreshold = 0.0; // pH threshold for the selected fish

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchSelectedFishType();
    _database.child('PH/Value').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _currentPh = double.parse(event.snapshot.value.toString());
          updatedph = _currentPh - 4.75;
          // print(_currentPh);
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
        _fetchPhThreshold();
      }
    } catch (error) {
      print('Error fetching selected fish type: $error');
    }
  }

  Future<void> _fetchPhThreshold() async {
    try {
      DataSnapshot snapshot =
          await _database.child('Fish/$_selectedFishType/pH').get();
      if (snapshot.value != null) {
        setState(() {
          _phThreshold = double.parse(snapshot.value.toString());
        });
      }
    } catch (error) {
      print('Error fetching pH threshold: $error');
    }
  }

  String getPhMessage() {
    if (_currentPh >= _phThreshold) {
      return 'pH is higher for $_selectedFishType. Take action to lower it!';
    } else if (_currentPh < _phThreshold - 1) {
      return 'pH is lower for $_selectedFishType. Take action to increase it!';
    } else {
      return 'pH is within the acceptable range.';
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
                'pH',
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
                    //   value: _currentPh / _maxPh, // Adjusted for pH
                    //   backgroundColor: Color.fromARGB(255, 164, 164, 164),
                    //   valueColor: AlwaysStoppedAnimation<Color>(
                    //     Color.fromARGB(255, 34, 71, 255),
                    //   ),
                    // ),
                  ),
                  GestureDetector(
                    // onPanUpdate: (details) {
                    //   setState(() {
                    //     double sensitivity = 1.0;
                    //     _currentPh -= details.delta.dy * sensitivity;
                    //     if (_currentPh < _minPh) {
                    //       _currentPh = _minPh;
                    //     } else if (_currentPh > _maxPh) {
                    //       _currentPh = _maxPh;
                    //     }
                    //   });
                    // },
                    child: Container(
                      width: 160.0,
                      height: 160.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 0, 0, 0),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 255, 255, 255)
                                .withOpacity(0.3),
                            spreadRadius: 12,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${updatedph.toStringAsFixed(1)} pH', // Adjusted for pH
                          style: TextStyle(
                            fontSize: 40,
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
                'pH Threshold',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                'Optimal for $_selectedFishType',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child:
                  Text('${_phThreshold.toStringAsFixed(1)}', // Adjusted for pH
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
                  getPhMessage(),
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
