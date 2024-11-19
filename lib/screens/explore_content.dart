
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/widgets/search_field.dart';
import 'package:first_project/widgets/explore_track_widget_block.dart';
import 'package:first_project/widgets/section_title_widget.dart';
import 'package:first_project/widgets/track_widget.dart';
import 'package:flutter/material.dart';
import 'package:first_project/deprecated/fake_user_data.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/size_config.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../widgets/categories_widget.dart';
import '../widgets/qari_card_widget.dart';

class ExploreContent extends StatefulWidget {
  const ExploreContent({Key? key}) : super(key: key);

  @override
  State<ExploreContent> createState() => _ExploreContentState();
}

class _ExploreContentState extends State<ExploreContent> {
  Future<QawlPlaylist>? _top100PlaylistFuture;
  Future<QawlPlaylist>? _newReleasesPlaylistFuture;
  Future<List<QawlUser>>? _searchQarisFuture;
  Future<List<Track>>? _searchTracksFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _top100PlaylistFuture = QawlPlaylist.getTop100Playlist();
    _newReleasesPlaylistFuture = QawlPlaylist.getNewReleasesPlaylist();
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
      if (newQuery.isEmpty) {
        _searchQarisFuture = null;
        _searchTracksFuture = null;
      } else {
        _searchQarisFuture = getUsersBySearchQuery(newQuery);
        _searchTracksFuture = getTracksBySearchQuery(newQuery);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double width = SizeConfig.screenWidth;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            WidgetAnimator(
                incomingEffect:
                    WidgetTransitionEffects.incomingSlideInFromTop(),
                child: SearchField(onChanged: _updateSearchQuery)),
            if (_searchQuery.isEmpty) ...[
              Categories(
                playlist:
                    QawlPlaylist(author: 'na', name: 'na', list: [], id: '0'),
              ),
              FutureBuilder<QawlPlaylist>(
                future: _top100PlaylistFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                        color: Colors.green); // Show loading indicator
                  } else if (snapshot.hasError) {
                    return Text(
                        'Error: ${snapshot.error}'); // Show error message
                  } else {
                    return ExploreTrackWidgetRow(
                      title: "Top 100",
                      playlist: snapshot.data!, isPersonal: false,
                    );
                  }
                },
              ),
              FutureBuilder<QawlPlaylist>(
                future: _newReleasesPlaylistFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                        color: Colors.green); // Show loading indicator
                  } else if (snapshot.hasError) {
                    return Text(
                        'Error: ${snapshot.error}'); // Show error message
                  } else {
                    return ExploreTrackWidgetRow(
                      title: "New Releases",
                      playlist: snapshot.data!, isPersonal: false,
                    );
                  }
                },
              ),
              SectionTitle(
                title: "Popular Reciters",
                press: () {},
              ),
              const QariCardRow(
                category: 'Featured',
              ),
            ] else ...[
              FutureBuilder<List<QawlUser>>(
                future: _searchQarisFuture,
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.green));
                  } else if (userSnapshot.hasError) {
                    return Center(child: Text('Error: ${userSnapshot.error}'));
                  } else {
                    final List<QawlUser>? users = userSnapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (users != null && users.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0),
                            child: Text(
                              'Users',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ),
                          GridView.builder(
                            padding: const EdgeInsets.all(20.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20.0,
                              mainAxisSpacing: 20.0,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return QariColumnCard(
                                user: users[index],
                                width: width / 2 - 40,
                              );
                            },
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                        ],
                      ],
                    );
                  }
                },
              ),
              FutureBuilder<List<Track>>(
                future: _searchTracksFuture,
                builder: (context, trackSnapshot) {
                  if (trackSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.green));
                  } else if (trackSnapshot.hasError) {
                    return Center(child: Text('Error: ${trackSnapshot.error}'));
                  } else {
                    final List<Track>? tracks = trackSnapshot.data;
                    if (tracks != null && tracks.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Uploads',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: tracks.length,
                            itemBuilder: (context, index) {
                              return TrackWidget(
                                track: tracks[index],
                                isPersonal: false,
                                playlist: QawlPlaylist(
                                  author: 'Search',
                                  name: 'Seach track results',
                                  list: tracks,
                                  id: 'search',
                                ),
                              );
                            },
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: Text('No results found'));

                    }
                  }
                },
              ),
              if ((_searchQarisFuture == null  && _searchTracksFuture == null))
                const Center(child: Text('No results found')),
            ],
          ],
        ),
      ),
    );
  }
}

// Future<List<QawlUser>> getUsersBySearchQuery(String query) async {
//   List<QawlUser> users = [];
//   List<QawlUser> allUsers = [];

//   try {
//     // Fetch all users (or a reasonable subset)
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('QawlUsers')
//         .get();

//     for (QueryDocumentSnapshot doc in querySnapshot.docs) {
//       allUsers.add(QawlUser.fromFirestore(doc));
//     }

//     // Convert query to lowercase
//     String lowercaseQuery = query.toLowerCase();

//     // Filter users on client-side
//     users = allUsers.where((user) {
//       return user.name.toLowerCase().contains(lowercaseQuery);
//     }).toList();
//   } catch (error) {
//     print("Error fetching users by search query: $error");
//   }
//   return users;

