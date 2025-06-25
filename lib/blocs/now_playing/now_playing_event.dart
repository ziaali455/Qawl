import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';

abstract class NowPlayingEvent {}

class InitializeAudioPlayer extends NowPlayingEvent {
  final String audioUrl;
  InitializeAudioPlayer(this.audioUrl);
}

class PlayAudio extends NowPlayingEvent {}

class PauseAudio extends NowPlayingEvent {}

class SeekAudio extends NowPlayingEvent {
  final Duration position;
  SeekAudio(this.position);
}

class UpdatePosition extends NowPlayingEvent {
  final Duration position;
  UpdatePosition(this.position);
}

class UpdateDuration extends NowPlayingEvent {
  final Duration duration;
  UpdateDuration(this.duration);
}

class UpdatePlayingState extends NowPlayingEvent {
  final bool isPlaying;
  UpdatePlayingState(this.isPlaying);
}

class LoadAuthorName extends NowPlayingEvent {}

class UpdateAuthorName extends NowPlayingEvent {
  final String authorName;
  UpdateAuthorName(this.authorName);
}

class DisposeAudioPlayer extends NowPlayingEvent {}

class PlayNextTrack extends NowPlayingEvent {}

class PlayPreviousTrack extends NowPlayingEvent {}

class SwitchPlaylist extends NowPlayingEvent {
  final QawlPlaylist newPlaylist;
  final Track newTrack;
  SwitchPlaylist(this.newPlaylist, this.newTrack);
}

class ToggleLoop extends NowPlayingEvent {}

class ToggleShuffle extends NowPlayingEvent {}

// Quiz audio events
class PlayQuizAudio extends NowPlayingEvent {
  final String assetPath;
  PlayQuizAudio(this.assetPath);
}

class StopQuizAudio extends NowPlayingEvent {}

class ResumeMainAudio extends NowPlayingEvent {}
