import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:justhome/additem.dart';
import 'package:justhome/chatpage.dart';
import 'package:justhome/database_services.dart';
import 'package:justhome/drawer.dart';
import 'package:justhome/homepage.dart';
import 'package:justhome/profile.dart';
import 'package:justhome/register.dart';

import 'package:firebase_auth/firebase_auth.dart';

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
      home: ChatListPage(), // Your home page
    );
  }
}

class ChatListPage extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(207, 196, 196, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          "All Chats",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(207, 196, 196, 1),
      ),
      drawer: Moreoption(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _databaseService.getChatList(currentUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return Center(child: Text('No chats available.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
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
                      backgroundImage: user['userImage'] != null &&
                              user['userImage'].isNotEmpty
                          ? NetworkImage(user[
                              'userImage']) // Set the backgroundImage directly
                          : null, // No image, set to null
                      child: user['userImage'] == null ||
                              user['userImage'].isEmpty // Check for placeholder
                          ? Icon(Icons.person,
                              size: 40) // Use an icon if image URL is empty
                          : null,
                    ),
                  ),
                  title: Text(
                    user['username'] ?? 'Unknown',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(31, 76, 107, 1)),
                  ),
                  subtitle: Text(
                    user['lastMessage'] ?? "No messages yet",
                    style: TextStyle(color: Colors.black),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 2),
                      Text(
                        user['timestamp'] != null
                            ? DateFormat('d MMM, yyyy').format(user['timestamp']
                                .toDate()) // Format timestamp to "8 Aug, 2024"
                            : "No date", // Fallback message if timestamp is null
                      ),
                      SizedBox(height: 4),
                      Text(
                        user['timestamp'] != null
                            ? DateFormat('hh:mm a').format(user['timestamp']
                                .toDate()) // Format timestamp to string
                            : "No messages yet",
                      ),
                      // Optional space between the trailing text and the new widget
                      // Add your new widget here
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatPage(
                        userId: user['id'],
                        userImage: user['userImage'] ?? 'Unknown',
                        username: user['username'] ?? 'Unknown',
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
