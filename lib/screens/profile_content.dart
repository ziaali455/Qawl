import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:first_project/model/player.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/screens/all_folders_screen.dart';
import 'package:first_project/screens/danger_zone_widget.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/screens/verification_quiz_content.dart';
import 'package:first_project/widgets/playlist_manager_widget.dart';
import 'package:first_project/widgets/playlist_preview_widget.dart';
import 'package:first_project/widgets/profile_picture_widget.dart';
import 'package:first_project/widgets/qawl_back_button_widget.dart';
import 'package:first_project/widgets/qawl_record_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/widgets/profile_stats_widget.dart';
// import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:first_project/widgets/upload_popup_widget.dart';
import '../screens/taken_from_firebaseui/profile_screen_firebaseui.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:first_project/widgets/playlist_manager_widget.dart';
import 'package:first_project/widgets/playlist_list_widget.dart';

class ProfileContent extends StatefulWidget {
  final bool isPersonal;
  QawlUser? user;
  ProfileContent({
    required this.isPersonal,
    this.user,
    Key? key,
  }) : super(key: key);
  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  late Future<QawlUser?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = _loadUserData();
  }

  Future<QawlUser?> _loadUserData() async {
    if (widget.isPersonal) {
      return QawlUser.getQawlUserOrCurr(true);
    } else {
      return widget.user;
    }
  }

  Future<void> _refreshUserData() async {
    setState(() {
      userFuture = _loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QawlUser?>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        } else if (snapshot.hasError) {
          // Log the error for debugging
          debugPrint('Error loading user data: ${snapshot.error}');
          // Display the error message on the UI
          return Center(child: Text('Error!: ${snapshot.error.toString()}'));
        } else {
          final user = snapshot.data;
          if (user == null) {
            // Provide a more informative message or actions when no user data is found
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('No user found!'),
                  ElevatedButton(
                    onPressed: () =>
                        _refreshUserData(), // Assuming this method refreshes the user data
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          // If user data is successfully fetched, display the content
          return _buildContent(user);
        }
      },
    );
  }

  Widget _buildContent(QawlUser user) {
    final bool isPersonal = widget.isPersonal;
    
    return Container(
      padding: const EdgeInsets.only(top: 50),
      child: Scaffold(
        body: Stack(
          children: [
            // Main scrollable content
            RefreshIndicator(
              onRefresh: _refreshUserData,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  ProfilePictureWidget(
                    imagePath: (user.imagePath.isEmpty)
                        ? "https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3"
                        : user.imagePath,
                    country: user.country,
                    isPersonal: isPersonal,
                    user: user,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isPersonal ? buildPersonalName() : buildName(user),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NumbersWidget(
                      user: user,
                    ),
                  ),
                  if (isPersonal)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 80, right: 80),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<MyProfileScreen>(
                              builder: (context) => MyProfileScreen(
                                actions: [
                                  SignedOutAction((context) {
                                    Navigator.of(context).pop();
                                  })
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color.fromARGB(255, 13, 161, 99),
                                Color.fromARGB(255, 22, 181, 93),
                                Color.fromARGB(255, 32, 220, 85),
                              ],
                            ),
                          ),
                          width: 80,
                          height: 45,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5), // Adjust the spacing as needed
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isPersonal
                        ? FutureBuilder<Widget>(
                            future: buildPersonalAbout(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(
                                    color: Colors.green);
                              } else if (snapshot.hasError) {
                                return Text('Error: \\${snapshot.error}');
                              } else {
                                return snapshot.data ?? Container();
                              }
                            },
                          )
                        : buildAbout(user),
                  ),
                  if (!isPersonal)
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: FollowButton(
                        user: user,
                      ),
                    ),
                  if (!isPersonal)
                    const SizedBox(height: 16),
                  PlaylistFoldersWidget(
                    user: user,
                    isPersonal: isPersonal,
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Track>>(
                    future: Track.getTracksByUser(user).then((tracks) {
                      tracks
                          .sort((a, b) => a.surahNumber.compareTo(b.surahNumber));
                      return tracks;
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: \\${snapshot.error}'),
                        );
                      } else {
                        List<Track> uploadedTracks = snapshot.data ?? [];
                        uploadedTracks.sort(
                            (a, b) => a.surahNumber.compareTo(b.surahNumber));

                        // print("The tracks are " + uploadedTracks.toString());
                        return PlaylistPreviewWidget(
                          playlist: QawlPlaylist(
                            id: '0',
                            author: user.name,
                            name: "Uploads",
                            list: uploadedTracks,
                          ),
                          isPersonal: isPersonal,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Fixed positioned elements - these will NOT scroll
            if (isPersonal)
              Positioned(
                top: 15,
                right: 15,
                child: SafeArea(
                  child: QawlRecordButton(user: user),
                ),
              ),
            if (!isPersonal)
              Positioned(
                top: 15,
                right: 15,
                child: SafeArea(
                  child: DangerZone(user: user),
                ),
              ),
            if (!isPersonal) 
              Positioned(
                top: 15,
                left: 15,
                child: SafeArea(
                  child: QawlBackButton(),
                ),
              ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget buildPersonalName() {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && firebaseUser.displayName != null) {
      String displayedUsername = firebaseUser.displayName!;
      QawlUser.updateUserField(firebaseUser.uid, "name", displayedUsername);
      return Column(
        children: [
          Text(displayedUsername,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24))
        ],
      );
    } else {
      // Handle the case where there is no current user or displayName is null
      return const Column(
        children: [
          Text("Qawl User",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))
        ],
      );
    }
  }

  Widget buildName(QawlUser user) {
    return Column(
      children: [
        Text(user.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24))
      ],
    );
  }

  Future<Widget> buildPersonalAbout() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    String? about = await QawlUser.getAbout(firebaseUser!.uid);
    if (about == null) {
      about = "No about";
    }

    return Column(
      children: [
        Text(about,
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15))
      ],
    );
  }

  Widget buildAbout(QawlUser user) {
    return Column(
      children: [
        Text(user.about,
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15))
      ],
    );
  }
}