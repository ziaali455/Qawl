import 'package:first_project/widgets/qawl_back_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/model/playlist.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_project/blocs/now_playing/now_playing_bloc.dart';
import 'package:first_project/blocs/now_playing/now_playing_event.dart';
import 'package:first_project/blocs/now_playing/now_playing_state.dart';
import 'package:first_project/widgets/explore_track_widget_block.dart';
import 'package:share_plus/share_plus.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/profile_content.dart';

class NowPlayingPage extends StatefulWidget {
  final Track track;
  final QawlPlaylist playlist;
  final bool fromNowPlayingButton;

  const NowPlayingPage({
    super.key,
    required this.track,
    required this.playlist,
    this.fromNowPlayingButton = false,
  });

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: NowPlayingBloc.instance,
      child: _NowPlayingContent(
        track: widget.track,
        playlist: widget.playlist,
        fromNowPlayingButton: widget.fromNowPlayingButton,
      ),
    );
  }
}

class _NowPlayingContent extends StatefulWidget {
  final Track track;
  final QawlPlaylist playlist;
  final bool fromNowPlayingButton;

  const _NowPlayingContent({
    required this.track,
    required this.playlist,
    required this.fromNowPlayingButton,
  });

  @override
  State<_NowPlayingContent> createState() => _NowPlayingContentState();
}

class _NowPlayingContentState extends State<_NowPlayingContent> {
  bool _hasSwitchedTrack = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only switch to the new track if we're not coming from the now playing button
    if (!_hasSwitchedTrack && !widget.fromNowPlayingButton) {
      _hasSwitchedTrack = true;
      context
          .read<NowPlayingBloc>()
          .add(SwitchPlaylist(widget.playlist, widget.track));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NowPlayingBloc, NowPlayingState>(
      builder: (context, state) {
        // If there's an error, show it
        if (state.error != null) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${state.error}'),
            ),
          );
        }

        // If no track is playing, show the current track
        if (state.currentTrack == null) {
          return const Scaffold(
            body: Center(
              child: Text('No track selected'),
            ),
          );
        }

        final displayTitle = state.currentTrack!.trackName.isEmpty
            ? SurahMapper.getSurahNameByNumber(state.currentTrack!.surahNumber)
            : state.currentTrack!.trackName;

        return Scaffold(
          appBar: AppBar(
            leading: const Padding(
              padding: EdgeInsets.all(8.0),
              child: QawlBackButton(),
            ),
            title: const Text(
              "Now playing",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    final track = state.currentTrack!;
                    final displayTitle = track.trackName.isEmpty
                        ? SurahMapper.getSurahNameByNumber(track.surahNumber)
                        : track.trackName;

                    final appStoreLink =
                        'https://apps.apple.com/us/app/qawl/id6483754850?mt=8&text=${Uri.encodeComponent('Check out "$displayTitle" by ${state.authorName ?? 'Unknown'}')}';
                    Share.share(
                      'Check out "$displayTitle" by ${state.authorName ?? 'Unknown'} on Qawl\n\n'
                      'Download the app: $appStoreLink',
                      subject: 'Check out this track on Qawl',
                    );
                  },
                  icon: const Icon(Icons.more_vert_rounded))
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.grey[900]!,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Album Art
                    Container(
                      width: 325,
                      height: 325,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: state.currentTrack!.coverImagePath,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.question_mark_rounded,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),

                    // Track Info
                    Column(
                      children: [
                        Text(
                          displayTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (state.isLoadingAuthor)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.green,
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () async {
                              final user = await QawlUser.getQawlUser(
                                  state.currentTrack!.userId);
                              if (user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileContent(
                                      user: user,
                                      isPersonal: false,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              state.authorName ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 86, 197, 90),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),

                    // Progress Bar
                    Column(
                      children: [
                        if (state.isLoadingAudio)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          )
                        else
                          ProgressBar(
                            progress: state.position,
                            total: state.duration,
                            onSeek: (duration) {
                              context
                                  .read<NowPlayingBloc>()
                                  .add(SeekAudio(duration));
                            },
                            baseBarColor: Colors.grey[800],
                            progressBarColor:
                                const Color.fromARGB(255, 32, 220, 85),
                            bufferedBarColor: Colors.grey[600],
                            thumbColor: const Color.fromARGB(255, 32, 220, 85),
                          ),
                      ],
                    ),

                    // Playback Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: state.isShuffleEnabled
                                ? Colors.green
                                : Colors.grey[400],
                          ),
                          onPressed: () {
                            context.read<NowPlayingBloc>().add(ToggleShuffle());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white),
                          onPressed: state.isLoadingAudio
                              ? null
                              : () {
                                  context
                                      .read<NowPlayingBloc>()
                                      .add(PlayPreviousTrack());
                                },
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 13, 161, 99),
                                Color.fromARGB(255, 22, 181, 93),
                                Color.fromARGB(255, 32, 220, 85),
                              ],
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              state.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: state.isLoadingAudio
                                ? null
                                : () {
                                    if (state.isPlaying) {
                                      context
                                          .read<NowPlayingBloc>()
                                          .add(PauseAudio());
                                    } else {
                                      context
                                          .read<NowPlayingBloc>()
                                          .add(PlayAudio());
                                    }
                                  },
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.skip_next, color: Colors.white),
                          onPressed: state.isLoadingAudio
                              ? null
                              : () {
                                  context
                                      .read<NowPlayingBloc>()
                                      .add(PlayNextTrack());
                                },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.repeat,
                            color: state.isLoopEnabled
                                ? Colors.green
                                : Colors.grey[400],
                          ),
                          onPressed: () {
                            context.read<NowPlayingBloc>().add(ToggleLoop());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
