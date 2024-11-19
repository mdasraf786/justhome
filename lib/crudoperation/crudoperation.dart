import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference property =
      FirebaseFirestore.instance.collection('property');

  // Create: add a new property with all the necessary fields
  Future<void> addProperty({
    required String location,
    required String category, // e.g., house, apartment, land
    required List<String> imageUrls, // List of image URLs
    required double price,
    required String forWhat, // rent or sale
  }) {
    return property.add({
      'location': location,
      'category': category,
      'imageUrls': imageUrls,
      'price': price,
      'forWhat': forWhat,
      'timestamp': Timestamp.now(),
    });
  }

// Read: Fetch all properties from Firestore
  Future<List<Map<String, dynamic>>> getProperties() async {
    try {
      QuerySnapshot querySnapshot = await property.get();

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
