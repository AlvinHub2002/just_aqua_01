import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
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
            onPressed: () {
              // Handle search button click
              // You can implement your search functionality here
            },
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
                  color: Colors.white, // Set text color to white
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Aquarist',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Set text color to white
                ),
              ),
              SizedBox(height: 25),
              // "Water Status" Card
              Container(
                width: double.infinity,
                child: Card(
                  color: Color.fromARGB(70, 66, 66, 66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                        minHeight: 150), // Set the minimum height
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
                                    color: Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Good",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 177, 177, 177),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              width:
                                  16), // Add some spacing between the texts and the image
                          Image.asset(
                            "images/water.png", // Replace with your image asset path
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Real-time Data Section
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
              // Four Cards for Real-time Sensor Data
              Row(
                children: [
                  buildSensorCard(
                    "Temperature",
                    "25°C",
                    Icons.thermostat, // Icon for Temperature
                  ),
                  SizedBox(width: 16),
                  buildSensorCard(
                    "Ammonia",
                    "0.5 ppm",
                    Icons.opacity, // Icon for Ammonia
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  buildSensorCard(
                    "Turbidity",
                    "10 NTU",
                    Icons.visibility, // Icon for Turbidity
                  ),
                  SizedBox(width: 16),
                  buildSensorCard(
                    "pH",
                    "7.0",
                    Icons.whatshot, // Icon for pH
                  ),
                ],
              ),
              // ...
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        selectedItemColor: Colors.white, // Set the color of selected item
        unselectedItemColor:
            Color.fromARGB(255, 117, 117, 117), // Set the background color

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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget buildSensorCard(
      String sensorName, String sensorValue, IconData iconData) {
    return Expanded(
      child: Card(
        color: Color.fromARGB(70, 66, 66, 66),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          constraints: BoxConstraints(
              minHeight: 150), // Set the minimum height for each card
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
                Text(
                  sensorValue,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 177, 177, 177),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
