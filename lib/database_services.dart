import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to send a message
  Future<void> sendMessage(String senderId, String receiverId, String message,
      String userImage) async {
    // Send the message
    await _firestore.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'userImage': userImage,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message for both sender and receiver
    await _updateLastMessage(senderId, receiverId, message, userImage);
    await _updateLastMessage(receiverId, senderId, message,
        userImage); // Also update on receiver's end
  }

  // Function to update the last message in the user's chat list
  Future<void> _updateLastMessage(String userId, String chatPartnerId,
      String lastMessage, String userImage) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chatList')
        .doc(chatPartnerId)
        .set({
      'userImage': userImage,
      'lastMessage': lastMessage,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getNotifications(String currentUserId) {
    return _firestore
        .collection('notifications')
        .where('userId',
            isEqualTo:
                currentUserId) // Adjust query according to your structure
        .orderBy('timestamp', descending: true) // Order by timestamp
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'username': doc['username'],
          'userImage': doc['userImage'],
          'type': doc['type'], // 'property' or 'message'
          'category': doc['category'], // Only for property notifications
          'senderId': doc['senderId'], // Only for message notifications
          'timestamp': doc['timestamp'],
        };
      }).toList();
    });
  }

  // Function to get messages between two users
  Stream<List<Map<String, dynamic>>> getMessages(
      String currentUserId, String chatPartnerId) {
    // Stream for sent messages
    final sentMessagesStream = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: chatPartnerId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());

    // Stream for received messages
    final receivedMessagesStream = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: chatPartnerId)
        .where('receiverId', isEqualTo: currentUserId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());

    // Combine sent and received messages streams
    return Rx.combineLatest2(sentMessagesStream, receivedMessagesStream,
        (List<Map<String, dynamic>> sentMessages,
            List<Map<String, dynamic>> receivedMessages) {
      // Combine both lists and sort them by timestamp
      final allMessages = [...sentMessages, ...receivedMessages];
      allMessages.sort((a, b) =>
          a['timestamp'].compareTo(b['timestamp'])); // Sort by timestamp
      return allMessages; // Return combined and sorted messages
    });
  }

  // Function to get a list of users
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  // Function to get chat list for a specific user
  // Function to get chat list for a specific user
  Stream<List<Map<String, dynamic>>> getChatList(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chatList')
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Map<String, dynamic>> chatList = [];

      for (var doc in snapshot.docs) {
        final chatPartnerId = doc.id; // Get the ID of the chat partner
        final lastMessage =
            doc['lastMessage'] ?? 'No messages yet'; // Fallback if null

        // Fetch user details
        final userDoc =
            await _firestore.collection('users').doc(chatPartnerId).get();

        // Add debug prints
        print('Fetching user data for chat partner: $chatPartnerId');
        print(
            'User document data: ${userDoc.data()}'); // Print the user document data

        final username =
            userDoc.data()?['username'] ?? 'Unknown'; // Get username
        final userImage =
            userDoc.data()?['imageUrl'] ?? 'unknown'; // Get userImage

        // Add user info to chatList
        chatList.add({
          'id': chatPartnerId,
          'username': username,
          'userImage': userImage,
          'lastMessage': lastMessage,
          'timestamp': doc['timestamp'],
        });
      }

      print('Chat List: $chatList'); // Print the full chat list
      return chatList; // Return the updated chat list with usernames and images
    });
  }
}
