import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';

class pH extends StatefulWidget {
  @override
  _pHState createState() => _pHState();
}

class _pHState extends State<pH> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  double _currentpH = 7.0; // Initial pH
  double _minpH = 0.0;
  double _maxpH = 14.0;

  // Function to get the effect of current pH
  String getpHEffect(double pH) {
    if (pH < 4) {
      return 'Very Acidic';
    } else if (pH < 6) {
      return 'Acidic';
    } else if (pH < 8) {
      return 'Neutral';
    } else if (pH < 10) {
      return 'Alkaline';
    } else {
      return 'Very Alkaline';
    }
  }

  @override
  void initState() {
    super.initState();
    _database.child('pH').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _currentpH = double.parse(event.snapshot.value.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('pH Level'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'pH Level',
              style: TextStyle(
                fontSize: 34.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 175, 175, 175),
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200.0,
                    height: 200.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 5.0,
                      value: (_currentpH - _minpH) / (_maxpH - _minpH),
                      backgroundColor: Color.fromARGB(255, 164, 164, 164),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 34, 71, 255),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        double sensitivity = 0.1;
                        _currentpH -= details.delta.dy * sensitivity;
                        if (_currentpH < _minpH) {
                          _currentpH = _minpH;
                        } else if (_currentpH > _maxpH) {
                          _currentpH = _maxpH;
                        }
                      });
                    },
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
                          '${_currentpH.toStringAsFixed(1)}',
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
            SizedBox(height: 20),
            Center(
              child: Text(
                getpHEffect(_currentpH),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 104, 104, 104).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          Color.fromARGB(255, 203, 203, 203).withOpacity(0.5)),
                ),
                child: Text(
                  'Current pH level is good for the aquarium.',
                  textAlign: TextAlign.center,
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
