import 'package:flutter/material.dart';
import 'package:justhome/appbarforchatting.dart';
import 'package:justhome/callingpage.dart';
// import 'package:real_estate/appbarforchatting.dart';
// import 'package:real_estate/callingpage.dart';
// import 'package:real_estate/callingpage.dart';

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
      home: ChattingPage(), // Your home page
    );
  }
}

class ChattingPage extends StatefulWidget {
  const ChattingPage({super.key});

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Center(
              child: Container(
                width: 110,
                height: 25,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(34, 77, 106, 1),
                    borderRadius: BorderRadius.circular(15)),
                child: Center(
                  child: Text(
                    'Augest, 2024',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.7, // Adjusts width to 70% of screen width
                padding:
                    EdgeInsets.all(10), // Add some padding inside the container
                decoration: BoxDecoration(
                  color: Colors.white, // Background color
                  borderRadius: BorderRadius.circular(10), // Border radius
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align content to the start
                  children: [
                    Text(
                      'Hey I am MD Asraf Ali, I have seen your product and I want to buy it',
                      style: TextStyle(
                        color: Colors.black, // Text color
                        fontSize: 12, // Adjust font size as needed
                      ),
                    ),
                    SizedBox(height: 5), // Space between message and time
                    Align(
                      alignment: Alignment
                          .bottomRight, // Align time to the bottom right
                      child: Text(
                        '10:30 AM', // Replace with the actual time
                        style: TextStyle(
                          color: Colors.grey, // Text color for the time
                          fontSize: 10, // Smaller font size for the time
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.7, // Adjusts width to 70% of screen width
                    padding: EdgeInsets.all(
                        10), // Add some padding inside the container
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(34, 77, 106, 1), // Background color
                      borderRadius: BorderRadius.circular(10), // Border radius
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Align content to the start
                      children: [
                        Text(
                          'Hey I am MD Asraf Ali, I have seen your product and I want to buy it',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 12, // Adjust font size as needed
                          ),
                        ),
                        SizedBox(height: 5), // Space between message and time
                        Align(
                          alignment: Alignment
                              .bottomRight, // Align time to the bottom right
                          child: Text(
                            '10:30 AM', // Replace with the actual time
                            style: TextStyle(
                              color: Colors.grey, // Text color for the time
                              fontSize: 10, // Smaller font size for the time
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            border: Border.all(color: Colors.black), // Border color
            borderRadius: BorderRadius.circular(15), // Border radius
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CallingPage(),
                    ),
                  );
                },
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(34, 77, 106, 1),
                ),
                child: IconButton(
                  iconSize: 20,
                  icon: Icon(
                    Icons.send,
                    color: Colors.white, // Icon color
                  ),
                  onPressed: () {
                    // Send action
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
