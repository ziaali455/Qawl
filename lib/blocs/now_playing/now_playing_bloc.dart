import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/widgets/explore_track_widget_block.dart';
import 'now_playing_event.dart';
import 'now_playing_state.dart';

class NowPlayingBloc extends Bloc<NowPlayingEvent, NowPlayingState> {
  static NowPlayingBloc? _instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioSession? _audioSession;
  Track? _track;
  QawlPlaylist? _playlist;
  int _currentTrackIndex = 0;
  List<int> _shuffleIndices = [];

  static NowPlayingBloc get instance {
    _instance ??= NowPlayingBloc._internal();
    return _instance!;
  }

  NowPlayingBloc._internal() : super(NowPlayingState(currentTrack: null)) {
    _initializeAudioSession();
    on<InitializeAudioPlayer>(_onInitializeAudioPlayer);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<SeekAudio>(_onSeekAudio);
    on<UpdatePosition>(_onUpdatePosition);
    on<UpdateDuration>(_onUpdateDuration);
    on<UpdatePlayingState>(_onUpdatePlayingState);
    on<LoadAuthorName>(_onLoadAuthorName);
    on<UpdateAuthorName>(_onUpdateAuthorName);
    on<DisposeAudioPlayer>(_onDisposeAudioPlayer);
    on<PlayNextTrack>(_onPlayNextTrack);
    on<PlayPreviousTrack>(_onPlayPreviousTrack);
    on<SwitchPlaylist>(_onSwitchPlaylist);
    on<ToggleLoop>(_onToggleLoop);
    on<ToggleShuffle>(_onToggleShuffle);

    // Set up audio player listeners
    _audioPlayer.positionStream.listen((position) {
      add(UpdatePosition(position));
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        add(UpdateDuration(duration));
      }
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      add(UpdatePlayingState(playerState.playing));

      // Check if the track has finished playing
      if (playerState.processingState == ProcessingState.completed) {
        if (state.isLoopEnabled) {
          // If loop is enabled, replay the current track
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else {
          // Otherwise, play the next track
          add(PlayNextTrack());
        }
      }
    });
  }

