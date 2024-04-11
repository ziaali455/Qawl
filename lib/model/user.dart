import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';
import 'package:flutter/foundation.dart';

class QawlUser {
  FirebaseAuth _auth = FirebaseAuth.instance;

  String imagePath;
  final String id;
  String name;
  final String email;
  String about;
  String country;
  int followers;
  Set<String> following;
  Set<String> privateLibrary;
  Set<String> uploads;

  QawlUser(
      {required this.imagePath,
      required this.id,
      required this.name,
      required this.email,
      required this.about,
      required this.country,
      required this.followers,
      required this.following,
      required this.privateLibrary,
      required this.uploads});

  static String? getCurrentUserUid() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid;
  }

  factory QawlUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QawlUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      imagePath: data['imagePath'] ?? '',
      about: data['about'] ?? '',
      country: data['country'] ?? '',
      followers: data['followers'] ?? 0,
      following: Set<String>.from(data['following'] ?? []),
      privateLibrary: Set<String>.from(data['privateLibrary'] ?? []),
      uploads: Set<String>.from(data['publicLibrary'] ?? []),
    );
  }

  static Future<QawlUser?> getQawlUser(String uid) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('QawlUsers').doc(uid).get();
    if (doc.exists) {
      return QawlUser.fromFirestore(doc);
    } else {
      return null;
    }
  }

  static Future<QawlUser?> getQawlUserOrCurr(bool isPersonal,
      {QawlUser? user}) async {
    if (isPersonal) {
      final currentUserUid = QawlUser.getCurrentUserUid();
      if (currentUserUid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('QawlUsers')
            .doc(currentUserUid)
            .get();
        if (doc.exists) {
          return QawlUser.fromFirestore(doc);
        }
      }
    } else {
      return user;
    }
    return null; // Return null if user not found or isPersonal is true but no user is logged in
  }

  Future<List<Track>> getUploadedTracks() async {
    List<Track> uploadedTracks = [];

    try {
      // Fetch the QawlUser document
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(id)
          .get();

      // Check if the user document exists
      if (userSnapshot.exists) {
        // Retrieve the uploads field from the user data as a set
        Set<String> userUploads = Set<String>.from(
            (userSnapshot.data() as Map<String, dynamic>)['uploads'] ?? []);

        // Iterate through each track ID in the uploads
        for (String trackId in userUploads) {
          print('Fetching track with ID: $trackId'); // Add debug print
          DocumentSnapshot trackSnapshot = await FirebaseFirestore.instance
              .collection('QawlTracks')
              .doc(trackId)
              .get();
          
          if (trackSnapshot.exists) {
            Map<String, dynamic> data =
                trackSnapshot.data() as Map<String, dynamic>;
            Track track = Track(
              userId: data['userId'],
              id: trackSnapshot.id,
              trackName: data['trackName'],
              plays: data['plays'],
              surahNumber: data['surahNumber'],
              audioPath: data['audioPath'],
              inPlaylists: data['inPlaylists'],
              coverImagePath: data['coverImagePath'] ?? "defaultCoverImagePath",
            );
            uploadedTracks.add(track);
            print(
                'Track with ID $trackId found and added to uploadedTracks.'); // Add debug print
          } else {
            print('Track with ID $trackId not found.');
          }
        }
      } else {
        print('QawlUser with ID $id not found.');
      }
    } catch (e) {
      print('Error fetching uploaded tracks: $e');
    }

    return uploadedTracks;
  }

//   Future<List<Track>> getUploadedTracks() async {
//     List<Track> uploadedTracks = [];
//    Map<String, dynamic> trackData = {
//   'userId': 'user123',
//   'trackName': 'Track 1',
//   'plays': 100,
//   'surahNumber': 1,
//   'audioPath': 'path/to/audio.mp3',
//   'coverImagePath': 'path/to/coverImage.png',
// };
//     try {
//       for (String trackId in uploads) {
//         Track? track = await Track.fromFirestore(trackData, trackId);
//         if (track != null) {
//           uploadedTracks.add(track);
//         } else {
//           // Handle the case where the track is null (not found)
//           print('Track with ID $trackId not found.');
//         }
//       }
//     } catch (e) {
//       print('Error fetching uploaded tracks: $e');
//     }

