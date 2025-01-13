import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/model/user.dart';
import 'package:uuid/uuid.dart';

class QawlPlaylist {
  final String author;
  final String name;
  final List<Track> list;
  String coverImagePath = "https://www.linkpicture.com/q/no_cover_1.jpg";
  String id;

  QawlPlaylist(
      {required this.author,
      required this.name,
      required this.list,
      required this.id});

  void addTrack(Track track) {
    list.add(track);
  }

  static Future<void> createPlaylist(QawlPlaylist playlist) async {
    try {
      await FirebaseFirestore.instance.collection('QawlPlaylists').add({
        'author': playlist.author,
        'name': playlist.name,
        'userId': playlist.author,
        'tracklist': playlist.list.map((track) => track.id).toList(),
      });
    } catch (error) {
      print("Error creating playlist: $error");
      // Handle error as necessary
    }
  }

  static Future<void> updateFavorites(QawlUser user, Track track) async {
    try {
      // Query Firestore for the "Favorites" playlist of the user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('QawlPlaylists')
          .where('userId', isEqualTo: user.id)
          .where('name', isEqualTo: 'Favorites')
          .limit(1) // Assuming there's only one "Favorites" playlist per user
          .get();

      // Check if the "Favorites" playlist exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get the document reference of the "Favorites" playlist
        DocumentReference playlistRef = querySnapshot.docs.first.reference;

        // Update the tracklist field by adding the track ID
        await playlistRef.update({
          'tracklist': FieldValue.arrayUnion([track.id]),
        });
      } else {
        String uniqueID = Uuid().v4();
        // "Favorites" playlist does not exist, create it
        await FirebaseFirestore.instance.collection('QawlPlaylists').add({
          'name': 'Favorites',
          'id': uniqueID,
          'userId': user.id,
          'tracklist': [track.id],
        });
      }
    } catch (error) {
      print("Error updating favorites: $error");
      // Handle error as necessary
    }
  }

  void removeTrack(Track track) {
    if (!empty()) {
      list.remove(track);
    } else {
      print("you can't remove from an empty list!");
    }
  }

  static Future<void> removeTrackFromPlaylist(
      QawlPlaylist playlist, Track track) async {
    try {
      await FirebaseFirestore.instance
          .collection('QawlPlaylists')
          .doc(playlist.id)
          .update({
        'tracklist': FieldValue.arrayRemove([track.id])
      });
      playlist.list.remove(track);
      print(
          'Track with ID ${track.id} deleted successfully from playlist ${playlist.id}');
    } catch (e) {
      print('Error deleting track: $e');
    }
  }

  String getAuthor() {
    return author;
  }

  String getName() {
    return name;
  }
  //String getSurah() {
  //return surah;
  // }

  int getCount() {
    return list.length;
  }

  bool empty() {
    return list.isEmpty;
  }

  static Future<QawlPlaylist> getTop100Playlist() async {
    QawlUser? currUser = await QawlUser.getCurrentQawlUser();
    // Fetch top 100 tracks from Firestore and create a Playlist object
    List<Track> topTracks =
        await fetchTopTracks(currUser!.gender); // Implement this method
    return QawlPlaylist(
        author: "Top 100", name: "Top 100", id: '0', list: topTracks);
  }

  static Future<QawlPlaylist> getNewReleasesPlaylist() async {
    QawlUser? currUser = await QawlUser.getCurrentQawlUser();
    // Fetch new releases from Firestore and create a Playlist object
    List<Track> newReleases =
        await fetchNewReleases(currUser!.gender); // Implement this method
    return QawlPlaylist(
        author: "New Releases",
        name: "New Releases",
        id: '0',
        list: newReleases);
  }
  //no gender ver
  // static Future<List<Track>> fetchTopTracks(String gender) async {
  //   try {
  //     // Query Firestore to get top tracks based on plays count
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('QawlTracks')
  //         .orderBy('plays',
  //             descending: true) // Order by plays count in descending order
  //         .limit(100) // Limit to top 100 tracks
  //         .get();

  //     // Map each document snapshot to a Track object
  //     List<Track> topTracks = querySnapshot.docs.map((doc) {
  //       return Track.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  //     }).toList();

  //     return topTracks;
  //   } catch (e) {
  //     print("Error fetching top tracks: $e");
  //     return [];
  //   }
  // }
  static Future<List<Track>> fetchTopTracks(String gender) async {
    try {
      // Query Firestore to get top tracks based on plays count
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('QawlTracks')
          .orderBy('plays',
              descending: true) // Order by plays count in descending order
          .limit(100) // Limit to top 100 tracks
          .get();

      // If gender is 'f', return all top tracks
      if (gender == 'f') {
        List<Track> topTracks = querySnapshot.docs
            .map((doc) =>
                Track.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        return topTracks;
      }

      // Get the user IDs of authors with the specified gender
      List<String> userIds = [];
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .where('gender', isEqualTo: 'm')
          .get();
      userQuerySnapshot.docs.forEach((doc) {
        userIds.add(doc.id);
      });

      // Filter top tracks based on the user IDs with matching gender
      List<Track> topTracks = querySnapshot.docs
          .where((doc) => userIds.contains(doc.get('userId')))
          .map((doc) =>
              Track.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return topTracks;
    } catch (e) {
      print("Error fetching top tracks: $e");
      return [];
    }
  }

  //no gender ver
  // static Future<List<Track>> fetchNewReleases(String gender) async {
  //   try {
  //     // Calculate the timestamp for one week ago
  //     DateTime twoWeeksAgo = DateTime.now().subtract(Duration(days: 14));

  //     // Query Firestore to get new releases published in the last week
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('QawlTracks')
  //         .where('timeStamp',
  //             isGreaterThan:
  //                 twoWeeksAgo) // Filter tracks published in the last week
  //         .orderBy('timeStamp',
  //             descending: true) // Order by timestamp in descending order
  //         .limit(100) // Limit to the latest 100 tracks
  //         .get();

  //     // Map each document snapshot to a Track object
  //     List<Track> newReleases = querySnapshot.docs.map((doc) {
  //       return Track.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  //     }).toList();

  //     return newReleases;
  //   } catch (e) {
  //     print("Error fetching new releases: $e");
  //     return [];
  //   }
  // }
  static Future<List<Track>> fetchNewReleases(String gender) async {
    try {
      // Calculate the timestamp for two weeks ago
      DateTime threeWeeksAgo = DateTime.now().subtract(Duration(days: 28));

      // Query Firestore to get new releases published in the last two weeks
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('QawlTracks')
          .where('timeStamp',
              isGreaterThan:
                  threeWeeksAgo) // Filter tracks published in the last two weeks
          .orderBy('timeStamp',
              descending: true) // Order by timestamp in descending order
          .limit(100) // Limit to the latest 100 tracks
          .get();

      // If gender is 'f', return all new releases
      if (gender == 'f') {
        List<Track> newReleases = querySnapshot.docs
            .map((doc) =>
                Track.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        return newReleases;
      }

      // Get the user IDs of authors with the specified gender
      List<String> userIds = [];
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .where('gender', isEqualTo: 'm')
          .get();
      userQuerySnapshot.docs.forEach((doc) {
        userIds.add(doc.id);
      });

      // Filter new releases based on the user IDs with matching gender
      List<Track> newReleases = querySnapshot.docs
          .where((doc) => userIds.contains(doc.get('userId')))
          .map((doc) =>
              Track.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return newReleases;
    } catch (e) {
      print("Error fetching new releases: $e");
      return [];
    }
  }

  static Future<QawlPlaylist> getStylesPlaylist(String style) async {
    try {
      // Step 1: Get the current user's gender
      QawlUser? currentUser = await QawlUser.getCurrentQawlUser();
      String? currentUserGender = currentUser?.gender;

      if (currentUserGender == null) {
        print("Current user gender is null.");
        return QawlPlaylist(
          author: "System",
          name: "Error Playlist",
          list: [],
          id: Uuid().v4(),
        );
      }

      // Step 2: Query Firestore to get all user IDs with the same gender
      QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .where('gender', isEqualTo: currentUserGender)
          .get();

      List<String> userIds =
          userQuerySnapshot.docs.map((doc) => doc.id).toList();

      if (userIds.isEmpty) {
        print("No users found with the specified gender.");
        return QawlPlaylist(
          author: "System",
          name: "No Tracks Playlist",
          list: [],
          id: Uuid().v4(),
        );
      }

      // Step 3: Query all tracks and filter manually for matching style and userId
      QuerySnapshot trackQuerySnapshot = await FirebaseFirestore.instance
          .collection('QawlTracks')
          .where('style', isEqualTo: style)
          .get();

      List<Track> tracks = trackQuerySnapshot.docs
          .where((doc) => userIds.contains(doc['userId']))
          .map((doc) =>
              Track.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Step 4: Create and return the playlist
      return QawlPlaylist(
        author: "System",
        name: "$style",
        list: tracks,
        id: Uuid().v4(),
      );
    } catch (error) {
      print("Error fetching playlist for style '$style': $error");
      return QawlPlaylist(
        author: "System",
        name: "Error Playlist",
        list: [],
        id: Uuid().v4(),
      );
    }
  }

  static Future<QawlPlaylist> getFollowingPlaylist() async {
    QawlUser? currentUser = await QawlUser.getCurrentQawlUser();
    List<Track> tracks = [];

    if (currentUser != null) {
      List<String> followingUserIds = currentUser.following.toList();

      if (followingUserIds.isNotEmpty) {
        // Fetch tracks without ordering
        QuerySnapshot trackSnapshot = await FirebaseFirestore.instance
            .collection('QawlTracks')
            .where('userId', whereIn: followingUserIds)
            // .orderBy('timeStamp', descending: true)
            .get();

        // Map documents to Track objects
        tracks = trackSnapshot.docs.map((doc) {
          return Track.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // sort by newest first
        tracks.sort((a, b) {
          if (a.timeStamp == null || b.timeStamp == null) {
            return 0; 
          }
          return b.timeStamp!.compareTo(a.timeStamp!);
        });
      }
    }

    return QawlPlaylist(
      author: "System",
      name: "Following",
      list: tracks,
      id: Uuid().v4(),
    );
  }

  static Future<QawlPlaylist?> getFavorites() async {
    try {
      QawlUser? user = await QawlUser.getCurrentQawlUser();
      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('QawlPlaylists')
            .where('userId', isEqualTo: user.id)
            .where('name', isEqualTo: 'Favorites')
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot playlistDoc = querySnapshot.docs.first;
          Map<String, dynamic> data =
              playlistDoc.data() as Map<String, dynamic>;
          List<dynamic> trackIds = data['tracklist'] ?? [];
          List<Track> tracks = [];

          // Retrieve Track objects corresponding to trackIds
          for (var trackId in trackIds) {
            DocumentSnapshot trackDoc = await FirebaseFirestore.instance
                .collection('QawlTracks')
                .doc(trackId)
                .get();
            if (trackDoc.exists) {
              dynamic data = trackDoc.data(); // Get the data
              if (data is Map<String, dynamic>) {
                Track track = Track.fromFirestore(data, trackDoc.id);
                tracks.add(track);
              } else {
                // Handle the case where the data is not of type Map<String, dynamic>
                // This could be an error in your data structure or other unexpected scenario
                print('Error: Data is not of type Map<String, dynamic>');
              }
            }
          }

          return QawlPlaylist(
            author: data['userId'],
            name: data['name'],
            list: tracks,
            id: playlistDoc.id,
          );
        }
      }
      return null; // Return null if no Favorites playlist found or user is null
    } catch (error) {
      print("Error getting favorites: $error");
      return null; // Handle error as necessary
    }
  }
}
