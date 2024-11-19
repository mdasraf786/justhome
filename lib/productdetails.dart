import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:justhome/additem.dart';
import 'package:justhome/card.dart';
import 'package:justhome/chatlist.dart';
import 'package:justhome/chatpage.dart';
import 'package:justhome/chattingpage.dart';
import 'package:justhome/drawer.dart';
import 'package:justhome/homepage.dart';
import 'package:justhome/images.dart';
import 'package:justhome/inbox.dart';
import 'package:justhome/notification.dart';
import 'package:justhome/profile.dart';

class SearchAppbarPage extends StatefulWidget {
  final String homeName;
  final String location;
  final String category;
  final List<String> imageUrls;
  final double price;
  final String type;
  final String area;
  final String floor;
  final String bed;
  final String bath;
  final String username;
  final String userImage;
  final String userId;
  final String createdAt; // Declare createdAt

  // Constructor to receive data
  SearchAppbarPage({
    Key? key,
    required this.homeName,
    required this.category,
    required this.location,
    required this.imageUrls,
    required this.price,
    required this.type,
    required this.area,
    required this.floor,
    required this.bed,
    required this.bath,
    required this.username,
    required this.userImage,
    required this.userId,
    required this.createdAt, // Assign createdAt here
  }) : super(key: key);

  @override
  State<SearchAppbarPage> createState() => _SearchAppbarPageState();
}

