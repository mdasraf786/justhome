import 'package:flutter/material.dart';
import 'package:justhome/additem.dart';
import 'package:justhome/profile.dart';

class BottomNavbar extends StatelessWidget {
  BottomNavbar({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      key: _scaffoldKey,
      child: SizedBox(
        height: 70, // Adjusted height
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.home,
                        color: Colors.black,
                      )),
                  Text(
                    'Home',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold), // Increased font size
                  )
                ],
              ),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.message,
                        color: Colors.black,
                      )),
                  Text(
                    'Inbox',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold), // Increased font size
                  )
                ],
              ),
            ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50, // Adjusted height
                      child: Center(
                        child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>AddItemPage(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                         
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>ProfilePage(),
                                ),
                              );
                            
                      },
                      icon: Icon(
                        Icons.person_2,
                        color: Colors.black,
                      )),
                  Text(
                    'Profile',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold), // Increased font size
                  )
                ],
              ),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        if (_scaffoldKey.currentState != null) {
                          _scaffoldKey.currentState?.openDrawer();
                        }
                      },
                      icon: Icon(
                        Icons.more,
                        color: Colors.black,
                      )),
                  Text(
                    'More',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold), // Increased font size
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
