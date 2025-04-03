import 'package:first_project/model/player.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/widgets/explore_track_widget_block.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:first_project/model/track.dart';

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
                    subtitle: Text(user.name,
                        style: TextStyle(overflow: TextOverflow.ellipsis)),
                    trailing: _buildTrailingButton(context),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                );
              } else {
                return const Text('User not found');
              }
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildTrailingButton(BuildContext context) {
    if (isPersonal && playlist.name == "Uploads") {
      return TrashButtonWidget(track: track);
    } else if (playlist.name != "Uploads") {
      return RemoveFromPlaylistButton(
        playlist: playlist,
        track: track,
      );
    } else {
      return const SizedBox.shrink(); // Empty widget if none of the conditions match
    }
  }
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
              content: const Text("Are you sure you want to permanently delete this upload? This action cannot be undone."),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                CupertinoDialogAction(
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    // Handle delete action
                    Track.deleteTrack(track);
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

class RemoveFromPlaylistButton extends StatelessWidget {
  final QawlPlaylist playlist;
  final Track track;

  const RemoveFromPlaylistButton({
    Key? key,
    required this.playlist,
    required this.track,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.remove_circle_outline, color: Colors.green),
      onPressed: () {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text("Remove from Playlist"),
              content: Text("Remove '${SurahMapper.getSurahNameByNumber(track.surahNumber)}' from '${playlist.name}'?"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: const Text(
                    "Remove",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await QawlPlaylist.removeTrackFromPlaylist(playlist, track);
                    Navigator.of(context).pop();
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