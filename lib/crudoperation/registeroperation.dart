import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference user =
      FirebaseFirestore.instance.collection('user');

  // Create: add a new property with all the necessary fields
  Future<void> addUser({
    required String username,
    required String email, // e.g., house, apartment, land
    required List<String> imageUrls, // List of image URLs
    required String password,
    // rent or sale
  }) {
    return user.add({
      'username': username,
      'email': email,
      'password': password,
      'imageUrls': imageUrls,
      'timestamp': Timestamp.now(),
    });
  }

// Read: Fetch all properties from Firestore
  Future<List<Map<String, dynamic>>> getProperties() async {
    try {
      QuerySnapshot querySnapshot = await user.get();

      // Convert the query result to a list of maps
      List<Map<String, dynamic>> properties = querySnapshot.docs.map((doc) {
        return {
          'location': doc['location'],
          'category': doc['category'],
          'imageUrls': List<String>.from(doc['imageUrls']),
          'price': doc['price'],
          'forWhat': doc['forWhat'],
          'timestamp': doc['timestamp'],
        };
      }).toList();

      return properties;
    } catch (e) {
      print("Error getting properties: $e");
      return [];
    }
  }
}
