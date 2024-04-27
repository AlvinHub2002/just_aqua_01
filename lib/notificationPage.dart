import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:just_aqua_01/profilePage.dart';
import 'LandingPage.dart';
import 'bottom_navigation_bar.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Mark all notifications as read
              FirebaseDatabase.instance
                  .reference()
                  .child('users')
                  .child(FirebaseAuth.instance.currentUser!.uid)
                  .child('notifications')
                  .remove();
            },
            icon: Icon(Icons.check_circle_outline_sharp),
            color: Colors.blue,
            iconSize: 28.0,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildUnreadNotificationsList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LandingPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildUnreadNotificationsList() {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('notifications')
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.snapshot.value != null &&
            (snapshot.data!.snapshot.value as Map).isNotEmpty) {
          Map<dynamic, dynamic>? notifications =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;

          // Check if notifications is not null before accessing entries
          if (notifications != null) {
            List<MapEntry<dynamic, dynamic>> notificationList =
                notifications.entries.toList();
            notificationList.sort((a, b) {
              // Sort notifications by timestamp in descending order
              return b.value['timestamp'].compareTo(a.value['timestamp']);
            });
            return ListView.builder(
              itemCount: notificationList.length,
              itemBuilder: (context, index) {
                final notificationKey = notificationList[index].key;
                final notification = notificationList[index].value;
                final notificationTime = DateTime.fromMillisecondsSinceEpoch(
                    notification['timestamp']);
                final formattedTime =
                    DateFormat('MMM dd, yyyy hh:mm a').format(notificationTime);
                return Card(
                  color: Colors.transparent,
                  elevation: 0,
                  child: ListTile(
                    title: Text(
                      notification['title'],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['body'],
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(
                              255, 255, 255, 255), // Set border color
                          width: 0, // Set border width
                        ),
                        borderRadius:
                            BorderRadius.circular(20), // Set border radius
                      ),
                      child: TextButton(
                        onPressed: () {
                          // Mark the notification as read or perform desired action
                          // For example, you can delete the notification from the database
                          FirebaseDatabase.instance
                              .reference()
                              .child('users')
                              .child(FirebaseAuth.instance.currentUser!.uid)
                              .child('notifications')
                              .child(notificationKey)
                              .remove();
                        },
                        child: Text(
                          'Mark as Read',
                          style: TextStyle(
                            color: Color.fromARGB(
                                255, 131, 126, 236), // Change color as needed
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
        // Return a message if no notifications found or data is null
        return Center(
          child: Text(
            'No unread notifications',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
