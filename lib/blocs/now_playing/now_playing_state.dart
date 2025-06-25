import 'package:first_project/model/track.dart';
import 'package:first_project/model/playlist.dart';

class NowPlayingState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? authorName;
  final bool isLoadingAuthor;
  final bool isLoadingAudio;
  final String? error;
  final Track? currentTrack;
  final QawlPlaylist? currentPlaylist;
  final bool isLoopEnabled;
  final bool isShuffleEnabled;
  final bool isQuizAudioPlaying;
  final String? currentQuizAudioPath;

  const NowPlayingState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.authorName,
    this.isLoadingAuthor = false,
    this.isLoadingAudio = false,
    this.error,
    this.currentTrack,
    this.currentPlaylist,
    this.isLoopEnabled = false,
    this.isShuffleEnabled = false,
    this.isQuizAudioPlaying = false,
    this.currentQuizAudioPath,
  });

  NowPlayingState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? authorName,
    bool? isLoadingAuthor,
    bool? isLoadingAudio,
    String? error,
    Track? currentTrack,
    QawlPlaylist? currentPlaylist,
    bool? isLoopEnabled,
    bool? isShuffleEnabled,
    bool? isQuizAudioPlaying,
    String? currentQuizAudioPath,
  }) {
    return NowPlayingState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      authorName: authorName ?? this.authorName,
      isLoadingAuthor: isLoadingAuthor ?? this.isLoadingAuthor,
      isLoadingAudio: isLoadingAudio ?? this.isLoadingAudio,
      error: error ?? this.error,
      currentTrack: currentTrack ?? this.currentTrack,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      isLoopEnabled: isLoopEnabled ?? this.isLoopEnabled,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      isQuizAudioPlaying: isQuizAudioPlaying ?? this.isQuizAudioPlaying,
      currentQuizAudioPath: currentQuizAudioPath ?? this.currentQuizAudioPath,
    );
  }
}
