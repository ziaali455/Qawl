import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/playlist_screen_content.dart';
import 'package:first_project/size_config.dart';
import 'package:first_project/widgets/section_title_widget.dart';
import 'package:first_project/widgets/track_widget.dart';
import 'package:flutter/material.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class PlaylistPreviewWidget extends StatelessWidget {
  final QawlPlaylist playlist;
  final bool isPersonal;
  const PlaylistPreviewWidget({
    Key? key,
    required this.playlist,
    required this.isPersonal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get a maximum of four tracks from the playlist
    List<Track> tracks = playlist.list.take(4).toList();

    // Check if tracks is empty and isPersonal is true
    if (tracks.isEmpty && isPersonal) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: WidgetAnimator(
            incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(),
            child: Text(
              'To add a recitation, press the + button in the top right corner. Then, refresh your profile to see your new upload!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getProportionateScreenWidth(12),
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }


      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        PlaylistSectionTitle(
          title: playlist.name,
          press: () {
            // Navigate to the expanded playlist with the correct isPersonal flag
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistScreenContent(
                  playlist: playlist,
                  isPersonal: isPersonal, // Pass this flag
                ),
              ),
            );
          },
          isPlaylist: true,
          playlist: playlist, isPersonal: isPersonal,
        ),
        // Track widgets
        ...tracks
            .map((track) => TrackWidget(
                  track: track,
                  isPersonal: isPersonal, // Pass this flag
                  playlist: playlist,
                ))
            .toList(),
      ],
    );
  }
}
