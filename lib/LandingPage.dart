import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'temperature_page.dart'; // Import your temperature page file

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  int _currentIndex = 0;
  String temperatureValue = ''; // Variable to hold the temperature value
  String ammoniaValue = ''; // Variable to hold the ammonia value
  String turbidityValue = ''; // Variable to hold the turbidity value
  String pHValue = ''; // Variable to hold the pH value

  @override
  void initState() {
    super.initState();
    _database.child('Temperature/Celsius').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          temperatureValue = event.snapshot.value.toString();
        });
      }
    });
    _database.child('Ammonia').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          ammoniaValue = event.snapshot.value.toString();
        });
      }
    });
    _database.child('Turbidity').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          turbidityValue = event.snapshot.value.toString();
        });
      }
    });
    _database.child('pH').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          pHValue = event.snapshot.value.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Row(
          children: [
            Text(
              '',
              style: TextStyle(
                fontFamily: 'Helvetica',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Aquarist',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 25),
              Container(
                width: double.infinity,
                child: Card(
                  color: Color.fromARGB(70, 66, 66, 66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 150),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Water Status",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Good",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 177, 177, 177),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Image.asset(
                            "images/water.png",
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Realtime Data',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TemperaturePage()),
                        );
                      },
                      child: buildSensorCard(
                        "Temperature",
                        temperatureValue,
                        Icons.thermostat,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: buildSensorCard(
                      "Ammonia",
                      ammoniaValue,
                      Icons.opacity,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: buildSensorCard(
                      "Turbidity",
                      turbidityValue,
                      Icons.visibility,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: buildSensorCard(
                      "pH",
                      pHValue,
                      Icons.whatshot,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        selectedItemColor: Colors.white,
        unselectedItemColor: Color.fromARGB(255, 117, 117, 117),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        onTap: (index) {},
      ),
    );
  }

  Widget buildSensorCard(
      String sensorName, String sensorValue, IconData iconData) {
    return Card(
      color: Color.fromARGB(70, 66, 66, 66),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: 150),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  iconData,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sensorName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    sensorValue,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 177, 177, 177),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '℃', // Degree Celsius symbol
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 177, 177, 177),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
