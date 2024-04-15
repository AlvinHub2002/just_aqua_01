import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TemperaturePage extends StatefulWidget {
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  double _currentTemperature = 0.0; // Initial temperature
  double _minTemperature = 0.0;
  double _maxTemperature = 100.0;

  // Function to get the effect of current temperature
  String getTemperatureEffect(double temperature) {
    if (temperature < 10) {
      return 'Very Cold';
    } else if (temperature < 20) {
      return 'Cold';
    } else if (temperature < 30) {
      return 'Moderate';
    } else if (temperature < 40) {
      return 'Warm';
    } else {
      return 'Hot';
    }
  }

  @override
  void initState() {
    super.initState();
    _database.child('Temperature/Celsius').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _currentTemperature = double.parse(event.snapshot.value.toString());
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
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Temperature',
                style: TextStyle(
                  fontSize: 34.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 175, 175, 175),
                ),
              ),
            ),
            SizedBox(height: 100.0),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200.0,
                    height: 200.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 5.0,
                      value: _currentTemperature / _maxTemperature,
                      backgroundColor: Color.fromARGB(255, 164, 164, 164),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 34, 71, 255),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        double sensitivity = 1.0;
                        _currentTemperature -= details.delta.dy * sensitivity;
                        if (_currentTemperature < _minTemperature) {
                          _currentTemperature = _minTemperature;
                        } else if (_currentTemperature > _maxTemperature) {
                          _currentTemperature = _maxTemperature;
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
                          '${_currentTemperature.toStringAsFixed(1)}°C',
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
                getTemperatureEffect(_currentTemperature),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 100),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 100,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 104, 104, 104).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          Color.fromARGB(255, 203, 203, 203).withOpacity(0.5)),
                ),
                child: Text(
                  'Current temperature is good for the fish. ',
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
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
