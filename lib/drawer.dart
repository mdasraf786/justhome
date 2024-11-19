import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:justhome/addeditem.dart';
import 'package:justhome/favourite.dart';
import 'package:justhome/images.dart';
import 'package:justhome/loginform.dart';
import 'package:justhome/notification.dart';
import 'package:justhome/additem.dart';
import 'package:justhome/notification1.dart';
import 'package:justhome/reportissue1.dart';

class Moreoption extends StatefulWidget {
  const Moreoption({super.key});

  @override
  State<Moreoption> createState() => _MoreoptionState();
}

class _MoreoptionState extends State<Moreoption> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _username;
  String? _imageUrl;
  String? _password;
  String? _email;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc['username'];
        _imageUrl = userDoc['imageUrl'];
        _password = userDoc['password'];
        _email = userDoc['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 20,
      shape:
          BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
      child: Material(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 225, 218, 218),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(_imageUrl ?? 'Loading...'),
                  ),
                  SizedBox(height: 2), // Space between image and text
                  Expanded(
                    child: Text(
                      _username ?? 'Loading...', // Fallback for null username
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    _email ?? 'Loading...', // Example phone number
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notification1()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favourite'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Favourite()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Privacy & Safety'),
              onTap: () {
                // Handle tap on Privacy & Safety
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.report_problem),
              title: Text('Report & Issue'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => reportissue()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Helps'),
              onTap: () {
                // Handle tap on Helps
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Added Items'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddedItems()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginForm()),
                );
              },
            ),
            // Add more items here
          ],
        ),
      ),
    );
  }
}
