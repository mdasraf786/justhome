import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Editproperty extends StatefulWidget {
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
  final String createdAt; // Declare createdAt

  // Constructor to receive data
  Editproperty({
    Key? key,
    required this.homeName,
    required this.location,
    required this.category,
    required this.imageUrls,
    required this.price,
    required this.type,
    required this.area,
    required this.floor,
    required this.bed,
    required this.bath,
    required this.username,
    required this.userImage,
    required this.createdAt, // Assign createdAt here
  }) : super(key: key);

  @override
  State<Editproperty> createState() => _EditpropertyState();
}

class _EditpropertyState extends State<Editproperty> {
  String? _originalHomename;
  String? _originalLocation;
  double? _originalPrice;
  String? _originalArea;
  String? _originalFloor;
  String? _originalBath;
  String? _originalBed;
  String? _originalCategory;
  String? _originalForWhat;

  // Original image URLs
  List<String> _originalImageUrls = [];
  // Currently selected images (after user changes)
  //List<XFile?> _selectedImages = List.filled(4, null);

  List<File?> _selectedImages = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initState() {
    super.initState();
    _fetchUserData();
    _fetchPropertyData(widget.username);
    _originalImageUrls = List.from(widget.imageUrls);
    _selectedImages = List.generate(widget.imageUrls.length, (index) => null);
    _homenameController.text = widget.homeName;

    _locationController.text = widget.location;
    _priceController.text = widget.price.toString();
    _areaController.text = widget.area.toString();
    _floorController.text = widget.floor.toString();
    _bathController.text = widget.bath.toString();
    _bedController.text = widget.bed.toString();

    // Store original values
    _originalHomename = widget.homeName;
    _originalLocation = widget.location;
    _originalPrice = widget.price;
    _originalArea = widget.area;
    _originalFloor = widget.floor;
    _originalBath = widget.bath;
    _originalBed = widget.bed;
    _originalCategory = widget.category;
    _originalForWhat = widget.type;

    // Set the selected category based on existing data
    String existingCategory = widget.category;
    _selectedCategoryIndex = existingCategory == 'House'
        ? 0
        : existingCategory == 'Apartment'
            ? 1
            : existingCategory == 'Land'
                ? 2
                : -1;

    // Set the selected "for what" index based on existing data
    String existingForWhat = widget.type;
    _selectedForIndex =
        existingForWhat == 'Rent' ? 0 : 1; // 0 for Rent, 1 for Sell
  }

  @override
  void dispose() {
    _homenameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _floorController.dispose();
    _bathController.dispose();
    _bedController.dispose();

    super.dispose();
  }

  Future<void> _checkDocumentExists() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('property')
        .doc(widget.username)
        .get();

    if (!doc.exists) {
      print('Document does not exist!');
      // Handle the absence of the document accordingly
    } else {
      print('Document exists, proceeding with update.');
      await _updatePropertyDetails();
    }
  }

