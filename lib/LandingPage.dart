import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notificationPage.dart';
import 'temperature_page.dart';
import 'profilePage.dart';
import 'bottom_navigation_bar.dart';

bool _fishTypeSelected = false;

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
  String _selectedFishType = '';
  double _temperatureThreshold = 0.0;
  bool _temperatureExceeded = true;
  bool _initialLoad = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _checkFishTypeSelection();
    _initializeLocalNotifications();
    _requestNotificationPermissions();
    _configureFirebaseMessaging();
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestNotificationPermissions() async {
    final PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permissions granted');
    } else {
      print('Notification permissions denied');
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Background message received: ${message.data}');
    // Handle background message here...
  }

  void _configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.data}');
      if (message.notification != null) {
        _showTemperatureNotification(message.notification!.title ?? '',
            message.notification!.body ?? '');
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
          _fishTypeSelected = true;
        });
        _selectedFishType = snapshot.value.toString();
        print(_selectedFishType);
        _fetchTemperatureThreshold();
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
          if (_initialLoad) {
            _initialLoad = false;
            _temperatureExceeded = false;
          } else {
            _checkTemperatureExceeded(double.parse(temperatureValue));
          }
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
  }

  Future<void> _fetchTemperatureThreshold() async {
    try {
      DataSnapshot snapshot =
          await _database.child('Fish/$_selectedFishType/Temperature').get();
      if (snapshot.value != null) {
        setState(() {
          _temperatureThreshold = double.parse(snapshot.value.toString());
          print(_temperatureThreshold);
        });
      }
    } catch (error) {
      print('Error fetching temperature threshold: $error');
    }
  }

  void _showTemperatureAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.yellow),
            SizedBox(width: 10),
            Text(
              'Temperature exceeded threshold!',
              style: TextStyle(color: Colors.yellow),
            ),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _checkTemperatureExceeded(double currentTemperature) {
    bool previouslyExceeded = _temperatureExceeded;

    setState(() {
      _temperatureExceeded = currentTemperature > _temperatureThreshold;
    });

    if (_temperatureExceeded && !previouslyExceeded) {
      _showTemperatureAlert();
      _showTemperatureNotification(
        'Temperature Alert!',
        'Temperature has exceeded ',
      );
    } else if (!_temperatureExceeded && previouslyExceeded) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  Future<void> _showTemperatureNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Temperature Alert',
      'Notifications for temperature alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      '$body  $_temperatureThreshold °C',
      platformChannelSpecifics,
    );

    // Store the notification in Firebase Realtime Database under the user's ID
    try {
      final databaseReference = FirebaseDatabase.instance.ref();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await databaseReference
            .child('users')
            .child(user.uid)
            .child('notifications')
            .push()
            .set({
          'title': title,
          'body': '$body  $_temperatureThreshold °C',
          'timestamp': ServerValue.timestamp,
        });
        print('Notification stored successfully');
      } else {
        print('Error: Current user is null');
      }
    } catch (error) {
      print('Error storing notification: $error');
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
          if (!_fishTypeSelected)
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
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
            SizedBox(height: 20),
            Center(
              child: Text(_selectedFishType,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 215, 215, 215),
                  )),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showTemperatureNotification(
                        'Temperature Alert',
                        'Temperature has exceeded ',
                      );
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
                      "°C",
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: buildSensorCard(
                    "Ammonia",
                    ammoniaValue,
                    Icons.opacity,
                    "mg/L",
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
                    "NTU",
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: buildSensorCard(
                    "pH",
                    pHValue,
                    Icons.whatshot,
                    "",
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
    Color cardColor = Color.fromARGB(70, 66, 66, 66);
    if (sensorName == 'Temperature' &&
        double.tryParse(sensorValue) != null &&
        _selectedFishType.isNotEmpty) {
      double currentTemperature = double.parse(sensorValue);
      if (currentTemperature > _temperatureThreshold) {
        cardColor = Colors.red;
      }
    }

    return Card(
      color: cardColor,
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

void main() {
  runApp(MaterialApp(
    home: LandingPage(),
  ));
}
