import 'package:flutter/material.dart';
import 'package:justhome/additem.dart';
import 'package:justhome/chatlist.dart';
import 'package:justhome/drawer.dart';

import 'package:justhome/notification1.dart';
import 'package:justhome/productdetails.dart';
import 'package:justhome/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Just Home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Your home page
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> addedUsers = []; // Store added users

  int _selectedCategoryIndex = 0;
  List<Map<String, dynamic>> _properties = [];

  String? _username;
  String? _imageUrl;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchPropertyData('House');
    _userId = _auth.currentUser?.uid;
    print('Current User ID: $_userId');
    // Load added users from Firestore
    if (_userId != null) {
      _loadAddedUsers();
    } // Fetch default properties
  }

  void _loadAddedUsers() async {
    // Load the list of added users from Firestore
    var doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('friends')
        .get();
    setState(() {
      addedUsers = doc.docs
          .map((friend) => {
                'id': friend.id,
                'username': friend['username'],
              })
          .toList();
    });
  }

  void _addFriend(String userId, String username, String userImage) async {
    // Add user to the addedUsers list and save to Firestore
    setState(() {
      addedUsers.add({
        'id': userId,
        'username': username,
        'imageUrl': userImage, // Add userImage to the addedUsers list
      });
    });

    // Save to Firestore
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('friends')
        .doc(userId)
        .set({
      'id': userId,
      'username': username,
      'imageUrl': userImage, // Save the user image URL as well
    });

    // Show a confirmation message or snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$username added to your friends!')),
    );
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc['username'];
        _imageUrl = userDoc['imageUrl'];
        _userId = userDoc['userId'];
      });
    }
  }

  Future<void> _fetchPropertyData(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('property')
          .where('category', isEqualTo: category) // Filter by category
          .get();

      List<Map<String, dynamic>> properties = [];

      for (var doc in snapshot.docs) {
        properties.add(doc.data() as Map<String, dynamic>);
      }

      setState(() {
        _properties =
            properties; // Update properties based on selected category
      });
    } catch (e) {
      print('Error fetching properties: $e');
    }
  }

  Future<void> _addFavorite({
    required String homeName,
    required String location,
    required double price,
    required String type,
    required String area,
    required String floor,
    required String bed,
    required String bath,
    required String username,
    required String userImage,
    required List<String> imageUrls,
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Check if the homeName already exists in the favorites
        QuerySnapshot snapshot = await _firestore
            .collection('favorites')
            .where('email', isEqualTo: user.email)
            .where('homeName', isEqualTo: homeName)
            .get();

        if (snapshot.docs.isEmpty) {
          // If homeName does not exist, add it to favorites
          await _firestore.collection('favorites').add({
            'email': user.email,
            'homeName': homeName,
            'location': location,
            'price': price,
            'type': type,
            'area': area,
            'floor': floor,
            'bed': bed,
            'bath': bath,
            'username': username,
            'userImage': userImage,
            'imageUrls': imageUrls,
            'timestamp': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added to favorites!')),
          );
        } else {
          // If homeName already exists, navigate to the next page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('It Already added in Favorites!')),
          );
        }
      } catch (e) {
        print('Error adding to favorites: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: isDarkMode
            ? const Color(0xFF121212) // Dark background
            : const Color.fromRGBO(207, 196, 196, 1), // Light background
        key: _scaffoldKey,
        drawer: Moreoption(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: _imageUrl != null
                            ? NetworkImage(_imageUrl!) // Load image from URL
                            : AssetImage('assets/images/default_profile.png')
                                as ImageProvider, // Default image
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _username ??
                            'Loading...', // Display username or loading text
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Spacer(),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Notification1()),
                              );
                            },
                            icon: Icon(
                              Icons.notifications,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          );
                        }

                        // Count notifications not seen by the current user
                        int notificationCount = snapshot.data!.docs
                            .where((doc) =>
                                doc['userId'] !=
                                    FirebaseAuth.instance.currentUser!.uid &&
                                !(doc['seen'] ??
                                    false)) // Only count unseen notifications
                            .length;

                        return IconButton(
                          onPressed: () async {
                            // Mark notifications as seen only for the current user
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .where('userId',
                                    isNotEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid)
                                .get()
                                .then((snapshot) {
                              for (var doc in snapshot.docs) {
                                // Update only if the field exists
                                if (doc.exists &&
                                    doc.data().containsKey('seen')) {
                                  doc.reference
                                      .update({'seen': true}); // Mark as seen
                                }
                              }
                            });

                            // Navigate to the Notification1 page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Notification1()),
                            );
                          },
                          icon: Stack(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              if (notificationCount > 0)
                                Positioned(
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                    child: Text(
                                      '$notificationCount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search Here',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryButton('House', 0),
                  _buildCategoryButton('Apartment', 1),
                  _buildCategoryButton('Land', 2),
                ],
              ),
              Container(
                height: 250,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _properties.length,
                  itemBuilder: (context, index) {
                    final property = _properties[index];
                    return _buildCard(
                      category: property['category'],
                      homeName: property['homename'],
                      location: property['location'],
                      imageUrls: List<String>.from(
                          property['imageUrls']), // Display the first image
                      price: property['price'],
                      type: property['forWhat'],
                      area: property['area'], // Pass area
                      floor: property['floor'], // Pass floor
                      bed: property['bed'], // Pass bed
                      bath: property['bath'], // Pass bath
                      username: property['username'], // Pass username
                      userImage: property['userImage'],

                      userId: property['userId'],
                      createdAt: property[
                          'createdAt'], // Pass user image URL // Rent or Sell
                      isDarkMode:
                          Theme.of(context).brightness == Brightness.dark,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 8.0, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black),
                    )
                  ],
                ),
              ),
              // Remove fixed height for the vertical list
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 250, // You can adjust this height as needed
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: _properties.length,
                    itemBuilder: (context, index) {
                      final property = _properties[index];
                      return _buildVerticalCard(
                        context: context, // Pass the context here
                        homeName: property['homename'],
                        location: property['location'],
                        category: property['category'],
                        imageUrls: List<String>.from(
                            property['imageUrls']), // Display the first image
                        price: property['price'],
                        type: property['forWhat'],
                        area: property['area'], // Pass area
                        floor: property['floor'], // Pass floor
                        bed: property['bed'], // Pass bed
                        bath: property['bath'], // Pass bath
                        username: property['username'], // Pass username
                        userImage: property['userImage'],
                        userId: property['userId'],

                        createdAt: property['createdAt'], // Pass createdAt
                        isDarkMode:
                            Theme.of(context).brightness == Brightness.dark,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddItemPage()),
            );
          },
          backgroundColor: Color.fromRGBO(31, 76, 107, 1),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          height: 86,
          shape: CircularNotchedRectangle(), // Adds the notch for FAB
          notchMargin: 8.0, // Margin for the notch
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavIcon(Icons.home, 'Home', HomePage()),
              _buildBottomNavIcon(Icons.message, 'Inbox', ChatListPage()),
              SizedBox(width: 40), // Space for FAB
              _buildBottomNavIcon(Icons.person_2, 'Profile', ProfilePage()),
              _buildMoreButton(),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton _buildCategoryButton(String text, int index) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedCategoryIndex = index;
          // Call fetch method with appropriate category
          if (text == 'House') {
            _fetchPropertyData('House');
          } else if (text == 'Apartment') {
            _fetchPropertyData('Apartment');
          } else if (text == 'Land') {
            _fetchPropertyData('Land');
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedCategoryIndex == index
            ? Color.fromRGBO(31, 76, 107, 1)
            : Colors.white,
        foregroundColor:
            _selectedCategoryIndex == index ? Colors.white : Colors.black,
        minimumSize: const Size(120, 35),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  GestureDetector _buildCard({
    required String homeName,
    required String location,
    required String category,
    required List<String> imageUrls,
    required double price,
    required String type,
    required String area,
    required String floor,
    required String bed,
    required String bath,
    required String username,
    required String userImage,
    required String userId,
    required String createdAt,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to the details page when the card is clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchAppbarPage(
              homeName: homeName,
              location: location,
              category: category,
              imageUrls: imageUrls,
              price: price,
              type: type,
              area: area,
              floor: floor,
              bed: bed,
              bath: bath,
              username: username,
              userImage: userImage,
              userId: userId,
              createdAt: createdAt,
            ), // Replace with your target page
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 140,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageUrls[0],
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 120,
                              color: Colors.grey[300],
                              child: Center(
                                  child: Icon(Icons.error)), // Error icon
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 82,
                        child: IconButton(
                          onPressed: () async {
                            await _addFavorite(
                                homeName: homeName,
                                location: location,
                                price: price,
                                type: type,
                                area: area,
                                floor: floor,
                                bed: bed,
                                bath: bath,
                                username: username,
                                userImage: userImage,
                                imageUrls:
                                    imageUrls); // Pass all relevant details
                          },
                          icon:
                              Icon(Icons.favorite, color: Colors.red, size: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        homeName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle overflow
                      ),
                      SizedBox(height: 2),
                      Text(
                        location,
                        style: TextStyle(
                          color: Color.fromARGB(255, 197, 196, 191),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Rs.${price.toString()}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      type,
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildVerticalCard({
    required String homeName,
    required String location,
    required String category,
    required List<String> imageUrls,
    required double price,
    required String type,
    required String area,
    required String floor,
    required String bed,
    required String bath,
    required String username,
    required String userImage,
    required String userId,
    required String createdAt,
    required bool isDarkMode,
    required BuildContext context, // Added context parameter
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to the SearchAppbarPage when the card is clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchAppbarPage(
              homeName: homeName,
              location: location,
              category: category,
              imageUrls: imageUrls,
              price: price,
              type: type,
              area: area,
              floor: floor,
              bed: bed,
              bath: bath,
              username: username,
              userImage: userImage,
              userId: userId,
              createdAt: createdAt,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          height: 120,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrls[0],
                    height: double.infinity,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: double.infinity,
                        width: 100,
                        color: Colors.grey, // Placeholder color
                        child: Center(child: Icon(Icons.error)), // Error icon
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(homeName,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black)),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            _addFavorite(
                              homeName: homeName,
                              location: location,
                              price: price,
                              type: type,
                              area: area,
                              floor: floor,
                              bed: bed,
                              bath: bath,
                              username: username,
                              userImage: userImage,
                              imageUrls: imageUrls,
                            ); // Pass all relevant details
                          },
                          icon: Icon(Icons.favorite, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(location,
                        style: TextStyle(
                            color: Color.fromARGB(255, 197, 196, 191),
                            fontSize: 14)),
                    const SizedBox(height: 0),
                    Row(
                      children: [
                        Text('Rs.${price.toString()}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Spacer(flex: 2),
                        Text(type), // Display type (Rent/Sell)
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            // Navigate to the desired page
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
