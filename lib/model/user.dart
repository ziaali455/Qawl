import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  String gender;
  bool isVerified;
  //DateTime? lastAttemptedQuiz;

  QawlUser(
      {required this.imagePath,
      required this.id,
      required this.name,
      required this.email,
      required this.about,
      this.country = '',
      required this.followers,
      required this.following,
      required this.privateLibrary,
      required this.uploads,
      this.gender = 'm',
      this.isVerified = false,
      //this.lastAttemptedQuiz
      });

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
        gender: data['gender'] ?? '',
        isVerified: data['isVerified'] ?? false,);
        //lastAttemptedQuiz: data['lastAttemptedQuiz'] ?? null);
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

// does a check to see if isVerified field already exists
  static Future<QawlUser?> getQawlUserOrCurr(bool isPersonal,
      {QawlUser? user}) async {
    if (isPersonal) {
      final currentUserUid = QawlUser.getCurrentUserUid();
      if (currentUserUid != null) {
        final docRef = FirebaseFirestore.instance
            .collection('QawlUsers')
            .doc(currentUserUid);

        final doc = await docRef.get();

        if (doc.exists) {
          // Check if the 'isVerified' field exists in the document
          final data = doc.data();
          if (data != null && (!data.containsKey('isVerified'))) {
            // Update the document to include 'isVerified' with a default value of false
            await docRef.update({'isVerified': false});
          }
          // if (data != null && (!data.containsKey('lastAttemptedQuiz'))) {
          //   await docRef.update({'lastAttemptedQuiz': null});
          // }

          return QawlUser.fromFirestore(doc);
        }
      }
    } else {
      return user;
    }
    return null; // Return null if user not found or isPersonal is true but no user is logged in
  }

  // static Future<QawlUser?> getQawlUserOrCurr(bool isPersonal,
  //     {QawlUser? user}) async {
  //   if (isPersonal) {
  //     final currentUserUid = QawlUser.getCurrentUserUid();
  //     if (currentUserUid != null) {
  //       final doc = await FirebaseFirestore.instance
  //           .collection('QawlUsers')
  //           .doc(currentUserUid)
  //           .get();
  //       if (doc.exists) {
  //         return QawlUser.fromFirestore(doc);
  //       }
  //     }
  //   } else {
  //     return user;
  //   }
  //   return null; // Return null if user not found or isPersonal is true but no user is logged in
  // }

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
                coverImagePath:
                    data['coverImagePath'] ?? "defaultCoverImagePath",
                style: data['style'] ?? 'Hafs \'an Asim',
                timeStamp: data['timeStamp']);
            uploadedTracks.add(track);
          }
        }
      }
    } catch (e) {
      // Handle errors
      throw e;
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

  // static Future<List<QawlUser>> getUsersByCountry(String countryName) async {
  //   List<QawlUser> users = [];

  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('QawlUsers')
  //         .where('country', isEqualTo: countryName)
  //         .get();

  //     querySnapshot.docs.forEach((doc) {
  //       users.add(QawlUser.fromFirestore(doc));
  //     });
  //   } catch (error) {
  //     print("Error fetching users by country: $error");
  //     // Handle error as necessary
  //   }
  //   List<QawlUser> res = [];
  //   QawlUser? curr = await QawlUser.getCurrentQawlUser();
  //   for (QawlUser user in users) {
  //     if (user.gender == curr?.gender) {
  //       res.add(user);
  //     }
  //   }

  //   // print("Users in $countryName are $users");
  //   return res;
  // }
  static Future<List<QawlUser>> getUsersByCountry(String countryName,
      {String query = ''}) async {
    List<QawlUser> users = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .where('country', isEqualTo: countryName)
          .get();

      querySnapshot.docs.forEach((doc) {
        users.add(QawlUser.fromFirestore(doc));
      });
    } catch (error) {
      // Handle error as necessary
    }

    List<QawlUser> res = [];
    QawlUser? curr = await QawlUser.getCurrentQawlUser();
    for (QawlUser user in users) {
      if (user.gender == curr?.gender) {
        res.add(user);
      }
    }

    if (query.isNotEmpty) {
      res = res.where((user) {
        return user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    return res;
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
      }
    } catch (e) {
      // Handle errors
      throw e;
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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // static Future<void> updatePfp(String imagePath) async {
  //   try {
  //     // Update local QawlUser object
  //     QawlUser? user = await getCurrentQawlUser();
  //     user?.imagePath = imagePath;

  //     // Update network document on Firebase
  //     await FirebaseFirestore.instance
  //         .collection('QawlUsers')
  //         .doc(user?.id)
  //         .update({'imagePath': imagePath});
  //   } catch (e) {
  //     print('Error updating pfp image: $e');
  //   }
  // }

  static Future<String?> getName(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return userDoc.get('name');
      } else {
        return null;
      }
    } catch (e) {
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

  static Future<void> updateGender(String newGender) async {
    try {
      // Update local QawlUser object
      QawlUser? user = await getCurrentQawlUser();
      user?.gender = newGender;
      print("GENDER UPDATED TO: " + newGender);

      // Update network document on Firebase
      await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(user?.id)
          .update({'gender': newGender});
    } catch (e) {
      print('Error updating gender: $e');
    }
  }

  static Future<void> updateCountry(String newCountry) async {
    try {
      // Update local QawlUser object
      QawlUser? user = await getCurrentQawlUser();
      user?.country = newCountry;

      // Update network document on Firebase
      await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(user?.id)
          .update({'country': newCountry});
    } catch (e) {
      print('Error updating country: $e');
    }
  }

  static Future<void> updateName(String newName) async {
    try {
      // Get the current Firebase user
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // Update the display name of the Firebase user
        await firebaseUser.updateDisplayName(newName);

        // Update local QawlUser object
        QawlUser? user = await getCurrentQawlUser();
        if (user != null) {
          user.name = newName;
        }

        // Update network document on Firebase (optional)
        await FirebaseFirestore.instance
            .collection('QawlUsers')
            .doc(firebaseUser.uid)
            .update({'name': newName});
      }
    } catch (e) {
      print('Error updating name: $e');
    }
  }

  Future<void> updateImagePath(String uid, String newPath) async {
    await FirebaseFirestore.instance.collection('QawlUsers').doc(uid).update({
      'imagePath': newPath,
    });
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
    } on FirebaseException catch (e) {
      String defaultPath =
          "https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3";
      updateQawlUserImagePath(defaultPath);
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
    } catch (e) {
      // Handle errors
      throw e;
    }
  }

  // static Future<void> createUserField(
  //     String uid, String field, dynamic value) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('QawlUsers')
  //         .doc(uid)
  //         .({field: value});
  //     debugPrint("Added $field to user .");
  //   } catch (e) {
  //     debugPrint("Error adding user $field: $e");
  //   }
  // }

  static Future<String?> createQawlUser(User? firebaseUser) async {
    firebaseUser != null
        ? QawlUser(
            imagePath:
                "https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3",
            id: firebaseUser.uid,
            name: "",
            email: firebaseUser.email ?? "",
            about: "",
            country: "",
            followers: 0,
            following: Set<String>(),
            privateLibrary: Set<String>(),
            uploads: Set<String>(),
            gender: 'm', //needs to be set later
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
        'imagePath':
            "https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3",

        'name': "",
        'about': "",
        'country': "",
        'followers': 0,
        'following': [],
        'privateLibrary': [],
        'gender': "m",
        'isVerified': false
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
      throw e;
    }
  }
}