  Future<void> _initializeAudioSession() async {
    _audioSession = await AudioSession.instance;
    await _audioSession?.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    // Handle audio interruptions
    _audioSession?.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // Another app started playing audio and we should duck
            _audioPlayer.setVolume(0.5);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            // Another app started playing audio and we should pause
            add(PauseAudio());
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // The interruption ended and we should unduck
            _audioPlayer.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            // The interruption ended and we should resume
            add(PlayAudio());
            break;
          case AudioInterruptionType.unknown:
            // The interruption ended but we should not resume
            break;
        }
      }
    });

    // Handle when headphones are unplugged
    _audioSession?.becomingNoisyEventStream.listen((_) {
      add(PauseAudio());
    });

    // Handle background media controls
    await _audioSession?.setActive(true);

    // Set up background media controls
    await _audioPlayer.setLoopMode(LoopMode.off);
    await _audioPlayer.setShuffleModeEnabled(false);

    // Set up background mode
    await _audioPlayer.setVolume(1.0);
  }

  MediaItem _getMediaItem(Track? track, String? authorName) {
    if (track == null) return MediaItem(id: '', title: '');
    return MediaItem(
      id: track.id,
      title: track.trackName.isNotEmpty
          ? track.trackName
          : SurahMapper.getSurahNameByNumber(track.surahNumber),
      artist: authorName ?? 'Unknown',
      artUri: Uri.parse(track.coverImagePath),
    );
  }

  void _updateMediaItem(Track track, String authorName) {
    final mediaItem = _getMediaItem(track, authorName);
    _audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(track.audioPath),
        tag: mediaItem,
      ),
    );
  }

  Future<void> _loadAuthorName(Track track) async {
    try {
      // Set loading state for author name
      emit(state.copyWith(
        authorName: null,
        isLoadingAuthor: true,
      ));

      final authorName = await track.getAuthor();
      if (!isClosed) {
        // Update state with the author name, or 'Unknown' if null/empty
        final finalAuthorName = authorName ?? 'Unknown';
        emit(state.copyWith(
          authorName: finalAuthorName,
          isLoadingAuthor: false,
        ));

        // Update media item with the new author name
        _updateMediaItem(track, finalAuthorName);
      }
    } catch (e) {
      if (!isClosed) {
        // On error, show 'Unknown' and stop loading
        emit(state.copyWith(
          authorName: 'Unknown',
          isLoadingAuthor: false,
        ));
        // Update media item with 'Unknown' author
        _updateMediaItem(track, 'Unknown');
      }
    }
  }

  Future<void> _onInitializeAudioPlayer(
    InitializeAudioPlayer event,
    Emitter<NowPlayingState> emit,
  ) async {
    try {
      // Create MediaItem for the track
      final mediaItem = MediaItem(
        id: state.currentTrack!.id,
        title: state.currentTrack!.trackName.isNotEmpty
            ? state.currentTrack!.trackName
            : SurahMapper.getSurahNameByNumber(state.currentTrack!.surahNumber),
        artist: state.authorName ?? 'Unknown',
        artUri: Uri.parse(state.currentTrack!.coverImagePath),
      );

      // Set the audio source with the MediaItem
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(event.audioUrl),
          tag: mediaItem,
        ),
      );

      // Set up background media controls
      await _audioPlayer.setLoopMode(LoopMode.off);
      await _audioPlayer.setShuffleModeEnabled(false);

      // Enable background media controls
      await _audioSession?.setActive(true);

      // Set up media controls
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();

      emit(state.copyWith(isPlaying: true));
      // Load author name immediately after initialization
      await _loadAuthorName(state.currentTrack!);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSwitchPlaylist(
    SwitchPlaylist event,
    Emitter<NowPlayingState> emit,
  ) async {
    try {
      // print('Switching playlist to track: ${event.newTrack.id}');
      // Stop current playback
      await _audioPlayer.stop();

      // Update playlist and track
      _playlist = event.newPlaylist;
      _track = event.newTrack;
      _currentTrackIndex = _playlist!.list.indexOf(_track!);

      // Update state with new track first
      emit(state.copyWith(
        currentTrack: _track,
        currentPlaylist: _playlist,
        position: Duration.zero,
        duration: Duration.zero,
        isPlaying: false,
        isLoadingAudio: true,
        isLoadingAuthor: true,
        authorName: null,
      ));

      // Load author name first
      await _loadAuthorName(_track!);
      // print('Author name loaded, starting playback');

      // Create MediaItem for the track
      final mediaItem = MediaItem(
        id: _track!.id,
        title: _track!.trackName.isNotEmpty
            ? _track!.trackName
            : SurahMapper.getSurahNameByNumber(_track!.surahNumber),
        artist: state.authorName ?? 'Unknown',
        artUri: Uri.parse(_track!.coverImagePath),
      );

      // Set the audio source with the MediaItem
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(_track!.audioPath),
          tag: mediaItem,
        ),
      );

      await _audioPlayer.play();
    } catch (e) {
      // print('Error switching playlist: $e');
      emit(state.copyWith(
        error: e.toString(),
        isLoadingAudio: false,
        isLoadingAuthor: false,
      ));
    }
  }

  Future<void> _onPlayAudio(
    PlayAudio event,
    Emitter<NowPlayingState> emit,
  ) async {
    try {
      await _audioPlayer.play();
      emit(state.copyWith(isPlaying: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onPauseAudio(
    PauseAudio event,
    Emitter<NowPlayingState> emit,
  ) async {
    try {
      await _audioPlayer.pause();
      emit(state.copyWith(isPlaying: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSeekAudio(
    SeekAudio event,
    Emitter<NowPlayingState> emit,
  ) async {
    try {
      await _audioPlayer.seek(event.position);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onUpdatePosition(
    UpdatePosition event,
    Emitter<NowPlayingState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  void _onUpdateDuration(
    UpdateDuration event,
    Emitter<NowPlayingState> emit,
  ) {
    emit(state.copyWith(
      duration: event.duration,
      isLoadingAudio: false,
    ));
  }

  void _onUpdatePlayingState(
    UpdatePlayingState event,
    Emitter<NowPlayingState> emit,
  ) {
    emit(state.copyWith(isPlaying: event.isPlaying));
  }

  Future<void> _onLoadAuthorName(
    LoadAuthorName event,
    Emitter<NowPlayingState> emit,
  ) async {
    await _loadAuthorName(state.currentTrack!);
  }

  void _onUpdateAuthorName(
    UpdateAuthorName event,
    Emitter<NowPlayingState> emit,
  ) {
    emit(state.copyWith(
      authorName: event.authorName,
    ));
  }

  Future<void> _onDisposeAudioPlayer(
    DisposeAudioPlayer event,
    Emitter<NowPlayingState> emit,
  ) async {
    await _audioPlayer.dispose();
  }

  Future<void> _onToggleLoop(
    ToggleLoop event,
    Emitter<NowPlayingState> emit,
  ) async {
    final newLoopState = !state.isLoopEnabled;
    emit(state.copyWith(isLoopEnabled: newLoopState));
  }

  Future<void> _onToggleShuffle(
    ToggleShuffle event,
    Emitter<NowPlayingState> emit,
  ) async {
    final newShuffleState = !state.isShuffleEnabled;

    if (newShuffleState) {
      // Generate shuffle indices when enabling shuffle
      _shuffleIndices = List.generate(_playlist!.list.length, (index) => index);
      _shuffleIndices.shuffle();
      // Find current track's position in shuffle indices
      _currentTrackIndex = _shuffleIndices.indexOf(_currentTrackIndex);
    } else {
      // When disabling shuffle, convert current shuffle index back to playlist index
      _currentTrackIndex = _shuffleIndices[_currentTrackIndex];
    }

    emit(state.copyWith(isShuffleEnabled: newShuffleState));
  }

  Future<void> _onPlayNextTrack(
    PlayNextTrack event,
    Emitter<NowPlayingState> emit,
  ) async {
    if (_playlist == null) return;

    int nextIndex;
    if (state.isShuffleEnabled) {
      // Get next index from shuffle list
      nextIndex =
          _shuffleIndices[(_currentTrackIndex + 1) % _shuffleIndices.length];
    } else {
      // Get next index from playlist
      nextIndex = (_currentTrackIndex + 1) % _playlist!.list.length;
    }

    _currentTrackIndex = nextIndex;
    final nextTrack = _playlist!.list[_currentTrackIndex];

    // Update state first to show loading state
    emit(state.copyWith(
      position: Duration.zero,
      duration: Duration.zero,
      isPlaying: false,
      currentTrack: nextTrack,
      isLoadingAudio: true,
      isLoadingAuthor: true,
      authorName: null,
    ));

    try {
      // Create MediaItem for the track
      final mediaItem = _getMediaItem(nextTrack, state.authorName);

      // Set the audio source with the MediaItem
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(nextTrack.audioPath),
          tag: mediaItem,
        ),
      );

      // Load author name before starting playback
      await _loadAuthorName(nextTrack);

      // Ensure audio session is still active before playing
      await _audioSession?.setActive(true);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoadingAudio: false,
        isLoadingAuthor: false,
      ));
    }
  }

  Future<void> _onPlayPreviousTrack(
    PlayPreviousTrack event,
    Emitter<NowPlayingState> emit,
  ) async {
    if (_playlist == null) return;

    int previousIndex;
    if (state.isShuffleEnabled) {
      // Get previous index from shuffle list
      previousIndex = _shuffleIndices[
          (_currentTrackIndex - 1 + _shuffleIndices.length) %
              _shuffleIndices.length];
    } else {
      // Get previous index from playlist
      previousIndex = (_currentTrackIndex - 1 + _playlist!.list.length) %
          _playlist!.list.length;
    }

    _currentTrackIndex = previousIndex;
    final previousTrack = _playlist!.list[_currentTrackIndex];

    // Update state first to show loading state
    emit(state.copyWith(
      position: Duration.zero,
      duration: Duration.zero,
      isPlaying: false,
      currentTrack: previousTrack,
      isLoadingAudio: true,
      isLoadingAuthor: true,
      authorName: null,
    ));

    try {
      // Create MediaItem for the track
      final mediaItem = _getMediaItem(previousTrack, state.authorName);

      // Set the audio source with the MediaItem
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(previousTrack.audioPath),
          tag: mediaItem,
        ),
      );

      // Load author name before starting playback
      await _loadAuthorName(previousTrack);

      // Ensure audio session is still active before playing
      await _audioSession?.setActive(true);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoadingAudio: false,
        isLoadingAuthor: false,
      ));
    }
  }
}