// Function to update property details
  Future<void> _updatePropertyDetails() async {
    print('Updating document with username: ${widget.username}');
    try {
      // Query to find the document by username
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('property')
          .where('username', isEqualTo: widget.username)
          .get();

      // Check if any documents were found
      if (querySnapshot.docs.isEmpty) {
        print('No document found for username: ${widget.username}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document not found.')),
        );
        return; // Exit early if no document exists
      }

      // Assuming there is only one document per username
      DocumentSnapshot doc = querySnapshot.docs.first;

      // Upload images and get the new URLs
      List<String> newImageUrls = await _uploadImages();

      // Create a map for the updated property data
      Map<String, dynamic> updatedData = {
        'homename': _homenameController.text != _originalHomename
            ? _homenameController.text
            : _originalHomename,
        'location': _locationController.text != _originalLocation
            ? _locationController.text
            : _originalLocation,
        'price': _priceController.text != _originalPrice.toString()
            ? double.tryParse(_priceController.text) ?? _originalPrice
            : _originalPrice,
        'area': _areaController.text != _originalArea
            ? _areaController.text
            : _originalArea,
        'floor': _floorController.text != _originalFloor
            ? _floorController.text
            : _originalFloor,
        'bath': _bathController.text != _originalBath
            ? _bathController.text
            : _originalBath,
        'bed': _bedController.text != _originalBed
            ? _bedController.text
            : _originalBed,
        'category': _selectedCategoryIndex == 0
            ? 'House'
            : _selectedCategoryIndex == 1
                ? 'Apartment'
                : _selectedCategoryIndex == 2
                    ? 'Land'
                    : _originalCategory,
        'forWhat': _selectedForIndex == 0 ? 'Rent' : 'Sell',
        'imageUrls': newImageUrls.isNotEmpty
            ? newImageUrls // Use new image URLs if any are uploaded
            : doc['imageUrls'], // Keep existing URLs if none are uploaded
      };

      // Update the Firestore document using the document ID from the snapshot
      await FirebaseFirestore.instance
          .collection('property')
          .doc(doc.id) // Use the document ID obtained from the query
          .update(updatedData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property updated successfully!')),
      );
    } catch (e) {
      print('Error updating property: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update property.')),
      );
    }
  }

  String? _username;
  String? _imageUrl;

  String? _email;

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc['username'];
        _imageUrl = userDoc['imageUrl'];
        _email = userDoc['email'];
      });
    }
  }

  Future<void> _fetchPropertyData(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('property')
          .where('email', isEqualTo: _username) // Filter by category
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

  // Track selected button indices
  int _selectedCategoryIndex = -1;
  int _selectedForIndex = -1;

  // Image variables
  //List<XFile?> _selectedImages = [];
  List<Map<String, dynamic>> _properties = [];

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

  // Update the pickImage function
  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // Store the picked file in the selected images list
        _selectedImages[index] = File(pickedFile.path); // Save the File object
        widget.imageUrls[index] =
            pickedFile.path; // Update the image URLs for display
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    for (int i = 0; i < _selectedImages.length; i++) {
      var image = _selectedImages[i];

      if (image != null) {
        // Create a unique file name
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        // Upload the image to Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child('property_images/$fileName');
        UploadTask uploadTask = storageRef.putFile(image);
        TaskSnapshot snapshot = await uploadTask;

        // Get the download URL and add it to the list
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl); // Add the newly uploaded URL
      } else {
        // If the image is null, keep the original URL if available
        if (i < _originalImageUrls.length) {
          imageUrls.add(_originalImageUrls[i]); // Keep existing URL
        } else {
          imageUrls
              .add(""); // Handle case where there are fewer original images
        }
      }
    }

    return imageUrls;
  }

  // bool _validateFields() {
  //   if (_locationController.text.isEmpty ||
  //       _selectedCategoryIndex == -1 ||
  //       _selectedImages.isEmpty ||
  //       _priceController.text.isEmpty ||
  //       _selectedForIndex == -1) {
  //     return false;
  //   }
  //   return true;
  // }

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

  // Future<void> _submitData() async {
  //   if (_validateFields()) {
  //     try {
  //       // Upload images to Firebase Storage and get their URLs
  //       List<String> imageUrls = await _uploadImages();

  //       // Submit the data to Firestore
  //       await _firestore.collection('property').add({
  //         'homename': _homenameController.text,
  //         'location': _locationController.text,
  //         'category': _selectedCategoryIndex == 0
  //             ? 'House'
  //             : _selectedCategoryIndex == 1
  //                 ? 'Apartment'
  //                 : 'Land', // Determine the category based on index
  //         'imageUrls': imageUrls, // Store image URLs
  //         'price': double.tryParse(_priceController.text) ?? 0,
  //         'forWhat': _selectedForIndex == 0 ? 'Rent' : 'Sell',
  //         'area': _areaController.text,
  //         'floor': _floorController.text,
  //         'bed': _bedController.text,
  //         'bath': _bathController.text,
  //         'username': _username,
  //         'userImage': _imageUrl,
  //         'email': _email,
  //         'createdAt': formattedDate,
  //       });

  //       // Show success message
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Property added successfully!')),
  //       );

  //       // Clear form after submission
  //       setState(() {
  //         _locationController.clear();
  //         _priceController.clear();
  //         _selectedCategoryIndex = -1;
  //         _selectedForIndex = -1;
  //         _selectedImages.clear();
  //       });
  //     } catch (error) {
  //       _showErrorDialog('Failed to add property: $error');
  //     }
  //   } else {
  //     // Show an error if the fields are not validated
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please fill all the fields!')),
  //     );
  //   }
  // }

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
          'Edit Property',
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
                children: List.generate(widget.imageUrls.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        await _pickImage(
                            index); // Allow picking a new image for this index
                      },
                      child: Container(
                        width: 80, // Set a specific width
                        height: 60, // Set a specific height
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey), // Optional: Add a border
                          borderRadius: BorderRadius.circular(
                              8), // Optional: Add rounded corners
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              8), // Match the container's radius
                          child: widget.imageUrls[index].startsWith(
                                  'http') // Check if it's a network URL
                              ? Image.network(
                                  widget.imageUrls[index],
                                  fit: BoxFit.cover, // Cover the container
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons
                                          .error), // Error icon if the image fails to load
                                    );
                                  },
                                )
                              : Image.file(
                                  File(widget.imageUrls[
                                      index]), // Load existing local image
                                  fit: BoxFit.cover, // Cover the container
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons
                                          .error), // Error icon if the image fails to load
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: List.generate(4, (index) {
              //     return Padding(
              //       padding: const EdgeInsets.only(right: 8.0),
              //       child: _selectedImages.length > index &&
              //               _selectedImages[index] != null
              //           ? GestureDetector(
              //               onTap: () async {
              //                 await _pickImage(
              //                     index); // Allow picking a new image for this index
              //               },
              //               child: Image.file(
              //                 File(_selectedImages[index]!.path),
              //                 width: 80,
              //                 height: 60,
              //                 fit: BoxFit.cover,
              //               ),
              //             )
              //           : IconButton(
              //               icon: const Icon(Icons.add_a_photo),
              //               onPressed: () async {
              //                 await _pickImage(
              //                     index); // Allow adding a new image
              //               },
              //             ),
              //     );
              //   }),
              // ),
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
                        hintText: 'No.Floor',
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
                        hintText: 'No.Bath',
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
                        hintText: 'No.BedRooms',
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
                  onPressed: _updatePropertyDetails,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    backgroundColor: const Color.fromRGBO(31, 76, 107, 1),
                  ),
                  child: const Text(
                    'Update',
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
