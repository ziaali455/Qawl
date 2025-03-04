import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_project/blocs/now_playing/now_playing_bloc.dart';
import 'package:first_project/blocs/now_playing/now_playing_state.dart';
import 'package:first_project/screens/now_playing_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/widgets/explore_track_widget_block.dart';

class NowPlayingButton extends StatelessWidget {
  const NowPlayingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NowPlayingBloc, NowPlayingState>(
      builder: (context, state) {
        // Only show the button if there's a track playing
        if (state.currentTrack == null || !state.isPlaying) {
          return const SizedBox.shrink();
        }

        final displayTitle = state.currentTrack!.trackName.isEmpty
            ? SurahMapper.getSurahNameByNumber(state.currentTrack!.surahNumber)
            : state.currentTrack!.trackName;

        return Stack(
          children: [
            Positioned(
              bottom: 0, // Position right at the bottom, above the tab bar
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  // Simply navigate to the Now Playing page without affecting playback
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NowPlayingPage(
                        track: state.currentTrack!,
                        playlist: state.currentPlaylist!,
                        fromNowPlayingButton: true,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 13, 161, 99),
                        Color.fromARGB(255, 22, 181, 93),
                        Color.fromARGB(255, 32, 220, 85),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Album Art
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CachedNetworkImage(
                              imageUrl: state.currentTrack!.coverImagePath,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[800],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Track Info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (state.isLoadingAuthor)
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.green,
                                  ),
                                )
                              else
                                Text(
                                  state.authorName ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
