import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/deprecated/profile_content_DEPRECATED.dart';
import 'package:first_project/size_config.dart';
import 'package:flutter/material.dart';

class NumbersWidget extends StatelessWidget {
  final QawlUser user;

  const NumbersWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildButton(context, user.followers.toString(), 'Followers'),
          ],
        ),
      ],
    );
  }

  Future<int> fetchFollowersCount(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('QawlUsers')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final followers = userDoc.get('followers');
        return followers as int? ?? 0;
      } else {
        return 0; // Return 0 if the document doesn't exist
      }
    } catch (e) {
      print("Error fetching followers count: $e");
      return 0; // Return 0 in case of an error
    }
  }

  buildButton(BuildContext context, String rank, String label) {
    return FutureBuilder<int>(
      future: fetchFollowersCount(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator while fetching data
          return CircularProgressIndicator(color: Colors.green);
        } else if (snapshot.hasError) {
          // Handle error state
          return Text('Error: ${snapshot.error}');
        } else {
          // Data fetched successfully, display the followers count
          final followers = snapshot.data ?? 0;
          return Column(
            children: [
              MaterialButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('$followers',
                        style:  TextStyle(
                            fontWeight: FontWeight.bold, fontSize: getProportionateScreenWidth(24))),
                    const SizedBox(height: 2),
                    Text('$label',
                        style:  TextStyle(
                            fontWeight: FontWeight.bold, fontSize: getProportionateScreenWidth(10))),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

// class FollowButton extends StatefulWidget {
//   const FollowButton({
//     Key? key,
//     required this.user,
//   }) : super(key: key);

//   final QawlUser user;

//   @override
//   State<FollowButton> createState() => _FollowButtonState();
// }

// // class _FollowButtonState extends State<FollowButton> {
// //   bool following = false;
// //   int followerCount = 0; // Add a local variable to keep track of follower count

// //  @override
// //   void initState() {
// //     super.initState();
// //     // Initialize the follower count
// //     followerCount = widget.user.followers;
// //   }
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(left: 120.0, right: 120.0),
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(4),
// //         child: Stack(
// //           children: <Widget>[
// //             Positioned.fill(
// //               child: Container(
// //                 decoration: const BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: <Color>[
// //                       Color.fromARGB(255, 13, 161, 99),
// //                       Color.fromARGB(255, 22, 181, 93),
// //                       Color.fromARGB(255, 32, 220, 85),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             TextButton(
// //               style: TextButton.styleFrom(
// //                 foregroundColor: Colors.white,
// //                 padding: const EdgeInsets.all(2.0),
// //                 textStyle: const TextStyle(fontSize: 15),
// //               ),
// //               onPressed: () {
// //                 setState(() {
// //                   // Toggle the following state
// //                   following = !following;

// //                 });
// //               },
// //               child: Align(
// //                 alignment: Alignment.center,
// //                 child: following
// //                     ? const Text(
// //                         "Unfollow",
// //                         style: TextStyle(
// //                           fontSize: 20.0,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       )
// //                     : const Text(
// //                         "Follow",
// //                         style: TextStyle(
// //                           fontSize: 20.0,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //  static Future<void> toggleFollow(QawlUser follower, QawlUser followed) async {
// //   try {
// //     // Check if follower is already following followed
// //     final isFollowing = follower.following.contains(followed.id);

// //     if (isFollowing) {
// //       // If already following, unfollow
// //       follower.following.remove(followed.id);
// //       followed.followers--;
// //     } else {
// //       // If not following, follow
// //       follower.following.add(followed.id);
// //       followed.followers++;
// //     }

// //     // Update network documents for follower and followed
// //     await FirebaseFirestore.instance.collection('QawlUsers').doc(follower.id).update({
// //       'following': follower.following.toList(),
// //     });
// //     await FirebaseFirestore.instance.collection('QawlUsers').doc(followed.id).update({
// //       'followers': followed.followers,
// //     });

// //   } catch (e) {
// //     // Handle errors
// //     print("Error toggling follow: $e");
// //     // You might want to throw or handle the error appropriately
// //     throw e;
// //   }
// // }
// //   Future<void> updateUserFollowerCount(String userId, int followerCount) async {
// //     try {
// //       await FirebaseFirestore.instance
// //           .collection('QawlUsers')
// //           .doc(userId)
// //           .update({'followers': followerCount});
// //     } catch (e) {
// //       print("Error updating follower count: $e");
// //       // Handle error
// //     }
// //   }
// // }
// class _FollowButtonState extends State<FollowButton> {
//   bool following = false;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the following state
//     following = widget.user.following.contains(widget.user.id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 120.0, right: 120.0),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(4),
//         child: Stack(
//           children: <Widget>[
//             Positioned.fill(
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: <Color>[
//                       Color.fromARGB(255, 13, 161, 99),
//                       Color.fromARGB(255, 22, 181, 93),
//                       Color.fromARGB(255, 32, 220, 85),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             TextButton(
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.all(2.0),
//                 textStyle: const TextStyle(fontSize: 15),
//               ),
//               onPressed: () {
//                 // Call toggleFollow method passing both follower and userBeingFollowed
//                 setState(() {
//                   following = !following;
//                 });
                
//                 toggleFollow(widget.user);
//               },
//               child: Align(
//                 alignment: Alignment.center,
//                 child: following
//                     ? const Text(
//                         "Unfollow",
//                         style: TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       )
//                     : const Text(
//                         "Follow",
//                         style: TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// }

class FollowButton extends StatefulWidget {
  final QawlUser user;

  const FollowButton({Key? key, required this.user}) : super(key: key);

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late Future<bool> _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = _checkIfFollowing();
  }

  Future<bool> _checkIfFollowing() async {
    // Get the current user
    QawlUser? currentUser = await QawlUser.getCurrentQawlUser();

    // Check if the current user's following list contains the user parameter
    return currentUser!.following.contains(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 120.0, right: 120.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color.fromARGB(255, 13, 161, 99),
                      Color.fromARGB(255, 22, 181, 93),
                      Color.fromARGB(255, 32, 220, 85),
                    ],
                  ),
                ),
              ),
            ),
            FutureBuilder<bool>(
              future: _isFollowing,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(color: Colors.green);
                } else {
                  return TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(2.0),
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    onPressed: () {
                      // Call toggleFollow method passing both follower and userBeingFollowed
                      setState(() {
                        // Toggling the following status
                        _isFollowing = Future.value(!snapshot.data!);
                      });
                      toggleFollow(widget.user);
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: snapshot.data == true
                          ? const Text(
                              "Unfollow",
                              style: TextStyle(fontFamily: "PPTelegraf",
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Text(
                              "Follow",
                              style: TextStyle(fontFamily: "PPTelegraf",
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  static Future<void> toggleFollow(QawlUser userBeingFollowed) async {
    try {
      QawlUser? follower = await QawlUser.getCurrentQawlUser();
      // Check if follower is already following followed
      final isFollowing = follower!.following.contains(userBeingFollowed.id);

      if (isFollowing) {
        // If already following, unfollow
        follower.following.remove(userBeingFollowed.id);
        userBeingFollowed.followers--;
      } else {
        // If not following, follow
        follower.following.add(userBeingFollowed.id);
        userBeingFollowed.followers++;
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
          .doc(userBeingFollowed.id)
          .update({
        'followers': userBeingFollowed.followers,
      });
    } catch (e) {
      // Handle errors
      print("Error toggling follow: $e");
      // You might want to throw or handle the error appropriately
      throw e;
    }
  }
}