//   //space efficient, case insensitive
//   // List<QawlUser> users = [];

//   // try {
//   //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//   //       .collection('QawlUsers')
//   //       .where('name', isGreaterThanOrEqualTo: query)
//   //       .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//   //       .get();

//   //   for (QueryDocumentSnapshot doc in querySnapshot.docs) {
//   //     users.add(QawlUser.fromFirestore(doc));
//   //   }
//   // } catch (error) {
//   //   print("Error fetching users by search query: $error");
//   // }

//   // return users;
// }
Future<List<QawlUser>> getUsersBySearchQuery(String query) async {
  List<QawlUser> users = [];
  List<QawlUser> allUsers = [];

  try {
    // Fetch the current user
    QawlUser? currentUser = await QawlUser.getCurrentQawlUser();
    if (currentUser == null) {
      throw Exception("Current user not found");
    }

    String currentUserGender = currentUser.gender;

    // Fetch all users (or a reasonable subset)
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('QawlUsers').get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      allUsers.add(QawlUser.fromFirestore(doc));
    }

    // Convert query to lowercase
    String lowercaseQuery = query.toLowerCase();
    print("CURRENT GENDER IS " + currentUser.gender);
    // Filter users on client-side
    users = allUsers.where((user) {
      bool notMe = user.id != currentUser.id;
      bool matchesQuery = user.name.toLowerCase().contains(lowercaseQuery);
      bool matchesGender = user.gender == currentUserGender;
      bool isVerified = user.isVerified == true;
      return matchesQuery && matchesGender && notMe && isVerified;
    }).toList();
  } catch (error) {
    print("Error fetching users by search query: $error");
  }
  return users;

//space efficient, case insensitive
  // List<QawlUser> users = [];

  // try {
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('QawlUsers')
  //       .where('name', isGreaterThanOrEqualTo: query)
  //       .where('name', isLessThanOrEqualTo: query + '\uf8ff')
  //       .get();

  //   for (QueryDocumentSnapshot doc in querySnapshot.docs) {
  //     users.add(QawlUser.fromFirestore(doc));
  //   }
  // } catch (error) {
  //   print("Error fetching users by search query: $error");
  // }

  // return users;
}

Future<List<Track>> getTracksBySearchQuery(String query) async {
  List<Track> tracks = [];
  List<Track> allTracks = [];

  try {
    QawlUser? currentUser = await QawlUser.getCurrentQawlUser();
    if (currentUser == null) {
      throw Exception("Current user not found");
    }
    String currentUserGender = currentUser.gender;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('QawlTracks').get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      allTracks
          .add(Track.fromFirestore(doc.data() as Map<String, dynamic>, doc.id));
    }

    String lowercaseQuery = query.toLowerCase();

    for (Track track in allTracks) {
      QawlUser? trackUser = await QawlUser.getQawlUser(track.userId);
      print(trackUser!.name);
      if (trackUser != null) {
        bool notMe = track.userId != currentUser.id;
        bool matchesQuery =
            track.trackName.toLowerCase().contains(lowercaseQuery);
        bool matchesGender = trackUser.gender == currentUserGender;
        bool isVerified = trackUser.isVerified == true;
        print("IS HE VERIFIED??: " + trackUser.isVerified.toString());
        if (matchesQuery && matchesGender && notMe && isVerified) {
          tracks.add(track);
        }
      }
    }
  } catch (error) {
    print("Error fetching tracks by search query: $error");
  }
  return tracks;
}

class QariCardRow extends StatefulWidget {
  const QariCardRow({
    Key? key,
    this.width = 175,
    this.aspectRetio = 1.02,
    required this.category,
  }) : super(key: key);

  final String category;
  final double width, aspectRetio;

  @override
  State<QariCardRow> createState() => _QariCardRowState();
}

class _QariCardRowState extends State<QariCardRow> {
  late Future<List<QawlUser>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = getTopUsersByFollowers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QawlUser>>(
      future: _futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While data is loading
          return const CircularProgressIndicator(color: Colors.green);
        } else if (snapshot.hasError) {
          // If an error occurs
          return Text('Error: ${snapshot.error}');
        } else {
          // Once data is loaded successfully
          List<QawlUser>? firstThreeUsers = snapshot.data;
          if (firstThreeUsers != null && firstThreeUsers.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(0)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: firstThreeUsers.map((user) {
                    return QariCard(width: widget.width, user: user);
                  }).toList(),
                ),
              ),
            );
          } else {
            // If no users are available
            return const Text('No users available');
          }
        }
      },
    );
  }
}

Future<List<QawlUser>> getTopUsersByFollowers() async {
  List<QawlUser> topThreeUsers = [];

  try {
    QawlUser? currUser = await QawlUser.getCurrentQawlUser(); // Await here

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('QawlUsers')
        .orderBy('followers', descending: true)
        .limit(5)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      QawlUser user = QawlUser.fromFirestore(doc);
      if (currUser != null && user.id != currUser.id) {
        topThreeUsers.add(user);
      }
    }
  } catch (e) {
    print("Error getting top three users by followers: $e");
  }

  return topThreeUsers;
}
