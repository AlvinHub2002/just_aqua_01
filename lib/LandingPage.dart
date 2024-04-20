import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'temperature_page.dart';
import 'profilePage.dart';
import 'bottom_navigation_bar.dart'; // Import the bottom navigation bar
import 'temperature_page.dart'; // Import your temperature page file
import 'pH.dart';

bool _fishTypeSelected = false; // Add this variable

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  int _currentIndex = 0;
  late User _user;

  String temperatureValue = '';
  String ammoniaValue = '';
  String turbidityValue = '';
  String pHValue = '';
  String _selectedFishType = ''; // Store the selected fish type

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _checkFishTypeSelection();
  }

  void _checkFishTypeSelection() {
    _database
        .child('users/${_user.uid}/selectedFishType')
        .get()
        .then((snapshot) {
      if (snapshot.value == null) {
        _showFishTypeDialog();
        _fishTypeSelected = false;
      } else {
        setState(() {
          _fishTypeSelected = true; // Fish type is selected
        });
        _fetchRealtimeData();
      }
    });
  }

  void _showFishTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Fish Type'),
          content: Text('Please select the type of fish you are keeping:'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
              child: Text('Select'),
            ),
          ],
        );
      },
    );
  }

  void _fetchRealtimeData() {
    _database.child('Temperature/Celsius').onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          temperatureValue = snapshot.value.toString();
        });
      }
    });
    _database.child('Ammonia').onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          ammoniaValue = snapshot.value.toString();
        });
      }
    });
    _database.child('Turbidity').onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          turbidityValue = snapshot.value.toString();
        });
      }
    });
    _database.child('pH').onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          pHValue = snapshot.value.toString();
        });
      }
    });
    _fetchSelectedFishType(); // Fetch the selected fish type
  }

  // Function to fetch the selected fish type from the database
  Future<void> _fetchSelectedFishType() async {
    try {
      DataSnapshot snapshot =
          await _database.child('users/${_user.uid}/selectedFishType').get();
      if (snapshot.value != null) {
        setState(() {
          _selectedFishType = snapshot.value.toString();
          print(_selectedFishType);
        });
      }
    } catch (error) {
      print('Error fetching selected fish type: $error');
    }
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
          if (!_fishTypeSelected) // Conditionally render the warning icon
            IconButton(
              icon: Icon(Icons.warning),
              onPressed: () {
                _showFishTypeDialog();
              },
            ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: PageView(
        children: [
          buildHomeContent(),
          buildProfileContent(),
        ],
        controller: PageController(
          initialPage: _currentIndex,
          keepPage: true,
        ),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) {
            // Profile button index
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          }
        },
      ),
    );
  }

  Widget buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello',
              style: TextStyle(
                fontSize: 24,
                color: const Color.fromARGB(255, 158, 158, 158),
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
            // Display the selected fish type here
            SizedBox(height: 20),
            Center(
              child: Text(_selectedFishType,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 215, 215, 215),
                  )),
            ),
            SizedBox(height: 20),
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
                color: Color.fromARGB(255, 162, 162, 162),
              ),
            ),
            SizedBox(height: 20.0),
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
                      "°C", // Celsius
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: buildSensorCard(
                    "Ammonia",
                    ammoniaValue,
                    Icons.opacity,
                    "mg/L", // milligrams per liter
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
                    "NTU", // Nephelometric Turbidity Units
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: buildSensorCard(
                    "pH",
                    pHValue,
                    Icons.whatshot,
                    "", // pH is dimensionless, no unit needed
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSensorCard(
      String sensorName, String sensorValue, IconData iconData, String unit) {
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
                    unit,
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

  Widget buildProfileContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProfilePage(),
      ),
    );
  }
}
