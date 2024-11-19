import 'package:flutter/material.dart';
import 'package:justhome/images.dart';

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
      home: CallingPage(), // Your home page
    );
  }
}

class CallingPage extends StatefulWidget {
  const CallingPage({super.key});

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 225, 218, 218),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(100.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'MD ASRAF ALI',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(62, 110, 142, 1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        '10:05',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 140),
                Center(
                  child: Container(
                    // Adjust the size of the profile image container
                    width: MediaQuery.of(context).size.width *
                        0.150, // Smaller size
                    height: MediaQuery.of(context).size.width *
                        0.150, // Smaller size
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          15), // Adjust for rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 29, 204, 35)
                              .withOpacity(0.8), // Adjusted green shadow color
                          blurRadius: 30, // Increased blur for a soft shadow
                          spreadRadius:
                              10, // Spread radius for a circular effect
                          offset: Offset(0, 0), // Center the shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(15), // Match border radius
                      child: Image.asset(
                        profile, // Replace with your image URL or asset
                        fit: BoxFit.cover, // Adjust image to fit the container
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200,
              width: double.infinity,
              color: Color(0xFFEFEFEF), // Adjusted color for better visibility
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row for Message and Mute Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Message Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          shape: BoxShape.circle, // Make it circular
                        ),
                        child: Icon(
                          Icons.message,
                          color: Colors.black, // Icon color
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      // Mute Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          shape: BoxShape.circle, // Make it circular
                        ),
                        child: Icon(
                          Icons.mic_none_outlined,
                          color: Colors.black, // Icon color
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40), // Space between the rows

                  // Row for End Call Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color: Color.fromRGBO(
                            34, 77, 106, 1), // Button background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minWidth: 200, // Set minimum width
                        height: 60, // Set height
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        onPressed: () {
                          // End call action
                        },
                        child: Row(
                          children: [
                            // Container for the call icon with transparent background
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.1), // Semi-transparent white
                                shape: BoxShape.circle, // Circular shape
                              ),
                              padding:
                                  EdgeInsets.all(8), // Padding for the icon
                              child: Icon(Icons.call_end,
                                  color: Colors.white), // Call icon
                            ),
                            SizedBox(width: 25), // Space between icon and text
                            Text(
                              "End Call",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
