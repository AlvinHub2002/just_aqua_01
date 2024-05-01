import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AmmoniaPage extends StatefulWidget {
  @override
  _AmmoniaPageState createState() => _AmmoniaPageState();
}

class _AmmoniaPageState extends State<AmmoniaPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late User _user;
  late String _selectedFishType = '';
  double _currentAmmonia = 0.0; // Initial ammonia level
  double _minAmmonia = 0.0;
  double _maxAmmonia = 10.0;
  double _ammoniaThreshold = 0.0; // Ammonia threshold for the selected fish

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchSelectedFishType();
    _database.child('Ammonia/Concentration').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _currentAmmonia = double.parse(event.snapshot.value.toString());
          print(_currentAmmonia);
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
        _fetchAmmoniaThreshold();
      }
    } catch (error) {
      print('Error fetching selected fish type: $error');
    }
  }

  Future<void> _fetchAmmoniaThreshold() async {
    try {
      DataSnapshot snapshot =
          await _database.child('Fish/$_selectedFishType/Ammonia').get();
      if (snapshot.value != null) {
        setState(() {
          _ammoniaThreshold = double.parse(snapshot.value.toString());
        });
      }
    } catch (error) {
      print('Error fetching ammonia threshold: $error');
    }
  }

  String getAmmoniaMessage() {
    if (_currentAmmonia >= _ammoniaThreshold) {
      return 'Ammonia level is higher for $_selectedFishType. Take action to lower it !';
    } else {
      return 'Ammonia level is within the acceptable range.';
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
                'Ammonia Level',
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
                    //   value: _currentAmmonia / _maxAmmonia,
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
                    //     _currentAmmonia -= details.delta.dy * sensitivity;
                    //     if (_currentAmmonia < _minAmmonia) {
                    //       _currentAmmonia = _minAmmonia;
                    //     } else if (_currentAmmonia > _maxAmmonia) {
                    //       _currentAmmonia = _maxAmmonia;
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
                            spreadRadius: 14,
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${_currentAmmonia.toStringAsFixed(3)} mg/L',
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
                'Maximum Ammonia Level',
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
              child: Text('${_ammoniaThreshold.toStringAsFixed(1)} mg/L',
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
                  getAmmoniaMessage(),
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
