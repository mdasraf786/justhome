import 'package:flutter/material.dart';
import 'package:justhome/chattingpage.dart';
import 'package:justhome/homepage.dart';
// Replace with the actual path to your ChattingPage

class NotificationPage extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  NotificationPage({required this.users});
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 0; // Initially display "Notification"
  int _filterIndex = 0; // Initially show "All" notifications

  // Notifications and messages data
  List<Map<String, dynamic>> notifications = [
    {
      'name': 'Baljit Thakur',
      'message': 'Just messaged you. Check the message tab.',
      'time': '0 mins ago',
      'type': 'message',
      'imageUrl': 'assets/images/baljit.jpg',
    },
    {
      'name': 'Asraf Ali',
      'message': 'Just added new Apartment for rent',
      'time': '20 mins ago',
      'type': 'notification',
      'imageUrl': 'assets/images/asraf.png',
      'propertyImage': 'assets/property1.png',
    },
    {
      'name': 'Mussa',
      'message': 'Just added Schoolview House',
      'time': '1 day ago',
      'type': 'notification',
      'imageUrl': 'assets/images/mussa.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1D7D0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        _buildTabButton("Notification", 0),
                        SizedBox(width: 16.0),
                        _buildTabButton("Message", 1),
                      ],
                    ),
                  ),
                  if (_selectedIndex == 1)
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Handle delete button press
                      },
                    ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            if (_selectedIndex == 0)
              _buildFilterOptions(), // Show filters only for notifications
            SizedBox(height: 16.0),
            Expanded(
              child: _buildNotificationOrMessageList(),
            ),
          ],
        ),
      ),
    );
  }

  // Build Notification or Message Tabs
  Widget _buildTabButton(String title, int index) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedIndex = index; // Update selected tab
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedIndex == index
              ? Color.fromRGBO(31, 76, 107, 1)
              : Colors.white,
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 22.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Build the filter buttons for notifications
  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: <Widget>[
          _buildFilterButton("All", 0),
          SizedBox(width: 16.0),
          _buildFilterButton("Today", 1),
          SizedBox(width: 16.0),
          _buildFilterButton("Older", 2),
        ],
      ),
    );
  }

  // Build filter buttons logic
  Widget _buildFilterButton(String title, int index) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _filterIndex = index; // Update the selected filter index
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _filterIndex == index
            ? Color.fromRGBO(31, 76, 107, 1)
            : Colors.white,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationOrMessageList() {
    return widget.users
            .isEmpty // Use widget.users to access the users list from NotificationPage
        ? Center(child: Text('No users in your inbox.'))
        : ListView.builder(
            itemCount: widget.users.length,
            itemBuilder: (context, index) {
              var user = widget.users[index];

              return ListTile(
                title: Text(user['username']),
                onTap: () {
                  // Navigate to the chat page with the selected user
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChattingPage(),
                  ));
                },
              );
            },
          );
  }

  // // Build Notification or Message List (with filtered logic based on selected tab)
  // Widget _buildNotificationOrMessageList() {
  //   // Filter notifications or messages based on selected tab and filter
  //   List<Map<String, dynamic>> filteredItems = notifications.where((item) {
  //     if (_selectedIndex == 1) {
  //       return item['type'] ==
  //           'message'; // Show only messages when "Message" tab is selected
  //     }
  //     // Apply filters for notifications
  //     if (_filterIndex == 1) {
  //       return item['time'].contains('0 mins ago') ||
  //           item['time'].contains('1 day ago');
  //     } else if (_filterIndex == 2) {
  //       return item['time'].contains('1 day ago');
  //     }
  //     return item['type'] == 'notification'; // Show notifications by default
  //   }).toList();

  //   return ListView.builder(
  //     itemCount: filteredItems.length,
  //     itemBuilder: (context, index) {
  //       return NotificationItem(
  //         notification: filteredItems[index],
  //         onTap: () {
  //           // Navigate to ChattingPage
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) =>
  //                     HomePage()), // Navigate to the external ChattingPage
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}

class NotificationItem extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  NotificationItem({required this.notification, required this.onTap});

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background
            borderRadius: BorderRadius.circular(25.0),
            // Border radius
            boxShadow: [
              BoxShadow(
                color: Colors.black12, // Shadow color for depth effect
                blurRadius: 5.0, // Blur radius for shadow
                offset: Offset(0, 2), // Position of the shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage(widget.notification['imageUrl']),
                  radius: 25.0,
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.notification['name'],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(31, 76, 107, 1),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        widget.notification['message'],
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromRGBO(31, 76, 107, 1),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        widget.notification['time'],
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
