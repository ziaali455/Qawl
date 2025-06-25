import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/widgets/qawl_back_button_widget.dart';
import 'package:flutter/material.dart';

class NotVerifiedTimePage extends StatelessWidget {
  const NotVerifiedTimePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const QawlBackButton(), // Back button in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Add padding around the content
        child: const Center(
          child: Text(
            "You must wait 10 days before retaking the quiz",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
