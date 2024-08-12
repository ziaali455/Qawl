import 'package:first_project/model/player.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/screens/playlist_screen_content.dart';
import 'package:first_project/widgets/explore_track_widget_block.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:first_project/model/track.dart';

//FIX THE TEXT UPDATING TO GREEN WHEN U TAP IT
class TrackWidget extends StatelessWidget {
  final Track track;
  final bool isPersonal;
  final QawlPlaylist playlist;
  const TrackWidget({
    Key? key,
    required this.track,
    required this.isPersonal,
    required this.playlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print("the user id is " + track.userId);
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: InkWell(
        onTap: () {
          playTrackWithList(track, playlist);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NowPlayingContent(playedTrack: track)),
          );
        },
        child: FutureBuilder<QawlUser?>(
          future: QawlUser.getQawlUser(track.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                  color: Colors.green); // Placeholder while loading
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final user = snapshot.data;
              if (user != null) {
                return Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          user.imagePath.isNotEmpty
                              ? user.imagePath
                              : 'https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      SurahMapper.getSurahNameByNumber(track.surahNumber),
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    subtitle: Text(user.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Ensures the row takes up only the necessary space
                      children: [
                        if (isPersonal) TrashButtonWidget(track: track),
                        if (playlist.getName() == 'Favorites')
                          RemoveFromPlaylistButton(
                              playlist: playlist, track: track),
                      ],
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                );
              } else {
                return const Text(
                    'User not found with userID: '); // Handle case where user is null
              }
            }
          },
        ),
      ),
    );
  }

  Widget buildCoverImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10), // Image border
      child: SizedBox.fromSize(
        // Image radius
        child: Image.network(track.coverImagePath, fit: BoxFit.cover),
      ),
    );
  }

  Widget buildTitle(bool isPlaying) {
    Color titleColor;
    if (trackIsPlaying()) {
      titleColor = Colors.green;
    } else {
      titleColor = Colors.white;
    }
    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
      child: Text(
        track.trackName,
        style: TextStyle(fontSize: 20, color: titleColor),
      ),
    );
  }

  //boolean input not count
}

class TrashButtonWidget extends StatelessWidget {
  const TrashButtonWidget({
    super.key,
    required this.track,
  });

  final Track track;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline_rounded, color: Colors.green),
      onPressed: () {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text("Confirm Deletion"),
              content: const Text("Are you sure you want to delete?"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text(
                    "No",
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                CupertinoDialogAction(
                  child: const Text(
                    "Yes",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    // Handle delete action here
                    // For example:
                    Track.deleteTrack(
                        track); // Assuming you have a deleteTrack method
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
      splashColor: Colors.transparent,
    );
  }
}

//potentially a better track widget visually?
// Card(
//         child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const ListTile(
//           leading: Icon(Icons.album),
//           title: Text('The Enchanted Nightingale'),
//           subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
//         ),
//       ],
//     ));
