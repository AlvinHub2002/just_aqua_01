import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'bottom_navigation_bar.dart';
import 'LandingPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String selectedFishType = 'Salmon';
  late DatabaseReference _fishRef;

  @override
  void initState() {
    super.initState();
    initializeFirebase(); // Initialize Firebase
  }

  Future<void> initializeFirebase() async {
    // Initialize Firebase
    await Firebase.initializeApp();
    _fishRef = FirebaseDatabase.instance.ref().child('Fish');
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = 330.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('images/ig.jpg'),
          ),
          SizedBox(height: 10),
          Text(
            'Alvin Varghese',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Poppins',
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              'Update Profile',
              style: TextStyle(color: const Color.fromARGB(255, 30, 30, 30)),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Color.fromARGB(255, 203, 203, 203),
            ),
          ),
          SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: buttonWidth),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.email),
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'example@example.com',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 21, 21, 21),
                      minimumSize: Size(buttonWidth, 50),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: buttonWidth),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.phone),
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ph : 9744901994',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 21, 21, 21),
                      minimumSize: Size(buttonWidth, 50),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: buttonWidth),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.water),
                    ),
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fish type : $selectedFishType',
                          style: TextStyle(color: Colors.white),
                        ),
                        PopupMenuButton(
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry>[
                              PopupMenuItem(
                                child: Text('Guppy'),
                                value: 'Guppy',
                              ),
                              PopupMenuItem(
                                child: Text('Goldfish'),
                                value: 'Goldfish',
                              ),
                              PopupMenuItem(
                                child: Text('Catfish'),
                                value: 'Catfish',
                              ),
                            ];
                          },
                          onSelected: (value) {
                            _showConfirmationDialog(value
                                .toString()); // Show confirmation dialog here
                          },
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 21, 21, 21),
                      minimumSize: Size(buttonWidth, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              primary: const Color.fromARGB(255, 21, 21, 21),
              minimumSize: Size(buttonWidth, 50),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                '',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LandingPage()),
            );
          }
        },
      ),
    );
  }

  void _showConfirmationDialog(String newValue) async {
    try {
      DataSnapshot snapshot = await _fishRef.child(newValue).get();
      if (snapshot.value != null) {
        Map<dynamic, dynamic>? fishData =
            snapshot.value as Map<dynamic, dynamic>?;
        print(fishData);

        var temperatureThreshold = fishData?['Temperature'];
        if (temperatureThreshold != null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirmation'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Do you want to change the fish type to $newValue?'),
                    SizedBox(height: 10),
                    Text('Temperature Threshold: $temperatureThreshold'),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedFishType = newValue;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('Yes'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Temperature threshold not found for $newValue');
        }
      } else {
        print('No data found for $newValue');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
}
