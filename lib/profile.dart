import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:justhome/additem.dart';
import 'package:justhome/chatlist.dart';
import 'package:justhome/drawer.dart';
import 'package:justhome/homepage.dart';
import 'package:justhome/loginform.dart';
import 'package:justhome/notification.dart';

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
      home: ProfilePage(), // Your home page
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> addedUsers = []; // Store added users

  String? _username;
  String? _password;
  String? _imageUrl;
  String? _email;
  String? userId;
  var currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController currentPasswordcontroller =
      TextEditingController();
  final TextEditingController newPasswordcontroller = TextEditingController();
  final passwordRegex =
      RegExp(r'^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,}$');

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc['username'];
        _imageUrl = userDoc['imageUrl'];
        _email = userDoc['email'];
        _password = userDoc['password'];
        userId = userDoc['userId'];
        _usernameController.text = _username!;
        _emailController.text = _email!;
      });
    }
  }

  Future<void> _updateUserData(String field, String value) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({field: value});
      setState(() {
        if (field == 'username') {
          _username = value;
        } else if (field == 'email') {
          _email = value;
        }
      });
    }
  }

  // Change password
  changePassword(
      {required String email,
      required String oldPassword,
      required String newPassword}) async {
    try {
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: oldPassword);
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);
      _showErrorMessage('Password changed successfully');
    } catch (error) {
      _showErrorMessage('Failed to change password: $error');
    }
  }

  Future<void> _updatePassword() async {
    String currentPassword =
        currentPasswordcontroller.text.trim(); // Get the current password input
    String newPassword =
        newPasswordcontroller.text.trim(); // Get the new password input

    // Validate input
    if (currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your current password.')),
      );
      return;
    }

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a new password.')),
      );
      return;
    }

    try {
      // Get the current user from Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Check if the current password is correct
        bool isPasswordCorrect = await _checkCurrentPassword(currentPassword);

        if (isPasswordCorrect) {
          // Update the password in Firebase Authentication
          await user.updatePassword(newPassword);

          // Optionally, update the password in Firestore if you need to keep it there (not recommended for security)
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid) // Use the Firebase Authentication user ID
              .update(
                  {'password': newPassword}); // Again, be cautious about this

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password updated successfully')),
          );
        } else {
          // If the current password verification fails
          _showErrorMessage('Current password does not match.');
        }
      } else {
        // If no user is currently signed in, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is signed in')),
        );
      }
    } catch (e) {
      print('Error updating password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update password: $e')),
      );
    }
  }

// Check if the current password is correct (this method is unchanged)
  Future<bool> _checkCurrentPassword(String currentPassword) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showErrorMessage('No user is currently signed in.');
      return false;
    }

    // Create a credential using the user's email and the entered current password
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      // Re-authenticate the user
      await user.reauthenticateWithCredential(credential);
      return true; // Password is correct
    } catch (e) {
      _showErrorMessage('Current password does not match.');
      return false; // Password is incorrect
    }
  }

// Method to show error messages (this method is unchanged)
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      String fileName = 'profile_images/${_auth.currentUser!.uid}.jpg';
      try {
        UploadTask uploadTask =
            FirebaseStorage.instance.ref(fileName).putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        User? user = _auth.currentUser;
        if (user != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .update({'imageUrl': downloadUrl});
          setState(() {
            _imageUrl = downloadUrl; // Update the local state
          });
        }
      } catch (e) {
        _showErrorMessage('Error uploading image: $e');
      }
    }
  }

  Future<bool> _reauthenticateUser(String password) async {
    User? user = _auth.currentUser;
    if (user != null) {
      AuthCredential credential =
          EmailAuthProvider.credential(email: user.email!, password: password);
      try {
        await user.reauthenticateWithCredential(credential);
        return true;
      } catch (e) {
        _showErrorMessage('Re-authentication failed: $e');
        return false;
      }
    }
    return false;
  }

  Future<void> _updateEmail(String newEmail) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String password = ''; // Implement method to prompt for password
      bool reauthenticated = await _reauthenticateUser(password);
      if (reauthenticated) {
        try {
          await user.updateEmail(newEmail);
          await user.sendEmailVerification();
          await _updateUserData('email', newEmail);
          _showErrorMessage(
              'Verification email sent to $newEmail. Please verify to update your email.');
        } catch (e) {
          _showErrorMessage('Failed to update email: $e');
        }
      }
    }
  }

  // Show dialog for changing password
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordcontroller,
                    decoration: InputDecoration(
                      hintText: 'Current Password',
                      suffixIcon: IconButton(
                        icon: Icon(isCurrentPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            isCurrentPasswordVisible =
                                !isCurrentPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isCurrentPasswordVisible,
                  ),
                  TextField(
                    controller: newPasswordcontroller,
                    decoration: InputDecoration(
                      hintText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            isNewPasswordVisible = !isNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isNewPasswordVisible,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final currentPassword = currentPasswordcontroller.text;
                    final newPassword = newPasswordcontroller.text;

                    // Check for empty fields
                    if (currentPassword.isEmpty || newPassword.isEmpty) {
                      _showErrorMessage('Don\'t leave any field empty.');
                      return;
                    }

                    // Check if current password is correct
                    // if (currentPassword != _password) {
                    //   _showErrorMessage('Current password does not match.');
                    //   return;
                    // }

                    // Validate new password strength
                    if (!passwordRegex.hasMatch(newPassword)) {
                      _showErrorMessage(
                        'Password must be at least 8 characters, contain an uppercase letter, a lowercase letter, a number, and a special character.',
                      );
                      return;
                    }

                    // Proceed with updating the password
                    _updatePassword();
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Change'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(String field) {
    TextEditingController controller =
        field == 'name' ? _usernameController : _emailController;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(hintText: 'Enter new $field'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (field == 'name') {
                  _updateUserData('username', controller.text);
                } else if (field == 'email') {
                  _updateEmail(controller.text);
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: Moreoption(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(180),
          child: AppBar(
            backgroundColor: isDarkMode
                ? const Color(0xFF121212)
                : const Color.fromRGBO(207, 196, 196, 1),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _updateProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_imageUrl ??
                        'default_image_url'), // Add a default image URL if _imageUrl is null
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _username ?? 'Username',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  _email ?? 'Email',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            elevation: 0,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileDetail('Name', Icons.person, _username ?? ''),
                _buildProfileDetail('Email', Icons.email, _email ?? ''),
                _buildProfileDetail('Password', Icons.lock,
                    '********'), // Don't display the actual password
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () {
                        // Navigate to the login screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginForm()),
                        );
                      },
                    ),
                    Text(
                      "Logout",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddItemPage()),
            );
          },
          backgroundColor: Color.fromRGBO(31, 76, 107, 1),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 86,
          shape: CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavIcon(Icons.home, 'Home', HomePage()),
              _buildBottomNavIcon(Icons.message, 'Inbox', ChatListPage()),
              SizedBox(width: 40),
              _buildBottomNavIcon(Icons.person_2, 'Profile', ProfilePage()),
              _buildMoreButton(),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildProfileDetail(
      String title, IconData leadingIcon, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(leadingIcon, color: Colors.black54),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (title == 'Password') {
                _showChangePasswordDialog(); // Call the password change dialog
              } else {
                _showEditDialog(title.toLowerCase());
              }
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Column _buildBottomNavIcon(
      IconData icon, String label, Widget destinationPage) {
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
