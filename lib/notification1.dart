import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:justhome/additem.dart';
import 'package:justhome/chatlist.dart';
import 'package:justhome/drawer.dart';
import 'package:justhome/homepage.dart';
import 'package:justhome/productdetails.dart';
import 'package:justhome/profile.dart';
// Import the ProductPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Notification1(), // Your home page
    );
  }
}

class Notification1 extends StatefulWidget {
  const Notification1({super.key});

  @override
  State<Notification1> createState() => _Notification1State();
}

class _Notification1State extends State<Notification1> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _resetNotificationCount(); // Reset notification count
  }

  void _resetNotificationCount() {
    // Implement logic to reset notification count in your database or state
    // If you are using a global state management, reset it here.
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(207, 196, 196, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          "All Notifications",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(207, 196, 196, 1),
      ),
      drawer: Moreoption(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No Notification available.'));
          }

          final properties = snapshot.data!.docs
              .where((doc) =>
                  doc['userId'] !=
                  currentUserId) // Filter out notifications from the current user
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              var property = properties[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundImage: property['userImage'] != null &&
                              property['userImage'].isNotEmpty
                          ? NetworkImage(property['userImage'])
                          : null,
                      child: property['userImage'] == null ||
                              property['userImage'].isEmpty
                          ? Icon(Icons.home, size: 40)
                          : null,
                    ),
                  ),
                  title: Text(
                    '${property['username'] ?? 'Unknown'} Added New Property',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(31, 76, 107, 1)),
                  ),
                  subtitle: Text(
                    "${property['location']} - ${property['category']} for ${property['forWhat']}",
                    style: TextStyle(color: Colors.black),
                  ),
                  trailing: Text(
                    property['createdAt'] != null
                        ? property['createdAt']
                        : "No time available",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    // Navigate to ProductPage with all details
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchAppbarPage(
                        homeName: property['homename'],
                        location: property['location'],
                        category: property['category'],
                        imageUrls: List<String>.from(
                            property['imageUrls']), // Display the first image
                        price: property['price'],
                        type: property['forWhat'],
                        area: property['area'], // Pass area
                        floor: property['floor'], // Pass floor
                        bed: property['bed'], // Pass bed
                        bath: property['bath'], // Pass bath
                        username: property['username'], // Pass username
                        userImage: property['userImage'],
                        userId: property['userId'],
                        createdAt: property['createdAt'],
                      ),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemPage()),
          );
        },
        backgroundColor: Color.fromRGBO(31, 76, 107, 1),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 86,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavIcon(context, Icons.home, 'Home', HomePage()),
            _buildBottomNavIcon(
                context, Icons.message, 'Inbox', ChatListPage()),
            SizedBox(width: 40),
            _buildBottomNavIcon(
                context, Icons.person_2, 'Profile', ProfilePage()),
            _buildMoreButton(),
          ],
        ),
      ),
    );
  }

  Column _buildBottomNavIcon(BuildContext context, IconData icon, String label,
      Widget destinationPage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationPage),
            );
          },
          icon: Icon(icon, color: Colors.black),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Column _buildMoreButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(Icons.more_horiz, color: Colors.black),
        ),
        const Text('More',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
