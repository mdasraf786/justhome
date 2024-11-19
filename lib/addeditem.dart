import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:justhome/additem.dart';
import 'package:justhome/chatlist.dart';
import 'package:justhome/drawer.dart';
import 'package:justhome/editproperty.dart';
import 'package:justhome/homepage.dart';
import 'package:justhome/notification.dart';
import 'package:justhome/productdetails.dart';
import 'package:justhome/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Properties',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AddedItems(),
    );
  }
}

class AddedItems extends StatefulWidget {
  const AddedItems({super.key});

  @override
  State<AddedItems> createState() => _AddedItemsState();
}

class _AddedItemsState extends State<AddedItems> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> addedUsers = [];
  List<Map<String, dynamic>> _properties = [];

  @override
  void initState() {
    super.initState();
    User? user = _auth.currentUser;
    if (user != null) {
      _fetchFavoriteProperties();
    } else {
      print('User is not logged in.');
    }
  }

  Future<void> _fetchFavoriteProperties() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('property')
            .where('email', isEqualTo: user.email)
            .get();

        if (snapshot.docs.isEmpty) {
          print('No properties found for this user.');
        } else {
          List<Map<String, dynamic>> properties = [];
          for (var doc in snapshot.docs) {
            var data = doc.data() as Map<String, dynamic>;
            properties.add({
              'homename': data['homename'] ?? 'Unknown Home',
              'location': data['location'] ?? 'Unknown Location',
              'category': data['category'] ?? 'Unknown Category',
              'price': data['price'] ?? 0.0,
              'type': data['forWhat'] ?? 'Unknown Type',
              'area': data['area'] ?? 'N/A',
              'floor': data['floor'] ?? 'N/A',
              'bed': data['bed'] ?? 'N/A',
              'bath': data['bath'] ?? 'N/A',
              'username': data['username'] ?? 'Anonymous',
              'userImage': data['userImage'] ?? 'default_user_image_url',
              'imageUrls': List<String>.from(data['imageUrls'] ?? []),
              'createdAt': data['createdAt'] ?? '',
              'userId': data['userId'] ?? 'unknown_user_id',
            });
          }

          setState(() {
            _properties = properties;
          });
        }
      } catch (e) {
        print('Error fetching properties: $e');
      }
    }
  }

  Future<void> _deletePropertyByUsername(String username) async {
    print('Deleting document for username: $username');
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('property')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No document found for username: $username');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No property found for this username.')),
          );
        }
        return;
      }

      DocumentSnapshot doc = querySnapshot.docs.first;

      await FirebaseFirestore.instance
          .collection('property')
          .doc(doc.id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Property deleted successfully!')),
        );
      }

      await _fetchFavoriteProperties();
    } catch (e) {
      print('Error deleting property: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete property.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(207, 196, 196, 1),
      appBar: AppBar(
        title: Center(child: Text('Added Items')),
      ),
      key: _scaffoldKey,
      drawer: Moreoption(),
      body: _properties.isEmpty
          ? Center(child: Text('No Property Added By You Till Now'))
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.63,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _properties.length,
                itemBuilder: (context, index) {
                  final property = _properties[index];
                  return _buildCard(
                    homeName: property['homename'] as String,
                    location: property['location'] as String,
                    category: property['category'] as String,
                    imageUrls: List<String>.from(property['imageUrls'] ?? []),
                    price: property['price'] as double,
                    type: property['type'] as String,
                    area: property['area'] as String,
                    floor: property['floor'] as String,
                    bed: property['bed'] as String,
                    bath: property['bath'] as String,
                    username: property['username'] as String,
                    userId: property['userId'] as String,
                    userImage: property['userImage'] as String,
                    createdAt: property['createdAt'] as String,
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
  }) {
    return GestureDetector(
      onTap: () {
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
              userId: userId,
              userImage: userImage,
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
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
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
                          imageUrls.isNotEmpty
                              ? imageUrls[0]
                              : 'default_image_url',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Center(child: Icon(Icons.error)),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 82,
                        child: IconButton(
                          onPressed: () {
                            // Add favorite functionality here
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
                        overflow: TextOverflow.ellipsis,
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
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Editproperty(
                                homeName: homeName,
                                location: location,
                                imageUrls: imageUrls,
                                price: price,
                                type: type,
                                category: category,
                                area: area,
                                floor: floor,
                                bed: bed,
                                bath: bath,
                                username: username,
                                userImage: userImage,
                                createdAt: createdAt,
                              ),
                            ),
                          );
                        },
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text('Edit'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: MaterialButton(
                        onPressed: () {
                          _deletePropertyByUsername(username);
                        },
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('Delet'),
                      ),
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

  GestureDetector _buildBottomNavIcon(
      IconData icon, String label, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(label),
        ],
      ),
    );
  }

  GestureDetector _buildMoreButton() {
    return GestureDetector(
      onTap: () {
        _scaffoldKey.currentState?.openDrawer();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.more_horiz),
          Text('More'),
        ],
      ),
    );
  }
}