//     return uploadedTracks;
//   }

  // Future<Playlist> getUploadedTracksPlaylist() async {
  //   List<Track> uploadedTracks = [];

  //   try {
  //     // Check if uploads list is empty
  //     if (uploads.isEmpty) {
  //       print('Error: uploads list is empty.');
  //       return Playlist(author: "", name: "Uploads", list: uploadedTracks);
  //     }

  //     // Fetch tracks directly from Firestore
  //     QuerySnapshot trackSnapshot = await FirebaseFirestore.instance
  //         .collection('QawlTracks')
  //         .where(FieldPath.documentId,
  //             whereIn: uploads.toList()) // Convert Set to List
  //         .get();

  //     // Extract track data from the snapshot and create Track objects
  //     trackSnapshot.docs.forEach((doc) {
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //       Track track = Track(
  //         userId: data['userId'],
  //         id: doc.id,
  //         trackName: data['trackName'],
  //         plays: data['plays'],
  //         surahNumber: data['surahNumber'],
  //         audioPath: data['audioPath'],
  //         inPlaylists: data['inPlaylists'],
  //         coverImagePath: data['coverImagePath'] ?? "defaultCoverImagePath",
  //       );
  //       uploadedTracks.add(track);
  //     });

  //     // Print the number of tracks fetched
  //     print("Fetched ${uploadedTracks.length} tracks successfully.");
  //   } catch (e) {
  //     print('Error fetching uploaded tracks: $e');
  //   }

  //   Playlist uploadPlaylist =
  //       Playlist(author: "", name: "Uploads", list: uploadedTracks);

  //   // Print all attributes of the Playlist object
  //   print("Playlist: $uploadPlaylist");

  //   return uploadPlaylist;
  // }

  static Future<QawlUser?> getCurrentQawlUser() async {
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    return getQawlUser(currentUserID!);
  }

  static Future<void> updateUserUploads(String uploadId) async {
    try {
      QawlUser? currentUser = await getCurrentQawlUser();
      if (currentUser != null) {
        // Update local QawlUser object
        currentUser.uploads.add(uploadId);

        // Update network document on Firebase
        await FirebaseFirestore.instance
            .collection('QawlUsers')
            .doc(currentUser.id)
            .update({
          'uploads': currentUser.uploads.toList(),
        });
      } else {
        print('Error: Current user not found.');
      }
    } catch (e) {
      print('Error updating user uploads: $e');
    }
  }

  String get getQawlUserImagePath => imagePath;
  String get getQawlUserId => id;
  String get getQawlUserName => name;
  String get getQawlUserEmail => email;
  String get getQawlUserAbout => about;
  String get getQawlUserCountry => country;
  int get getQawlUserFollowers => followers;
  Set<String> get getQawlUserFollowing => following;

  static Future<String?> getPfp(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return userDoc.get('imagePath');
      } else {
        debugPrint("No user found for UID: $uid");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile picture: $e");
      return null;
    }
  }

  static Future<String?> getName(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return userDoc.get('name');
      } else {
        debugPrint("No user found for UID: $uid");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile picture: $e");
      return null;
    }
  }

  static Future<String?> getAbout(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return userDoc.get('about');
      } else {
        print("No about found for UID: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching about: $e");
      return null;
    }
  }

  static Future<String?> getFollowers(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return userDoc.get('followers');
      } else {
        print("No follower data found for UID: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching followers: $e");
      return null;
    }
  }

  Future<void> updateImagePath(String uid, String newPath) async {
    await FirebaseFirestore.instance.collection('QawlUsers').doc(uid).update({
      'imagePath': newPath,
    });
    debugPrint("\nImage path: " + imagePath + '\n');
    debugPrint("\n UPLOADING IMAGE TO STORAGE\n");
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child("images/profile_images/$uid/profile.jpg");
    File imageFile = File(imagePath);
    try {
      UploadTask uploadTask = storageRef.putFile(imageFile);
      await uploadTask;
      final url = await storageRef.getDownloadURL();
      imagePath = url;
      updateQawlUserImagePath(imagePath);
      print("THE DOWNLOAD URL IS: " + imagePath + '\n');
      print("Image uploaded successfully. URL: $url");
    } on FirebaseException catch (e) {
      print("Error uploading image: ${e.message}");
    }
    debugPrint("Image path updated successfully.");
  }

  Future<void> updateQawlUserImagePath(String newPath) async {
    this.imagePath = newPath;
    await updateUserField(this.id, "imagePath", newPath);
  }

  static Future<void> updateUserField(
      String uid, String field, dynamic value) async {
    try {
      await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(uid)
          .update({field: value});
      debugPrint("User $field updated successfully.");
    } catch (e) {
      debugPrint("Error updating user $field: $e");
    }
  }

  static Future<String?> createQawlUser(User? firebaseUser) async {
    firebaseUser != null
        ? QawlUser(
            imagePath: "",
            id: firebaseUser.uid,
            name: "",
            email: firebaseUser.email ?? "",
            about: "",
            country: "",
            followers: 0,
            following: Set<String>(),
            privateLibrary: Set<String>(),
            uploads: Set<String>(),
          )
        : null;
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('QawlUsers')
        .doc(firebaseUser?.uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (firebaseUser != null && !docSnapshot.exists) {
      // Playlist uploads = new Playlist(
      //     author: firebaseUser.uid, name: "Uploads", list: List<Track>.empty());
      await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(firebaseUser.uid)
          .set({
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'timestamp': DateTime.now(),
        'imagePath': "",
        'name': "",
        'about': "",
        'country': "",
        'followers': 0,
        'following': [],
        'privateLibrary': [],
        // 'publicLibrary': [uploads],
      });
    }
    if (firebaseUser?.uid != null) {
      return firebaseUser?.uid;
    } else {
      return null;
    }
  }

  static Future<void> toggleFollow(QawlUser follower, QawlUser followed) async {
    try {
      // Check if follower is already following followed
      final isFollowing = follower.following.contains(followed.id);

      if (isFollowing) {
        // If already following, unfollow
        follower.following.remove(followed.id);
        followed.followers--;
      } else {
        // If not following, follow
        follower.following.add(followed.id);
        followed.followers++;
      }

      // Update network documents for follower and followed
      await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(follower.id)
          .update({
        'following': follower.following.toList(),
      });
      await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(followed.id)
          .update({
        'followers': followed.followers,
      });
    } catch (e) {
      // Handle errors
      print("Error toggling follow: $e");
      // You might want to throw or handle the error appropriately
      throw e;
    }
  }
}
