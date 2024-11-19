import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:justhome/SplashscreenWidget.dart';
import 'package:justhome/homepage.dart';
import 'package:justhome/register.dart';
import 'package:justhome/register1.dart';

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Just Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance
  bool agreeToTerms = false;

  final double buttonWidthFactor = 0.9;
  final double buttonHeight = 50.0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Define regular expressions for validation
  final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'); // Basic email pattern
  final RegExp passwordRegExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$'); // At least 8 chars, 1 letter & 1 number

  String? emailError;
  String? passwordError;

  void _validateAndLogin() {
    // Validate email and password format before checking Firebase
    String email = usernameController.text.trim();
    String password = passwordController.text.trim();

    // Regular expression for validating email format
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp emailRegExp = RegExp(emailPattern);

    // Check email format
    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address'),
        ),
      );
      return; // Stop execution if email is invalid
    }

    // Check password length
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters long'),
        ),
      );
      return; // Stop execution if password is invalid
    }

    // Check if terms & conditions are agreed
    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to the terms & conditions'),
        ),
      );
      return; // Stop execution if terms are not agreed
    }

    // If all validations pass, call the login function
    _loginUser(); // Call login function
  }

  Future<void> _forgotPassword() async {
    String email = usernameController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent! Check your email.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth == null) {
        throw Exception('Google sign-in failed');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if the user already exists in Firestore
      DocumentReference userRef =
          _firestore.collection('users').doc(userCredential.user?.uid);

      // If user does not exist, create a new user document
      userRef.get().then((doc) {
        if (!doc.exists) {
          // User does not exist, create a new user document
          userRef.set({
            'userId': userCredential.user?.uid,
            'email': userCredential.user?.email,
            'username': userCredential.user?.displayName,
            'imageUrl': userCredential.user?.photoURL,
            'password': '*******', // You may not want to store the password
            'createdAt':
                FieldValue.serverTimestamp(), // Automatically sets timestamp
          });
        }
      });

      // Navigate to the home page after successful login
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    }
  }

  Future<void> _loginUser() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Please verify your email by checking your mail before logging in.')),
        );
        await _auth.signOut(); // Log the user out if email is not verified
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    }
  }

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the SplashscreenWidget
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SplashscreenWidget()),
            );
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
                  'assets/images/new.png', // Make sure this path is correct
                  width: 50,
                  height: 50,
                ),
                SizedBox(width: 0),
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
      backgroundColor:
          isDarkMode ? Color(0xFF121212) : Color.fromRGBO(207, 196, 196, 1),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Add crossAxisAlignment here to align the text to the start
                  children: <Widget>[
                    SizedBox(height: screenWidth * 0.1), // Add a bit of spacing

                    // Align "Let's Sign In" text to the right
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Let's ",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "Sign In",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  color: Color.fromRGBO(31, 76, 107, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                        height: screenWidth *
                            0.05), // Add some space before the text fields

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter your Email",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.05),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible, // Toggle visibility
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter your password",
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible =
                                    !_isPasswordVisible; // Toggle password visibility
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _forgotPassword();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              agreeToTerms = value!;
                            });
                          },
                        ),
                        Text.rich(
                          TextSpan(
                            text: "I agree with the ",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: "terms & conditions",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  color: Color.fromRGBO(31, 76, 107, 1),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.05),
                    Center(
                      child: Container(
                        width: screenWidth * buttonWidthFactor,
                        height: buttonHeight,
                        child: TextButton(
                          onPressed: () {
                            if (agreeToTerms) {
                              _validateAndLogin(); // Call login function
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Please agree to the terms & conditions'),
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(31, 76, 107, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    Align(
                      alignment: Alignment.center, // Center the "OR" text
                      child: Text(
                        "OR",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontFamily: 'Poppins',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: screenWidth * 0.03),

                    // Google Sign In Button using Icons
                    Center(
                      child: Container(
                        width: screenWidth * buttonWidthFactor,
                        height: buttonHeight,
                        child: TextButton(
                          onPressed: () async {
                            try {
                              await signInWithGoogle();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Google sign-in failed: $e'),
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons
                                    .g_mobiledata, // Replace this with your preferred Google icon from Icons
                                color: Colors.red,
                                size: screenWidth * 0.06,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Sign up with Google",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenWidth * 0.08),

                    // Facebook Login Button
                    Center(
                      child: Container(
                        width: screenWidth * buttonWidthFactor,
                        height: buttonHeight,
                        child: TextButton(
                          onPressed: () {
                            // Handle Login with Facebook
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.facebook,
                                color: Colors.white,
                                size: screenWidth * 0.06,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Login with Facebook",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an account?",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontFamily: 'Poppins',
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to Register Page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterForm()),
                            );
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: Color.fromRGBO(31, 76, 107, 1),
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
