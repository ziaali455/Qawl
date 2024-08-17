import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/size_config.dart';
import 'package:first_project/widgets/track_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:first_project/deprecated/fake_track_data.dart';

import '../neu_box.dart';

class PlaylistScreenContent extends StatefulWidget {
  //final String playlistTitle;
  final QawlPlaylist playlist;
  final bool isPersonal; // Added this flag

  //refactor playlistTitle

  const PlaylistScreenContent({Key? key, required this.playlist, required this.isPersonal})
      : super(key: key);

   @override
  State<PlaylistScreenContent> createState() =>
      _PlaylistScreenContentState(playlist, isPersonal); // Pass flag to state
}

class _PlaylistScreenContentState extends State<PlaylistScreenContent> {
  late QawlPlaylist playlist;
    final bool isPersonal; // Store this flag

  _PlaylistScreenContentState(QawlPlaylist playlist, this.isPersonal) {
    this.playlist = playlist;
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(children: [
            // back button and menu button
            const SizedBox(height: 50),
            QawlBackButton(),

            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  playlist.getName(),
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            //insert for loop that goes through playlist parameter and populates track widgets HERE.
            for (Track track in playlist.list)
              Material(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: TrackWidget(
                    track: track,
                    isPersonal: isPersonal,
                    playlist: playlist,
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class RemoveFromPlaylistButton extends StatelessWidget {
  const RemoveFromPlaylistButton({
    super.key,
    required this.playlist,
    required this.track
  });

  final QawlPlaylist playlist;
  final Track track;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.highlight_remove_rounded, color: Colors.green),
      onPressed: () {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text("Confirm Deletion"),
              content: const Text("Are you sure you want to remove this track from your playlist?"),
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
                  onPressed: () async {
                    // Handle delete action here
                    await QawlPlaylist.removeTrackFromPlaylist(playlist, track);
                    //Track.deleteTrack(track); // Assuming you have a deleteTrack method
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
