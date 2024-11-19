import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:justhome/callingpage.dart';
import 'package:justhome/database_services.dart';

class ChatPage extends StatelessWidget {
  final String userId; // Receiver's user ID
  final String username;
  final String userImage; // Receiver's username

  ChatPage({
    required this.userId,
    required this.username,
    required this.userImage,
  }) {
    if (userImage.isEmpty) {
      print("Warning: User Image URL is empty!");
    } else {
      print("ChatPage initialized with User Image URL: $userImage");
    }
  }

  final TextEditingController messageController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController

  Future<void> sendMessage() async {
    String message = messageController.text.trim();

    if (message.isNotEmpty) {
      await _databaseService.sendMessage(
        FirebaseAuth.instance.currentUser!.uid, // Current user's ID
        userId, // Receiver's ID
        message,
        userImage,
      );
      messageController.clear(); // Clear the input field after sending

      // Scroll to the bottom after sending a message
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 194, 212, 227),
            ),
            child: IconButton(
              iconSize: 20,
              icon: Icon(Icons.call_outlined, color: Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CallingPage(),
                  ),
                );
              },
            ),
          ),
        ],
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(2),
              child: ClipOval(
                  child: Image.network(
                userImage,
                fit: BoxFit.cover,
              )
                  // Replace with your image URL

                  ),
            ),
            SizedBox(width: 10),
            Text(username),
          ],
        ),
        backgroundColor: const Color.fromRGBO(207, 196, 196, 1),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _databaseService.getMessages(
                FirebaseAuth.instance.currentUser!.uid,
                userId,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                // If there are no messages, show "Start the chat"
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Start the chat",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController, // Use the ScrollController
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data![index];
                    bool isSender = message['senderId'] ==
                        FirebaseAuth.instance.currentUser!.uid;

                    return Padding(
                      padding: const EdgeInsets.all(
                          8.0), // Padding around each message
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align items to the start
                        children: [
                          Center(
                            child: Container(
                              width: 110,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(34, 77, 106, 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  message['timestamp'] != null
                                      ? DateFormat('d MMM, yyyy').format(message[
                                              'timestamp']
                                          .toDate()) // Format timestamp to "8 Aug, 2024"
                                      : "No date", // Fallback message if timestamp is null
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5), // Space between date and message
                          Align(
                            alignment: isSender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  0.7, // Adjusts width to 70% of screen width
                              padding: EdgeInsets.all(
                                  10), // Add some padding inside the container
                              decoration: BoxDecoration(
                                color: isSender
                                    ? Color.fromRGBO(31, 76, 107, 1)
                                    : Colors
                                        .white, // Background color based on sender/receiver
                                borderRadius:
                                    BorderRadius.circular(10), // Border radius
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Align content to the start
                                children: [
                                  Text(
                                    message['message'],
                                    style: TextStyle(
                                      color: isSender
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize:
                                          16, // Font size for the message text
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          5), // Space between message and time
                                  Align(
                                    alignment: Alignment
                                        .bottomRight, // Align time to the bottom right
                                    child: Text(
                                      message['timestamp'] != null
                                          ? DateFormat('hh:mm a').format(message[
                                                  'timestamp']
                                              .toDate()) // Format timestamp to string
                                          : "No time", // Fallback message if timestamp is null
                                      style: TextStyle(
                                        color: isSender
                                            ? Colors.white70
                                            : Colors
                                                .grey, // Text color for the time
                                        fontSize:
                                            10, // Smaller font size for the time
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: "Type a message",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color.fromRGBO(31, 76, 107, 1),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