class _SearchAppbarPageState extends State<SearchAppbarPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _properties = [];
  List<Map<String, dynamic>> addedUsers = []; // Store added users

  String? _username;

  String? _imageUrl;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    int bedCount =
        int.tryParse(widget.bed) ?? -1; // Convert to int, default to -1
    int floorCount =
        int.tryParse(widget.floor) ?? -1; // Convert to int, default to -1

    if (bedCount == 0) {
      _fetchPropertyData('Land');
    }

    if (floorCount == 0) {
      _fetchPropertyData('Apartment');
    }

    if (bedCount > 0 && floorCount > 0) {
      _fetchPropertyData(
          'House'); // Only fetch House if both are greater than 0
    }
    // Fetch default properties
    currentUserId = _auth.currentUser?.uid;
    print('Current User ID: $currentUserId');
    // Load added users from Firestore
    if (currentUserId != null) {
      _loadAddedUsers();
    }
  }

  void _loadAddedUsers() async {
    // Load the list of added users from Firestore
    var doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .get();
    setState(() {
      addedUsers = doc.docs
          .map((friend) => {
                'id': friend.id,
                'username': friend['username'],
                'userImage': friend['userImage']
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
        .doc(currentUserId)
        .collection('friends')
        .doc(userId)
        .set({
      'id': userId,
      'username': username,
      'imageUrl': userImage, // Save the user image URL as well
    });

    // Show a confirmation message or snackbar
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('$username added to your friends!')),
    // );
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc['username'];
        _imageUrl = userDoc['imageUrl'];
        currentUserId = userDoc['userId'];
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> imageUrlss = [house, hall, kitchen, bedroom];
// Call to super constructor
  @override
  Widget build(BuildContext context) {
    // String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(createdAt);
    // Parse the number of bedrooms (assuming `bed` is a String)
    int numberOfBedrooms = int.tryParse(widget.bed) ?? 0;

    // Determine the kitchen value based on bedrooms
    int kitchenCount = numberOfBedrooms == 0 ? 0 : 1; // Adjust this as needed

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 235, 234, 224),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 235, 234, 224),
        title: SearchBar(),
      ),
      drawer: Moreoption(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 4,
              color: Colors.white, // Set background color to white
              shape: RoundedRectangleBorder(
                  //borderRadius: BorderRadius.circular(15), // Add border radius
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carousel for images with increased height
                  // Carousel for images with increased height
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 350, // Increased height of the images
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: widget.imageUrls.asMap().entries.map((entry) {
                      int index = entry.key;
                      String imageUrl = entry.value;

                      return Builder(
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 15.0,
                                bottom: 15), // Add top padding to the image
                            child: Stack(
                              children: [
                                Container(
                                  // Adjust the width of the image here
                                  width: MediaQuery.of(context).size.width *
                                      0.9, // Image width is now 90% of screen width
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    // Add border radius to container
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          imageUrl), // Use NetworkImage for URLs
                                      fit: BoxFit
                                          .cover, // Ensure the images cover the container
                                    ),
                                  ),
                                ),
                                // Show favorite icon on the first image only
                                if (index == 0)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: Icon(Icons.favorite,
                                          color: Colors.red, size: 30),
                                      onPressed: () {
                                        // Handle favorite button press
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),

                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.homeName,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rs.${widget.price.toString()}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '${widget.area} Sq.ft. Residental Plot for sal...',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8),
                    child: Text(
                      'Area: ${widget.area} SQ.FT',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BedRooms : ${widget.bed}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'BathRooms : ${widget.bath}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Check if the username and _username are the same
                            if (widget.username == _username) {
                              // Show a message or alert

                              // Alternatively, use a SnackBar or AlertDialog to display the message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("You can't text yourself"),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            } else {
                              print(
                                  "Navigating to ChatPage with User Image: ${widget.userImage}");
                              _addFriend(widget.userId, widget.username,
                                  widget.userImage);

                              // Navigate to the desired page if the usernames are different
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    username: widget.username,
                                    userImage: widget.userImage,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Connect',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Color.fromRGBO(31, 76, 107, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                        left: 8.0, right: 30, top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kitchen : $kitchenCount',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Floor : ${widget.floor}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.createdAt,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on),
                        Text(
                          widget.location,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        // Text(
                        //   'Floor : 2',
                        //   style: TextStyle(
                        //       fontSize: 15, fontWeight: FontWeight.bold),
                        // ),
                        // Text(
                        //   '15 Aug',
                        //   style: TextStyle(
                        //       fontSize: 15, fontWeight: FontWeight.bold),
                        // )
                      ],
                    ),
                  ),
                  // Description below the carousel
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 0, right: 8, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.homeName,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  // Text(
                  //   '15 Aug',
                  //   style: TextStyle(
                  //       fontSize: 15, fontWeight: FontWeight.bold),
                  // )
                ],
              ),
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
                    homeName: property['homename'],
                    location: property['location'],
                    category: property['category'],
                    userId: property['userId'],
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
                    createdAt: property[
                        'createdAt'], // Pass user image URL // Rent or Sell
                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  );
                },
              ),
            ),
            Divider(),
            Container(
              height: 250,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _properties.length,
                itemBuilder: (context, index) {
                  final property = _properties[index];
                  return _buildCard(
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
                    userId: property['userId'],
                    userImage: property['userImage'],
                    createdAt: property[
                        'createdAt'], // Pass user image URL // Rent or Sell
                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  );
                },
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
            _buildBottomNavIcon(context, Icons.home, 'Home', HomePage()),
            _buildBottomNavIcon(
                context, Icons.message, 'Inbox', ChatListPage()),
            SizedBox(width: 40), // Space for FAB
            _buildBottomNavIcon(
                context, Icons.person_2, 'Profile', ProfilePage()),
            _buildMoreButton(),
          ],
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   height: 90,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       Column(
      //         children: [
      //           IconButton(
      //               onPressed: () {},
      //               icon: Icon(
      //                 Icons.home,
      //                 color: Colors.black,
      //               )),
      //           Text(
      //             'Home',
      //             style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      //           )
      //         ],
      //       ),
      //       Column(
      //         children: [
      //           IconButton(
      //               onPressed: () {},
      //               icon: Icon(
      //                 Icons.message,
      //                 color: Colors.black,
      //               )),
      //           Text(
      //             'Inbox',
      //             style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      //           )
      //         ],
      //       ),
      //       Container(
      //         decoration: BoxDecoration(
      //           shape: BoxShape.circle,
      //           color: Colors.black,
      //         ),
      //         child: Column(
      //           children: [
      //             SizedBox(
      //               height: 63,
      //               child: Center(
      //                 child: IconButton(
      //                     onPressed: () {},
      //                     icon: Icon(
      //                       Icons.add,
      //                       color: Colors.white,
      //                     )),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       Column(
      //         children: [
      //           IconButton(
      //               onPressed: () {},
      //               icon: Icon(
      //                 Icons.person_2,
      //                 color: Colors.black,
      //               )),
      //           Text(
      //             'Profile',
      //             style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      //           )
      //         ],
      //       ),
      //       Column(
      //         children: [
      //           IconButton(
      //               onPressed: () {
      //                 if (_scaffoldKey.currentState != null) {
      //                   _scaffoldKey.currentState?.openDrawer();
      //                 }
      //               },
      //               icon: Icon(
      //                 Icons.more,
      //                 color: Colors.black,
      //               )),
      //           Text(
      //             'More',
      //             style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      //           )
      //         ],
      //       )
      //     ],
      //   ),
      // ),
    );
  }

  Column _buildBottomNavIcon(BuildContext context, IconData icon, String label,
      Widget destinationPage) {
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
    required String createdAt,
    required String userId,
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
                          onPressed: () {
                            // Add to favorites logic here
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

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar>
    with SingleTickerProviderStateMixin {
  bool _isActive = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!_isActive)
          Padding(
            padding: const EdgeInsets.only(left: 38.0),
            child: Text("Property Details Page",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(31, 76, 107, 1),
                )),
          ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _isActive
                  ? Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0)),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: 'Search for something',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isActive = false;
                                  });
                                },
                                icon: const Icon(Icons.close))),
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          _isActive = true;
                        });
                      },
                      icon: const Icon(
                        Icons.search,
                        size: 33,
                      )),
            ),
          ),
        ),
      ],
    );
  }
}
