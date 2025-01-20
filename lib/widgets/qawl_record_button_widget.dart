// OLD VERSION, NEW IS UNCOMMENTED BELOW WITH STREAMBUILDER APPROACH
// import 'package:audio_service/audio_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:first_project/model/player.dart';
// import 'package:first_project/model/playlist.dart';
// import 'package:first_project/model/track.dart';
// import 'package:first_project/screens/danger_zone_widget.dart';
// import 'package:first_project/screens/now_playing_content.dart';
// import 'package:first_project/screens/verification_quiz_content.dart';
// import 'package:first_project/widgets/playlist_preview_widget.dart';
// import 'package:first_project/widgets/profile_picture_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:first_project/model/user.dart';
// import 'package:first_project/widgets/profile_stats_widget.dart';
// import 'package:go_router/go_router.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:first_project/widgets/upload_popup_widget.dart';
// import '../screens/taken_from_firebaseui/profile_screen_firebaseui.dart';

// class QawlRecordButton extends StatefulWidget {
//   final QawlUser user;

//   QawlRecordButton({
//     Key? key,
//     required this.user,
//   }) : super(key: key);

//   @override
//   State<QawlRecordButton> createState() => _QawlRecordButtonState();
// }

// class _QawlRecordButtonState extends State<QawlRecordButton> {

//   bool isVerified = false; // Default verification status
//   bool isLoading = true; // State to handle loading

//   @override
//   void initState() {
//     super.initState();
//     _checkVerificationStatus();
//   }

//   Future<void> _checkVerificationStatus() async {
//     // Fetch the user and check the `isVerified` field
//     QawlUser? currentUser = await QawlUser.getQawlUserOrCurr(true, user: widget.user);
//     //QawlUser? currentUser = await QawlUser.fromFirestore(doc)
//     print("CURRENT USER: " + currentUser!.isVerified.toString());
//     if (currentUser != null) {
//       setState(() {
//         isVerified = currentUser.isVerified;
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Center(
//         child: CircularProgressIndicator(), // Show a loader while checking
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(3.0),
//       child: GestureDetector(
//         onTap: () {

//           print("VERIFICATION STATUS IS: " + isVerified.toString());
//           if (isVerified) {
//             showMaterialModalBottomSheet(
//               context: context,
//               builder: (context) => SingleChildScrollView(
//                 controller: ModalScrollController.of(context),
//                 child: const UploadPopupWidget(), // Replace with your content widget
//               ),
//             );
//           } else {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => QuizHomePage(),
//               ),
//             );
//           }
//         },
//         child: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.transparent, // Transparent background
//           ),
//           child: ShaderMask(
//             shaderCallback: (Rect bounds) {
//               return LinearGradient(
//                 colors: <Color>[
//                   Color.fromARGB(255, 13, 161, 99),
//                   Color.fromARGB(255, 22, 181, 93),
//                   Color.fromARGB(255, 32, 220, 85),
//                 ],
//               ).createShader(bounds);
//             },
//             blendMode:
//                 BlendMode.srcATop, // Ensures gradient only affects the icon
//             child: Icon(
//               Icons.add,
//               size: 35,
//               color: Colors.white, // Icon color
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/not_yet_verified_content.dart';
import 'package:first_project/screens/verification_quiz_content.dart';
import 'package:first_project/widgets/upload_popup_widget.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QawlRecordButton extends StatelessWidget {
  final QawlUser user;

  QawlRecordButton({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(user.id) // Use the user's document ID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(), // Show a loader while loading
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('User data not found');
        }

        // Get the `isVerified` field from Firestore
        final isVerified = snapshot.data!.get('isVerified') ?? false;
        // final lastAttemptedQuiz =
        //     snapshot.data!.get('lastAttemptedQuiz') ?? null;

        //var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

        // APPROACH TO USE LOCAL MEMORY FOR LAST ATTEMPT
        Future<bool> canRetakeQuiz() async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final int? lastAttempt = prefs.getInt('lastQuizAttempt');

          if (lastAttempt == null) {
            return true; // No attempt recorded, allow quiz
          }

          final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
          // const int tenDaysInMillis = 10 * 24 * 60 * 60 * 1000;
          const int twoMinInMillis = 2 * 60 * 1000; // = 120000 milliseconds

          return (currentTimestamp - lastAttempt) >= twoMinInMillis; // CHANGE BACK TO 10 DAYS!!!
        }
        
        // UPDATES TIMESTAMP LOCALLY
        Future<void> updateQuizTimestamp() async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
          await prefs.setInt('lastQuizAttempt', currentTimestamp);
          print('Last quiz attempt timestamp updated: $currentTimestamp');
        }

        // SETS THE CURRENT TIMESTAMP AND SAVES IN LOCAL MEMORY 
        Future<void> _handleQuizAttempt() async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
          await prefs.setInt('lastQuizAttempt', currentTimestamp);
          print('Last quiz attempt saved: $currentTimestamp');
        }

        // Future<void> _handleQuizAttempt() async {
        //   final currentUser = await QawlUser.getQawlUserOrCurr(true);

        //   if (currentUser != null) {
        //     await QawlUser.updateUserField(
        //       currentUser.id,
        //       'lastAttemptedQuiz',
        //       DateTime.now(),
        //     );
        //     print('Updated lastAttemptedQuiz timestamp.');
        //   } else {
        //     print('Error: Unable to update timestamp.');
        //   }
        // }

        return GestureDetector(
          onTap: () async {
            final canRetake = await canRetakeQuiz();

            print("VERIFICATION STATUS IS: $isVerified");
            if (isVerified) {
              showMaterialModalBottomSheet(
                context: context,
                builder: (context) => SingleChildScrollView(
                  controller: ModalScrollController.of(context),
                  child: const UploadPopupWidget(),
                ),
              );
            } else if (!canRetake) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotVerifiedTimePage(),
                ),
              );
            } else {
              await updateQuizTimestamp();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizHomePage(),
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
        );
      },
    );
  }
}
