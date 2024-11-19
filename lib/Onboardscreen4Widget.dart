import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Onboardscreen4Widget extends StatelessWidget {
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
            // SVG at the top center
            Positioned(
              top: 138,
              left: (MediaQuery.of(context).size.width - 270) / 2, // Center horizontally
              child: SvgPicture.asset(
                'assets/images/vector.svg',
                semanticsLabel: 'vector',
                width: 270, // Adjust width as needed
              ),
            ),

            // Centered text moved a bit down for image space
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 40, // Moved a bit down
              left: (MediaQuery.of(context).size.width - 240) / 2, // Center horizontally
              child: Text(
                'JH Estate\nService At Their\nPeak.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                  height: 1.2,
                ),
              ),
            ),

            // "Next" button moved a bit to the right
            Positioned(
              bottom: 100,
              left: (MediaQuery.of(context).size.width - 240) / 2 + 10, // Moved a bit right
              child: ElevatedButton(
                onPressed: () {
                  print('Next Button Pressed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(31, 76, 107, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(240),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                ),
                child: Text(
                  'Next',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    letterSpacing: 0,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
              ),
            ),

            // Indicators below the button
            Positioned(
              bottom: 60,
              left: (MediaQuery.of(context).size.width - 70) / 2, // Center horizontally
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.5),
                      color: Color.fromRGBO(31, 76, 107, 1),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // "Skip" text at the top right
            Positioned(
              top: 39,
              right: 30,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                  height: 1,
                ),
              ),
            ),

            // SVG near the top center
            Positioned(
              top: 20,
              left: (MediaQuery.of(context).size.width - 150) / 2, // Center horizontally
              child: Container(
                width: 150,
                height: 42,
                child: SvgPicture.asset(
                  'assets/images/vector.svg',
                  semanticsLabel: 'vector',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
