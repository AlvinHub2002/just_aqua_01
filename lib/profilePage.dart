import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_aqua_01/notificationPage.dart';
import 'bottom_navigation_bar.dart';
import 'LandingPage.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String selectedFishType = '';
  late DatabaseReference _fishRef;
  late User _user; // Store the current user
  DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');
  String? _userDisplayName;
  var ph_number;

  @override
  void initState() {
    super.initState();
    initializeFirebase(); // Initialize Firebase
    _fetchCurrentUser(); // Fetch current user
  }

  Future<void> initializeFirebase() async {
    // Initialize Firebase
    await Firebase.initializeApp();
    _fishRef = FirebaseDatabase.instance.ref().child('Fish');
    // Initialize _userRef here
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
          ph_number = userData['phoneNumber'];
          String? selectedFish = userData['selectedFishType'] as String?;

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
              selectedFishType = selectedFish ?? 'Not selected';
            });
            print(selectedFishType);
          }
        } else {
          print('User data is null');
        }
      }
    } catch (error) {
      print('Error fetching username: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = 330.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: Colors.black,
      ),
      body: _user != null // Check if the user data is fetched
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('images/profile_icon.png'),
                ),
                SizedBox(height: 10),
                Text(
                  _user.displayName ?? '', // Display user's display name
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
                    style:
                        TextStyle(color: const Color.fromARGB(255, 30, 30, 30)),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Color.fromARGB(255, 203, 203, 203),
                  ),
                ),
                SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints:
                            BoxConstraints.tightFor(width: buttonWidth),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Icon(Icons.email),
                          ),
                          label: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _user.email ?? '', // Display user's email
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 21, 21, 21),
                            minimumSize: Size(buttonWidth, 50),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ConstrainedBox(
                        constraints:
                            BoxConstraints.tightFor(width: buttonWidth),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Icon(Icons.phone),
                          ),
                          label: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Ph : $ph_number',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 21, 21, 21),
                            minimumSize: Size(buttonWidth, 50),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ConstrainedBox(
                        constraints:
                            BoxConstraints.tightFor(width: buttonWidth),
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
                            backgroundColor:
                                const Color.fromARGB(255, 21, 21, 21),
                            minimumSize: Size(buttonWidth, 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _signOut();
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 21, 21, 21),
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
            )
          : Center(
              child:
                  CircularProgressIndicator()), // Show loading indicator if user data is not yet fetched
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LandingPage()),
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
                    onPressed: () async {
                      // Update the selected fish type in the user's data
                      await _userRef.child(_user.uid).update({
                        'selectedFishType': newValue,
                      });
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

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user
      Navigator.pushReplacement(
        // Navigate to the login page
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
