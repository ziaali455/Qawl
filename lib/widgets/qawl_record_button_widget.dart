import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:first_project/model/player.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/screens/danger_zone_widget.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/screens/verification_quiz_content.dart';
import 'package:first_project/widgets/playlist_preview_widget.dart';
import 'package:first_project/widgets/profile_picture_widget.dart';
import 'package:flutter/material.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/widgets/profile_stats_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:first_project/widgets/upload_popup_widget.dart';
import '../screens/taken_from_firebaseui/profile_screen_firebaseui.dart';



class QawlRecordButton extends StatefulWidget {
  final QawlUser user;

  QawlRecordButton({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<QawlRecordButton> createState() => _QawlRecordButtonState();
}

class _QawlRecordButtonState extends State<QawlRecordButton> {

  bool isVerified = false; // Default verification status
  bool isLoading = true; // State to handle loading

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    // Fetch the user and check the `isVerified` field
    QawlUser? currentUser = await QawlUser.getQawlUserOrCurr(true, user: widget.user);
    //QawlUser? currentUser = await QawlUser.fromFirestore(doc)
    print("CURRENT USER: " + currentUser!.isVerified.toString());
    if (currentUser != null) {
      setState(() {
        isVerified = currentUser.isVerified;
        isLoading = false;
      });
    } 
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(), // Show a loader while checking
      );
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: GestureDetector(
        onTap: () {

          print("VERIFICATION STATUS IS: " + isVerified.toString());
          if (isVerified) {
            showMaterialModalBottomSheet(
              context: context,
              builder: (context) => SingleChildScrollView(
                controller: ModalScrollController.of(context),
                child: const UploadPopupWidget(), // Replace with your content widget
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizHomePage(),
              ),
            );
          }
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent, // Transparent background
          ),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: <Color>[
                  Color.fromARGB(255, 13, 161, 99),
                  Color.fromARGB(255, 22, 181, 93),
                  Color.fromARGB(255, 32, 220, 85),
                ],
              ).createShader(bounds);
            },
            blendMode:
                BlendMode.srcATop, // Ensures gradient only affects the icon
            child: Icon(
              Icons.add,
              size: 35,
              color: Colors.white, // Icon color
            ),
          ),
        ),
      ),
    );
  }
}
