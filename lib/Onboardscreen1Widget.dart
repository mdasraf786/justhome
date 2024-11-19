import 'package:flutter/material.dart';
import 'package:justhome/loginform.dart';

class JustHomePage extends StatefulWidget {
  const JustHomePage({Key? key}) : super(key: key);

  @override
  _JustHomePageState createState() => _JustHomePageState();
}

class _JustHomePageState extends State<JustHomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 2) { // Change this to the total number of pages - 1
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Navigate to LoginForm when finished
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginForm()),
      );
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          // Background color
          Container(
            color: Color.fromRGBO(207, 196, 196, 1),
          ),
          // PageView for the content
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              buildPage('assets/images/f.png', 'Our Service\nis outstanding as\nyours.'),
              buildPage('assets/images/s.png', 'Quality and Trust\nis our priority.'),
              buildPage('assets/images/t.png', 'Experience the best\nwith us.'),
            ],
          ),
          // Custom AppBar with modified content
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  IconButton(
                    onPressed: () {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  
                  // Inserted Image and Text Row
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/new.png',
                        width: 70, // Adjusted to match the design
                        height: 80,
                      ),
                      SizedBox(width: 2), // Spacing between image and text
                      Text(
                        'JustHome',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors.black, // Text color to match design
                        ),
                      ),
                    ],
                  ),

                  // Skip Button
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginForm()),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content below the PageView
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == 2 ? 'Finish' : 'Next',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(31, 76, 107, 1),
                      padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return GestureDetector(
                        onTap: () => _goToPage(index),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index ? Color.fromRGBO(31, 76, 107, 1) : Colors.grey[300],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage(String imagePath, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        children: [
          // Centering the image
          Image.asset(
            imagePath, // Use the passed imagePath
            width: 300, // Adjust width as needed
            height: 300, // Adjust height as needed
            fit: BoxFit.contain, // Maintain aspect ratio
          ),
          SizedBox(height: 20), // Space between image and text
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
