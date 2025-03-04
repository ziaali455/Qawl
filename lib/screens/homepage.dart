import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/screens/homepage_content.dart';
import 'package:first_project/screens/explore_content.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/screens/profile_content.dart';
import 'package:first_project/deprecated/profile_content_DEPRECATED.dart';
import 'package:first_project/widgets/now_playing_button.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 1; // Set initial index to 1 for ExploreContent

  final List<Widget> screens = [
    const HomePageContent(),
    const ExploreContent(),
    ProfileContent(isPersonal: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          screens[currentIndex],
          const NowPlayingButton(),
        ],
      ),
      bottomNavigationBar: GNav(
        backgroundColor: Colors.black,
        color: Colors.white,
        activeColor: Colors.green,
        onTabChange: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        tabs: const [
          GButton(icon: Icons.home),
          GButton(icon: Icons.search),
          GButton(icon: Icons.person),
        ],
        selectedIndex: currentIndex,
      ),
    );
  }
}
