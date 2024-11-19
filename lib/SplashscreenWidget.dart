import 'package:flutter/material.dart';
import 'package:justhome/Onboardscreen1Widget.dart'; // Correctly import Onboardscreen1Widget

class SplashscreenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromRGBO(207, 196, 196, 1),
        ),
        child: Stack(
          children: <Widget>[
            // Align logo and "JustHome" text horizontally
            Positioned(
              top: 150, // Adjusted top position for better spacing
              left: (MediaQuery.of(context).size.width - 280) / 2, // Center horizontally
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                
                  Image.asset(
                    'assets/images/new.png',
                    width: 80,
                    height: 200,
                  ),
                  SizedBox(width: 0), // Spacing between image and text
                  Text(
                    'JustHome',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      
                    ),
                  ),
                ],
              ),
            ),
            
            // Positioning for "Real estate" section
            Positioned(
              top: 300, // Adjusted position to have sufficient gap
              left: (MediaQuery.of(context).size.width - 211) / 2, // Center horizontally
              child: Container(
                width: 211,
                height: 150, // Adjusted height to fit the text
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      child: Text(
                        'R',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color.fromRGBO(11, 11, 11, 1),
                          fontFamily: 'Poppins',
                          fontSize: 90,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 25, // Adjusted to align "eal" under "R"
                      left: 55,
                      child: Text(
                        'eal',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color.fromRGBO(11, 11, 11, 1),
                          fontFamily: 'Poppins',
                          fontSize: 32,
                          fontWeight: FontWeight.normal,
                          height: 1,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60, // Adjusted to align "estate" under "R"
                      left: 55,
                      child: Text(
                        'estate',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color.fromRGBO(11, 11, 11, 1),
                          fontFamily: 'Poppins',
                          fontSize: 32,
                          fontWeight: FontWeight.normal,
                          height: 1,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100, // Positioned below "R" and "estate"
                      left: 0,
                      child: Text(
                        'Making dreams come to you',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(11, 11, 11, 1),
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
           
            // Button Positioning
            Positioned(
              bottom: 30, // Adjusted bottom position for the button
              left: (MediaQuery.of(context).size.width - 240) / 2, // Center horizontally
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => JustHomePage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = 0.0;
                        const end = 1.0;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end);
                        var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
                        var opacityAnimation = tween.animate(curvedAnimation);

                        return FadeTransition(opacity: opacityAnimation, child: child);
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(31, 76, 107, 1), // Button background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(240),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15.5),
                ),
                child: Text(
                  'Let\'s start',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
