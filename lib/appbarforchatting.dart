import 'package:flutter/material.dart';
import 'package:justhome/callingpage.dart';
import 'package:justhome/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Receiver's user ID
  final String username;
  final String userImage; // Receiver's username

  CustomAppBar({required this.username, required this.userImage});

  @override
  Size get preferredSize => Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.chevron_left),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(2),
                child: ClipOval(
                  child: Image.asset(
                    profile, // Replace with your image URL
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green, // Green for online status
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MD ASRAF ALI',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Online', // Change to 'Offline' as needed
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 194, 212, 227),
          ),
          child: IconButton(
            iconSize: 20,
            icon: Icon(Icons.call_outlined, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CallingPage(),
                ),
              );
            },
          ),
        ),
      ],
      backgroundColor:
          Color.fromARGB(255, 225, 218, 218), // Customize as needed
    );
  }
}
