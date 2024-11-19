import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
      home: AddItemPage(), // Your home page
    );
  }
}

class AddItemPage extends StatefulWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void initState() {
    super.initState();
    _fetchUserData();
  }

  String? _username;
  String? _imageUrl;

  String? _email;
  String? _userId;

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc['username'];
        _imageUrl = userDoc['imageUrl'];
        _email = userDoc['email'];
        _userId = userDoc['userId'];
      });
    }
  }

  // Track selected button indices
  int _selectedCategoryIndex = -1;
  int _selectedForIndex = -1;

  // Image variables
  List<XFile?> _selectedImages = [];

  // Text controllers for text fields
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _bedController = TextEditingController();
  final TextEditingController _bathController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _homenameController = TextEditingController();

  String formattedDate = DateFormat('d MMM').format(DateTime.now());
  // Method to pick images
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(pickedFile);
      });
    }
  }

  // Upload images to Firebase Storage and return the URLs
  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (var image in _selectedImages) {
      if (image != null) {
        // Create a unique file name
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        // Upload the image to Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child('property_images/$fileName');
        UploadTask uploadTask = storageRef.putFile(File(image.path));
        TaskSnapshot snapshot = await uploadTask;
        // Get the download URL and add it to the list
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    }
    return imageUrls;
  }

  bool _validateFields() {
    if (_locationController.text.isEmpty ||
        _selectedCategoryIndex == -1 ||
        _selectedImages.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedForIndex == -1) {
      return false;
    }
    return true;
  }

  // Method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitData() async {
    if (_validateFields()) {
      try {
        // Upload images to Firebase Storage and get their URLs
        List<String> imageUrls = await _uploadImages();

        // Submit the data to Firestore
        await _firestore.collection('property').add({
          'homename': _homenameController.text,
          'location': _locationController.text,
          'category': _selectedCategoryIndex == 0
              ? 'House'
              : _selectedCategoryIndex == 1
                  ? 'Apartment'
                  : 'Land', // Determine the category based on index
          'imageUrls': imageUrls, // Store image URLs
          'price': double.tryParse(_priceController.text) ?? 0,
          'forWhat': _selectedForIndex == 0 ? 'Rent' : 'Sell',
          'area': _areaController.text,
          'floor': _floorController.text,
          'bed': _bedController.text,
          'bath': _bathController.text,
          'username': _username,
          'userImage': _imageUrl,
          'email': _email,
          'userId': _userId,
          'createdAt': formattedDate,
        });
        // Now add the data to another collection, e.g., 'notifications'
        await _firestore.collection('notifications').add({
          'homename': _homenameController.text,
          'location': _locationController.text,
          'category': _selectedCategoryIndex == 0
              ? 'House'
              : _selectedCategoryIndex == 1
                  ? 'Apartment'
                  : 'Land', // Determine the category based on index
          'imageUrls': imageUrls, // Store image URLs
          'price': double.tryParse(_priceController.text) ?? 0,
          'forWhat': _selectedForIndex == 0 ? 'Rent' : 'Sell',
          'area': _areaController.text,
          'floor': _floorController.text,
          'bed': _bedController.text,
          'bath': _bathController.text,
          'username': _username,
          'userImage': _imageUrl,
          'email': _email,
          'userId': _userId,
          'seen': false,
          'createdAt': formattedDate,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property added successfully!')),
        );

        // Clear form after submission
        setState(() {
          _locationController.clear();
          _priceController.clear();
          _selectedCategoryIndex = -1;
          _selectedForIndex = -1;
          _selectedImages.clear();
        });
      } catch (error) {
        _showErrorDialog('Failed to add property: $error');
      }
    } else {
      // Show an error if the fields are not validated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(207, 196, 196, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(207, 196, 196, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Add Item',
          style: TextStyle(
            color: Color.fromRGBO(31, 76, 107, 1),
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Hi JustHome, Fill detail of your',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'real estate to sell/rent',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(31, 76, 107, 1),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Home Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _homenameController,
                decoration: InputDecoration(
                  hintText: 'Tintiled Home',
                  prefixIcon: const Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(31, 76, 107, 1),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Property category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryIndex = 0;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategoryIndex == 0
                          ? const Color.fromRGBO(31, 76, 107, 1)
                          : Colors.white,
                      foregroundColor: _selectedCategoryIndex == 0
                          ? Colors.white
                          : Colors.black,
                      minimumSize: const Size(80, 50),
                    ),
                    child: const Text('House'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryIndex = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategoryIndex == 1
                          ? const Color.fromRGBO(31, 76, 107, 1)
                          : Colors.white,
                      foregroundColor: _selectedCategoryIndex == 1
                          ? Colors.white
                          : Colors.black,
                      minimumSize: const Size(80, 50),
                    ),
                    child: const Text('Apartment'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryIndex = 2;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategoryIndex == 2
                          ? const Color.fromRGBO(31, 76, 107, 1)
                          : Colors.white,
                      foregroundColor: _selectedCategoryIndex == 2
                          ? Colors.white
                          : Colors.black,
                      minimumSize: const Size(80, 50),
                    ),
                    child: const Text('Land'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Location',
                  prefixIcon: const Icon(Icons.location_pin),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(31, 76, 107, 1),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _selectedImages.length > index
                        ? Stack(
                            children: [
                              Image.file(
                                File(_selectedImages[index]!.path),
                                width: 80,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: -10,
                                top: -15,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, // Make it circular
                                    color: Colors.white
                                        .withOpacity(0.5), // Background color
                                    boxShadow: [
                                      // Optional shadow for depth
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.01),
                                        blurRadius: 4.0,
                                        spreadRadius: 1.0,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        // Remove the image at the current index
                                        _selectedImages.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_a_photo),
                            onPressed: _pickImage,
                          ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Text(
                'Price',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  hintText: 'Price',
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(31, 76, 107, 1),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Area',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _areaController,
                decoration: InputDecoration(
                  hintText: 'Area in SQ.ft',
                  prefixIcon: const Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(31, 76, 107, 1),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'No. Of Things',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _floorController,
                      decoration: InputDecoration(
                        hintText: 'Floor',
                        prefixIcon: const Icon(Icons.stairs),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(31, 76, 107, 1),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _bathController,
                      decoration: InputDecoration(
                        hintText: 'Bath',
                        prefixIcon: const Icon(Icons.bathroom),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(31, 76, 107, 1),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _bedController,
                      decoration: InputDecoration(
                        hintText: 'BedRooms',
                        prefixIcon: const Icon(Icons.bed),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(31, 76, 107, 1),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'For What',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedForIndex = 0;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedForIndex == 0
                          ? const Color.fromRGBO(31, 76, 107, 1)
                          : Colors.white,
                      foregroundColor:
                          _selectedForIndex == 0 ? Colors.white : Colors.black,
                      minimumSize: const Size(80, 50),
                    ),
                    child: const Text('Rent'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedForIndex = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedForIndex == 1
                          ? const Color.fromRGBO(31, 76, 107, 1)
                          : Colors.white,
                      foregroundColor:
                          _selectedForIndex == 1 ? Colors.white : Colors.black,
                      minimumSize: const Size(80, 50),
                    ),
                    child: const Text('Sell'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    backgroundColor: const Color.fromRGBO(31, 76, 107, 1),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
