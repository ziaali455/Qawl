import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/deprecated/fake_playlists_data.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/country_explore_content.dart';
import 'package:first_project/screens/explore_content.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/screens/playlist_screen_content.dart';
import 'package:first_project/screens/profile_content.dart';
import 'package:first_project/widgets/qari_card_widget.dart';
import 'package:flutter/material.dart';

import '../../../../size_config.dart';
import '../constants.dart';

class Categories extends StatelessWidget {
  const Categories({super.key, required this.playlist});
  final QawlPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categories = [
      {
        "icon": const Icon(
          Icons.place_outlined,
          color: Colors.green,
        ),
        "text": "Nations"
      },
      {
        "icon":
            const Icon(Icons.spatial_tracking_outlined, color: Colors.red),
        "text": "Styles"
      },
      {
        "icon": const Icon(Icons.trending_up, color: Colors.yellow),
        "text": "Trending"
      },
      
      {
        "icon": const Icon(Icons.supervised_user_circle_rounded,
            color: Colors.purple),
        "text": "Following"
      },
    ];
        SizeConfig().init(context);

    return Padding(
      
      padding: EdgeInsets.all(getProportionateScreenWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          categories.length,
          (index) => CategoryCard(
            icon: categories[index]["icon"],
            text: categories[index]["text"],
            press: () {},
            playlist: playlist,
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final QawlPlaylist playlist;
  const CategoryCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.press,
    required this.playlist,
  }) : super(key: key);

  final Icon? icon;
  final String? text;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
        SizeConfig().init(context);

    return GestureDetector(
      onTap: () {
        if (text == "Nations") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CountryExploreContent()),
            //const CountryExploreContent()),
          );
        } else if (text == "Trending") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlaceholderContent()),
            //PlaylistScreenContent(playlist: fake_playlist_data.following,)),
          );
        } else if (text == "Styles") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlaceholderContent()),
            //PlaylistScreenContent(playlist: fake_playlist_data.following,)),
          );
        } else if (text == "Following") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FollowingContent()),
            //PlaylistScreenContent(playlist: fake_playlist_data.following,)),
          );
        }
      },
      child: SizedBox(
        width: getProportionateScreenWidth(70),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(getProportionateScreenWidth(0)),
              height: getProportionateScreenWidth(55),
              width: getProportionateScreenWidth(55),
              decoration: BoxDecoration(
                color: kSecondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: icon,
            ),
            const SizedBox(
              height: 5,
              width: 30,
            ),
            Text(
              text!,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

Future<List<QawlUser>> getFollowingUsers() async {
  QawlUser? currentUser = await QawlUser.getCurrentQawlUser();
  List<QawlUser> followingUsers = [];

  if (currentUser != null) {
    List<String> followingUserIds = currentUser.following.toList();

    // Iterate over each userId in the following list
    for (String userId in followingUserIds) {
      // Skip adding the currentUser's id to the list of following users
      if (userId == currentUser.id) {
        continue;
      }

      // Query Firestore to get the QawlUser with the current userId
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(userId)
          .get();

      // If the document exists, convert it to a QawlUser object and add it to the list
      if (userSnapshot.exists) {
        QawlUser user = QawlUser.fromFirestore(userSnapshot);
        followingUsers.add(user);
      }
    }
  }

  return followingUsers;
}

class FollowingContent extends StatelessWidget {
  const FollowingContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: FutureBuilder<List<QawlUser>>(
        future: getFollowingUsers(), // Your method to fetch following Qaris
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<QawlUser>? users = snapshot.data;
            if (users != null && users.isNotEmpty) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Adjust the number of items per row
                  crossAxisSpacing: 20.0, // Adjust spacing as needed
                  mainAxisSpacing: 20.0, // Adjust spacing as needed
                  childAspectRatio: 0.75, // Adjust aspect ratio as needed
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return QariColumnCard(
                    user: users[index],
                    width: MediaQuery.of(context).size.width / 2 - 40, // Adjust width
                  );
                },
              );
            } else {
              return const Center(child: Text('No Qaris available'));
            }
          }
        },
      ),
    );
  }
}
class QariColumnCard extends StatelessWidget {
  const QariColumnCard({
    super.key,
    required this.width,
    required this.user,
  });

  final double width;
  final QawlUser user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(getProportionateScreenWidth(10)),
      child: SizedBox(
        width: getProportionateScreenWidth(width),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileContent(
                user: user,
                isPersonal: false,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: .75,
                child: Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(20)),
                  decoration: BoxDecoration(
                    color: kSecondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: "user pfp",
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              user.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Load default image when loading fails
                                return Image.network(
                                  'https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          user.name,
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(15),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class PlaceholderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenWidth(24),
                      ),
                    ),
                    SizedBox(height: 60),
                    Text(
                      '😊',
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(40),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: QawlBackButton(),
          ),
        ]),
      ),
    );
  }
}

