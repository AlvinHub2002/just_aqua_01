import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_aqua_01/Turbidity_page.dart';
import 'package:just_aqua_01/pH.dart';
import 'package:just_aqua_01/ammonia.dart';
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
  double phupdate = 0.0;
  int turbidityUpdate = 0;
  String _selectedFishType = '';
  double? _temperatureThreshold;
  double? _ammoniaThreshold;
  double? _turbidityThreshold;
  double? _pHThreshold;
  bool _temperatureExceeded = false;
  bool _ammoniaExceeded = false;
  bool _turbidityExceeded = false;
  bool _pHExceeded = false;
  bool _initialLoad = true;
  DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');
  String? _userDisplayName;
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
    _fetchCurrentUser(); // _fetchRealtimeData(); // Call initially to fetch data and check thresholds
  }

  Future<void> _fetchCurrentUser() async {
    _user = FirebaseAuth.instance.currentUser!;
    String uid = _user.uid;

    try {
      if (_userRef != null) {
        print(uid);
        DataSnapshot snapshot = await _userRef.child(uid).get();
        var userData = snapshot.value as Map?;
        print(userData);
        if (userData != null) {
          String? username = userData['username'] as String?;

          // Check if the user has logged in using Google
          if (_user.providerData[0].providerId == 'google.com') {
            // If logged in using Google, use Google display name
            username = _user.displayName;
            print(_user.displayName);
          }

          if (username != null) {
            await _user.updateDisplayName(username);
            setState(() {
              _userDisplayName = username;
            });
          }
        } else {
          print('User data is null');
        }
      }
    } catch (error) {
      print('Error fetching username: $error');
    }
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
        _showAmmoniaNotification(message.notification!.title ?? '',
            message.notification!.body ?? '');
        _showPHNotification(message.notification!.title ?? '',
            message.notification!.body ?? '');
        _showTurbidityNotification(message.notification!.title ?? '',
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
        _fetchThresholds();
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
          _checkThresholds();
        });
      }
    });
    _database.child('Ammonia/Concentration').onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          ammoniaValue = snapshot.value.toString();
          _checkThresholds();
        });
      }
    });
    _database.child('Turbidity').onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          int? TurbidityValueDouble = int.tryParse(snapshot.value.toString());
          if (TurbidityValueDouble != null) {
            int turbidityUpdate = (TurbidityValueDouble / 34).toInt();
            turbidityValue = turbidityUpdate.toString();
            _checkThresholds();
          }
        });
      }
    });
    _database.child('PH/Value').onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          double? phValueDouble = double.tryParse(snapshot.value.toString());
          if (phValueDouble != null) {
            double phUpdate = phValueDouble - 4.75;
            pHValue = phUpdate.toStringAsFixed(3);
            _checkThresholds();
          } else {
            // Handle the case when the pH value cannot be parsed as a double
            // This could occur if the value from the database is not a valid number
          }
        });
      }
    });
  }

  void _checkThresholds() {
    if (!_initialLoad) {
      try {
        double temperature = double.tryParse(temperatureValue ?? '') ?? 0.0;
        double ammonia = double.tryParse(ammoniaValue ?? '') ?? 0.0;
        double turbidity = double.tryParse(turbidityValue ?? '') ?? 0.0;
        double pH = double.tryParse(pHValue ?? '') ?? 0.0;

        _checkTemperatureExceeded(temperature);
        _checkAmmoniaExceeded(ammonia);
        _checkTurbidityExceeded(turbidity);
        _checkPHExceeded(pH);
      } catch (e) {
        print('Error parsing values to double: $e');
        // Handle the error, such as showing a message to the user or logging it
      }
    }
    _initialLoad = false;
  }

  String _calculateWaterStatus() {
    if (_temperatureThreshold == null ||
        _ammoniaThreshold == null ||
        _turbidityThreshold == null ||
        _pHThreshold == null) {
      return 'Loading...';
    }

    double temperature = double.tryParse(temperatureValue) ?? 0.0;
    double ammonia = double.tryParse(ammoniaValue) ?? 0.0;
    double turbidity = double.tryParse(turbidityValue) ?? 0.0;
    double pH = double.tryParse(pHValue) ?? 0.0;

    if (temperature > _temperatureThreshold! - 1) {
      return ("Control the water Temperature !");
    } else if (ammonia > _ammoniaThreshold! - 0.1) {
      return ("Control the water Ammonia !");
    } else if (turbidity > _turbidityThreshold! - 10) {
      return ("Please clean the water !");
    } else if (pH > _pHThreshold! - 1) {
      return 'Control the pH of the water';
    } else {
      return 'Water seems to be Good for your $_selectedFishType';
    }
  }

  Future<void> _fetchThresholds() async {
    try {
      DataSnapshot snapshot =
          await _database.child('Fish/$_selectedFishType/Temperature').get();
      if (snapshot.value != null) {
        setState(() {
          _temperatureThreshold = double.parse(snapshot.value.toString());
        });
      }

      snapshot = await _database.child('Fish/$_selectedFishType/Ammonia').get();
      if (snapshot.value != null) {
        setState(() {
          _ammoniaThreshold = double.parse(snapshot.value.toString());
        });
      }

      snapshot =
          await _database.child('Fish/$_selectedFishType/Turbidity').get();
      if (snapshot.value != null) {
        setState(() {
          _turbidityThreshold = double.parse(snapshot.value.toString());
        });
      }

      snapshot = await _database.child('Fish/$_selectedFishType/pH').get();
      if (snapshot.value != null) {
        setState(() {
          _pHThreshold = double.parse(snapshot.value.toString());
        });
      }
    } catch (error) {
      print('Error fetching thresholds: $error');
    }
  }

  void _checkTemperatureExceeded(double currentTemperature) {
    bool previouslyExceeded = _temperatureExceeded;

    bool isExceeded = currentTemperature > _temperatureThreshold!;

    // Update the exceeded flag
    setState(() {
      _temperatureExceeded = isExceeded;
    });

    // Show notification only if the value exceeded the threshold and it was not previously exceeded
    if (isExceeded && !previouslyExceeded) {
      // _showTemperatureAlert();
      _showTemperatureNotification(
        'Temperature Alert!',
        'Temperature has exceeded ',
      );
      _storeNotification('Temperature Alert!', 'Temperature has exceeded');
    } else if (!isExceeded && previouslyExceeded) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // void _showTemperatureAlert() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           Icon(Icons.warning, color: Colors.yellow),
  //           SizedBox(width: 10),
  //           Text(
  //             'Temperature exceeded threshold!',
  //             style: TextStyle(color: Colors.yellow),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

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
  }

  void _checkAmmoniaExceeded(double currentAmmonia) {
    bool previouslyExceeded = _ammoniaExceeded;
    bool isExceeded = currentAmmonia > _ammoniaThreshold!;

    setState(() {
      _ammoniaExceeded = isExceeded;
    });

    if (isExceeded && !previouslyExceeded) {
      // _showAmmoniaAlert();
      _showAmmoniaNotification('Ammonia Alert!', 'Ammonia has exceeded');
      _storeNotification('Ammonia Alert!', 'Ammonia has exceeded');
    } else if (!isExceeded && previouslyExceeded) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // void _showAmmoniaAlert() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           Icon(Icons.warning, color: Colors.yellow),
  //           SizedBox(width: 10),
  //           Text(
  //             'Ammonia exceeded threshold!',
  //             style: TextStyle(color: Colors.yellow),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

  Future<void> _showAmmoniaNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Ammonia Alert',
      'Notifications for ammonia alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      '$body  $_ammoniaThreshold mg/L',
      platformChannelSpecifics,
    );
  }

  void _checkTurbidityExceeded(double currentTurbidity) {
    bool previouslyExceeded = _turbidityExceeded;
    bool isExceeded = currentTurbidity > _turbidityThreshold!;

    setState(() {
      _turbidityExceeded = isExceeded;
    });

    if (isExceeded && !previouslyExceeded) {
      // _showTurbidityAlert();
      _showTurbidityNotification('Turbidity Alert!', 'Turbidity has exceeded');
      _storeNotification('Turbidity Alert!', 'Turbidity has exceeded');
    } else if (!isExceeded && previouslyExceeded) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // void _showTurbidityAlert() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           Icon(Icons.warning, color: Colors.yellow),
  //           SizedBox(width: 10),
  //           Text(
  //             'Turbidity exceeded threshold!',
  //             style: TextStyle(color: Colors.yellow),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

  Future<void> _showTurbidityNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Turbidity Alert',
      'Notifications for Turbidity alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      '$body  $_turbidityThreshold NTU',
      platformChannelSpecifics,
    );
  }

  void _checkPHExceeded(double currentPH) {
    bool previouslyExceeded = _pHExceeded;
    bool isExceeded = currentPH > _pHThreshold!;

    setState(() {
      _pHExceeded = isExceeded;
    });

    if (isExceeded && !previouslyExceeded) {
      // _showPHAlert();
      _showPHNotification('pH Alert!', 'pH has exceeded');
      _storeNotification('pH Alert!', 'pH has exceeded');
    } else if (!isExceeded && previouslyExceeded) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // void _showPHAlert() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           Icon(Icons.warning, color: Colors.yellow),
  //           SizedBox(width: 10),
  //           Text(
  //             'pH exceeded threshold!',
  //             style: TextStyle(color: Colors.yellow),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

  Future<void> _showPHNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pH Alert',
      'Notifications for pH alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      '$body  $_pHThreshold ',
      platformChannelSpecifics,
    );
  }

  Future<void> _storeNotification(String title, String body) async {
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
          'body': body,
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
              _user.displayName ?? '', // Display user's display name
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 34,
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
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 20),
                              Text(
                                _calculateWaterStatus(),
                                style: TextStyle(
                                  fontSize: 18,
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
                      _temperatureExceeded,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AmmoniaPage()),
                      );
                    },
                    child: buildSensorCard(
                      "Ammonia",
                      ammoniaValue,
                      Icons.opacity,
                      "mg/L",
                      _ammoniaExceeded,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TurbidityPage()),
                      );
                    },
                    child: buildSensorCard(
                      "Turbidity",
                      turbidityValue,
                      Icons.visibility,
                      "NTU",
                      _turbidityExceeded,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Ph()),
                      );
                    },
                    child: buildSensorCard(
                      "pH",
                      pHValue,
                      Icons.whatshot,
                      "",
                      _pHExceeded,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSensorCard(String sensorName, String sensorValue,
      IconData iconData, String unit, bool exceeded) {
    Color cardColor = Color.fromARGB(70, 66, 66, 66);
    VoidCallback? onTapHandler;

    if (sensorName == 'Temperature') {
      onTapHandler = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TemperaturePage()),
        );
      };
    } else if (sensorName == 'Turbidity') {
      onTapHandler = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TurbidityPage()),
        );
      };
    }

    if (sensorName == 'Temperature' &&
        sensorValue != null &&
        _selectedFishType.isNotEmpty) {
      double currentTemperature = double.parse(sensorValue);
      if (_temperatureThreshold != null &&
          currentTemperature > _temperatureThreshold!) {
        cardColor = Colors.red;
      }
    }

    if (sensorName == 'Turbidity' &&
        sensorValue != null &&
        _selectedFishType.isNotEmpty) {
      double currentTubidity = double.parse(sensorValue);
      if (_turbidityThreshold != null &&
          currentTubidity > _turbidityThreshold!) {
        cardColor = Colors.red;
      }
    }

    if (sensorName == 'Ammonia' &&
        sensorValue != null &&
        _selectedFishType.isNotEmpty) {
      double currentAmmonia = double.parse(sensorValue);
      if (_ammoniaThreshold != null && currentAmmonia > _ammoniaThreshold!) {
        cardColor = Colors.red;
      }
    }

    if (sensorName == 'pH' &&
        sensorValue != null &&
        _selectedFishType.isNotEmpty) {
      double currentpH = double.parse(sensorValue);
      if (_pHThreshold != null && currentpH > _pHThreshold!) {
        cardColor = Colors.red;
      }
      sensorValue = currentpH.toStringAsFixed(4);
    }

    return GestureDetector(
      onTap: onTapHandler,
      child: Card(
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
