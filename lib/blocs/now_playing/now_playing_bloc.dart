import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/widgets/explore_track_widget_block.dart';
import 'package:first_project/services/unified_audio_manager.dart';
import 'now_playing_event.dart';
import 'now_playing_state.dart';

class NowPlayingBloc extends Bloc<NowPlayingEvent, NowPlayingState> {
  static NowPlayingBloc? _instance;
  final UnifiedAudioManager _audioManager = UnifiedAudioManager();
  QawlPlaylist? _playlist;
  int _currentTrackIndex = 0;
  List<int> _shuffleIndices = [];

  static NowPlayingBloc get instance {
    _instance ??= NowPlayingBloc._internal();
    return _instance!;
  }

  NowPlayingBloc._internal() : super(NowPlayingState(currentTrack: null)) {
    _initializeAudioManager();
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
    on<PlayQuizAudio>(_onPlayQuizAudio);
    on<StopQuizAudio>(_onStopQuizAudio);
    on<ResumeMainAudio>(_onResumeMainAudio);
  }

  Future<void> _initializeAudioManager() async {
    await _audioManager.initialize();
    
    // Set up callbacks for state updates
    _audioManager.setOnPlayingStateChanged((isPlaying) {
      add(UpdatePlayingState(isPlaying));
    });
    
    _audioManager.setOnPositionChanged((position) {
      add(UpdatePosition(position));
    });
    
    _audioManager.setOnDurationChanged((duration) {
      add(UpdateDuration(duration));
    });
    
    _audioManager.setOnErrorChanged((error) {
      if (error != null) {
        emit(state.copyWith(error: error));
      }
    });
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
      }
    } catch (e) {
      if (!isClosed) {
        // On error, show 'Unknown' and stop loading
        emit(state.copyWith(
          authorName: 'Unknown',
          isLoadingAuthor: false,
        ));
      }
    }
  }

  Future<void> _onInitializeAudioPlayer(
    InitializeAudioPlayer event,
    Emitter<NowPlayingState> emit,
  ) async {
    try {
      // Play main audio using unified manager
      await _audioManager.playMainAudio(state.currentTrack!, authorName: state.authorName);
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
      // Update playlist and track
      _playlist = event.newPlaylist;
      _currentTrackIndex = _playlist!.list.indexOf(event.newTrack);

      // Update state with new track first
      emit(state.copyWith(
        currentTrack: event.newTrack,
        currentPlaylist: _playlist,
        position: Duration.zero,
        duration: Duration.zero,
        isPlaying: false,
        isLoadingAudio: true,
        isLoadingAuthor: true,
        authorName: null,
      ));

      // Load author name first
      await _loadAuthorName(event.newTrack);

      // Play the new track
      await _audioManager.playMainAudio(event.newTrack, authorName: state.authorName);
    } catch (e) {
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
      await _audioManager.play();
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
      await _audioManager.pause();
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
      await _audioManager.seek(event.position);
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
    await _audioManager.stop();
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
    emit(state.copyWith(isShuffleEnabled: newShuffleState));
    
    if (newShuffleState && _playlist != null) {
      // Generate shuffle indices
      _shuffleIndices = List.generate(_playlist!.list.length, (i) => i);
      _shuffleIndices.shuffle();
      _currentTrackIndex = 0;
    }
  }

  Future<void> _onPlayNextTrack(
    PlayNextTrack event,
    Emitter<NowPlayingState> emit,
  ) async {
    if (_playlist == null) return;

    int nextIndex;
    if (state.isShuffleEnabled) {
      // Get next index from shuffle list
      nextIndex = _shuffleIndices[(_currentTrackIndex + 1) % _shuffleIndices.length];
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
      // Load author name before starting playback
      await _loadAuthorName(nextTrack);

      // Play the next track
      await _audioManager.playMainAudio(nextTrack, authorName: state.authorName);
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
      // Load author name before starting playback
      await _loadAuthorName(previousTrack);

      // Play the previous track
      await _audioManager.playMainAudio(previousTrack, authorName: state.authorName);
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoadingAudio: false,
        isLoadingAuthor: false,
      ));
    }
  }

  Future<void> _onPlayQuizAudio(
    PlayQuizAudio event,
    Emitter<NowPlayingState> emit,
  ) async {
    try {
      // Check if the same quiz audio is already playing
      if (state.isQuizAudioPlaying && 
          state.currentQuizAudioPath == event.assetPath && 
          state.isPlaying) {
        // Same audio is already playing, no need to change
        return;
      }

      // First, update state to indicate we're switching to quiz audio
      emit(state.copyWith(
        isQuizAudioPlaying: true,
        currentQuizAudioPath: event.assetPath,
        isLoadingAudio: true,
      ));

      // Play quiz audio using unified manager
      await _audioManager.playQuizAudio(event.assetPath);
      
      emit(state.copyWith(
        isQuizAudioPlaying: true,
        currentQuizAudioPath: event.assetPath,
        isPlaying: true,
        isLoadingAudio: false,
      ));
      
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to play quiz audio: $e',
        isQuizAudioPlaying: false,
        currentQuizAudioPath: null,
        isLoadingAudio: false,
      ));
    }
  }

  Future<void> _onStopQuizAudio(
    StopQuizAudio event,
    Emitter<NowPlayingState> emit,
  ) async {
    try {
      await _audioManager.stop();
      emit(state.copyWith(
        isQuizAudioPlaying: false,
        currentQuizAudioPath: null,
        isPlaying: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to stop quiz audio: $e'));
    }
  }

  Future<void> _onResumeMainAudio(
    ResumeMainAudio event,
    Emitter<NowPlayingState> emit,
  ) async {
    try {
      if (state.currentTrack != null) {
        // First, update state to indicate we're switching back to main audio
        emit(state.copyWith(
          isQuizAudioPlaying: false,
          currentQuizAudioPath: null,
          isLoadingAudio: true,
        ));

        // Resume the main track if it exists
        await _audioManager.resumeMainAudio();
        emit(state.copyWith(
          isQuizAudioPlaying: false,
          currentQuizAudioPath: null,
          isPlaying: true,
          isLoadingAudio: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to resume main audio: $e',
        isLoadingAudio: false,
      ));
    }
  }

  @override
  Future<void> close() async {
    await _audioManager.stop();
    return super.close();
  }
}
