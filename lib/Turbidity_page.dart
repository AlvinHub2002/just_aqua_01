import 'package:flutter/material.dart';

class TurbidityPage extends StatefulWidget {
  @override
  _TurbidityPageState createState() => _TurbidityPageState();
}

class _TurbidityPageState extends State<TurbidityPage> {
  double _currentTurbidity = 0.0; // Initial turbidity
  double _maxTurbidity = 100.0;

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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200.0,
                    height: 200.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 5.0,
                      value: _currentTurbidity / _maxTurbidity,
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
                        _currentTurbidity -= details.delta.dy * sensitivity;
                        if (_currentTurbidity < 0) {
                          _currentTurbidity = 0;
                        } else if (_currentTurbidity > _maxTurbidity) {
                          _currentTurbidity = _maxTurbidity;
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
                          '${_currentTurbidity.toStringAsFixed(1)}',
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
                getTurbidityEffect(_currentTurbidity),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: Text(
                'Maximum Turbidity',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: Text('$_maxTurbidity',
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
                  'Current turbidity is good for the fish. ',
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

  // Function to get the effect of current turbidity
  String getTurbidityEffect(double turbidity) {
    if (turbidity < 10) {
      return 'Very Clear';
    } else if (turbidity < 20) {
      return 'Clear';
    } else if (turbidity < 30) {
      return 'Slightly Cloudy';
    } else if (turbidity < 40) {
      return 'Moderately Cloudy';
    } else {
      return 'Very Cloudy';
    }
  }
}
