import 'package:flutter/material.dart';

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
      home: reportissue(), // Your home page
    );
  }
}

class reportissue extends StatelessWidget {
  const reportissue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 225, 218, 218),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Navigates to the previous page
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Report An Issue'),
        backgroundColor: Color.fromARGB(255, 231, 222, 222),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                'Name',
                style: TextStyle(
                    fontSize: 16, color: const Color.fromARGB(255, 65, 64, 64)),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(17.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter your name',
                    filled: true, // Set filled to true
                    fillColor: Colors.white, // Set fill color to white
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Add border radius
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Add border radius
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                'Email ID',
                style: TextStyle(
                    fontSize: 16, color: const Color.fromARGB(255, 65, 64, 64)),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(17.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter your email id',
                    filled: true, // Set filled to true
                    fillColor: Colors.white, // Set fill color to white
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Add border radius
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Add border radius
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                'Mobile Number',
                style: TextStyle(
                    fontSize: 16, color: const Color.fromARGB(255, 65, 64, 64)),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(17.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter your Mobile Number',
                    filled: true, // Set filled to true
                    fillColor: Colors.white, // Set fill color to white
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Add border radius
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Add border radius
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                  ),
                )),
            Padding(
                padding: const EdgeInsets.all(17.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText:
                        'Anything Else to share, share it here (optional)',
                    filled: true, // Set filled to true
                    fillColor: Colors.white, // Set fill color to white
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Add border radius
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Add border radius
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                  ),
                  maxLines: 5,
                )),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Center(
                child: MaterialButton(
                  color:
                      Color.fromRGBO(31, 76, 107, 1), // Button background color
                  textColor: Colors.white, // Text color
                  onPressed: () {
                    // Add your button press logic here
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 20), // Increase the size of the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Button shape
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
