import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:justhome/additem.dart';
import 'package:justhome/drawer.dart';
import 'package:justhome/homepage.dart';
import 'package:justhome/notification.dart';
import 'package:justhome/productdetails.dart'; // Ensure this is your ProductDetails page
import 'package:justhome/profile.dart';

class Favourite extends StatefulWidget {
  const Favourite({super.key});

  @override
  State<Favourite> createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> addedUsers = []; // Store added users

  List<Map<String, dynamic>> _properties = []; // Initialize as an empty list

  @override
  void initState() {
    super.initState();
    _fetchFavoriteProperties(); // Fetch favorite properties on init
  }

  Future<void> _fetchFavoriteProperties() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('favorites')
            .where('email', isEqualTo: user.email) // Filter by user's email
            .get();

        List<Map<String, dynamic>> properties = [];
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          properties.add({
            'homename': data['homeName'] ?? 'Unknown Home',
            'location': data['location'] ?? 'Unknown Location',
            'price': data['price'] ?? 0.0,
            'type': data['type'] ?? 'Unknown Type',
            'area': data['area'] ?? 'N/A',
            'floor': data['floor'] ?? 'N/A',
            'bed': data['bed'] ?? 'N/A',
            'bath': data['bath'] ?? 'N/A',
            'username': data['username'] ?? 'Anonymous',
            'userImage': data['userImage'] ??
                'default_user_image_url', // Use a default image URL if needed
            'imageUrls': List<String>.from(
                data['imageUrls'] ?? []), // Ensure this is a list
            'createdAt': data['createdAt'] ?? '',
          });
        }

        setState(() {
          _properties = properties; // Update the state with fetched properties
        });
      } catch (e) {
        print('Error fetching favorites: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(207, 196, 196, 1),
      appBar: AppBar(
        //backgroundColor: const Color.fromRGBO(207, 196, 196, 1),
        title: Center(child: Text('Favourite Items')),
      ),
      key: _scaffoldKey,
      drawer: Moreoption(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _properties.length,
          itemBuilder: (context, index) {
            final property = _properties[index];
            return _buildVerticalCard(
              context: context,
              homeName: property['homename']?.toString() ?? 'Unknown Home',
              location: property['location']?.toString() ?? 'Unknown Location',
              category: property['category']?.toString() ?? 'Unknown Category',
              imageUrls: List<String>.from(property['imageUrls'] ?? []),
              price: (property['price'] as double?) ?? 0.0,
              type: property['type']?.toString() ?? 'Unknown Type',
              area: property['area']?.toString() ?? 'N/A',
              floor: property['floor']?.toString() ?? 'N/A',
              bed: property['bed']?.toString() ?? 'N/A',
              bath: property['bath']?.toString() ?? 'N/A',
              username: property['username']?.toString() ?? 'Anonymous',
              userImage:
                  property['userImage']?.toString() ?? 'default_user_image_url',
              userId: property['userId']?.toString() ?? 'Unlnowm',
              createdAt: property['createdAt']?.toString() ?? '',
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
            );
          },
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
            _buildBottomNavIcon(
                Icons.message, 'Inbox', NotificationPage(users: addedUsers)),
            SizedBox(width: 40), // Space for FAB
            _buildBottomNavIcon(Icons.person_2, 'Profile', ProfilePage()),
            _buildMoreButton(),
          ],
        ),
      ),
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
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchAppbarPage(
              // Make sure this matches your actual page class
              homeName: homeName,
              category: category,
              location: location,
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
                    imageUrls.isNotEmpty
                        ? imageUrls[0]
                        : 'default_image_url', // Handle empty URLs
                    height: double.infinity,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: double.infinity,
                        width: 100,
                        color: Colors.grey,
                        child: Center(child: Icon(Icons.error)),
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
                        Text(type),
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
}
