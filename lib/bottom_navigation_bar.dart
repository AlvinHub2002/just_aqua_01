import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('notifications')
          .onValue,
      builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While data is loading, show bottom navigation without red dot
          return _buildBottomNavigationBar(false);
        } else {
          // Check if there are unread notifications
          bool hasUnreadNotifications = _hasUnreadNotifications(snapshot.data);
          return _buildBottomNavigationBar(hasUnreadNotifications);
        }
      },
    );
  }

  bool _hasUnreadNotifications(DatabaseEvent? snapshot) {
    if (snapshot != null && snapshot.snapshot.value != null) {
      Map<dynamic, dynamic>? notifications =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      if (notifications != null && notifications.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  Widget _buildBottomNavigationBar(bool showNotificationDot) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color.fromARGB(255, 117, 117, 117),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.notifications),
              if (showNotificationDot)
                Positioned(
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: onTap,
    );
  }
}
