import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:justhome/homepage.dart'; // Ensure this import is correct

class OtpVerification extends StatefulWidget {
  String verificationid;
  OtpVerification({super.key, required this.verificationid});

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final TextEditingController otpcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? Color(0xFF121212) : Color.fromRGBO(207, 196, 196, 1),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Return to the previous page
          },
        ),
        backgroundColor:
            isDarkMode ? Colors.black : Color.fromRGBO(207, 196, 196, 1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/new.png',
                  width: 50,
                  height: 260,
                ),
                SizedBox(width: 0), // Spacing between image and text
                Text(
                  'JustHome',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                SizedBox(width: 13),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the verification code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'A 4 digit code has been sent to your registered phone number.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: otpcontroller,
                )
                // _buildCodeBox('1'),
                // const SizedBox(width: 8),
                // _buildCodeBox('2'),
                // const SizedBox(width: 8),
                // _buildCodeBox('3'),
                // const SizedBox(width: 8),
                // _buildCodeBox('4'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                color: Color.fromRGBO(207, 196, 196, 1),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, color: Colors.black),
                  const SizedBox(width: 4),
                  const Text(
                    '60 sec',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 280,
              height: 60,
              child: MaterialButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                      verificationId: widget.verificationid,
                      smsCode: otpcontroller.text.trim(),
                    );

                    // Sign in using the credential
                    await FirebaseAuth.instance
                        .signInWithCredential(credential)
                        .then((value) {
                      // Navigate to home page after successful sign-in
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Invalid OTP or Error: ${e.toString()}")),
                    );
                  }
                },
                color: const Color.fromRGBO(31, 76, 107, 1),
                textColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 18),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color.fromRGBO(31, 76, 107, 1)),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh,
                      color: Color.fromRGBO(31, 76, 107, 1)),
                  const SizedBox(width: 8),
                  const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeBox(String digit) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
