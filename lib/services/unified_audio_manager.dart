import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/widgets/explore_track_widget_block.dart';

enum AudioType {
  main,
  quiz,
}

class UnifiedAudioManager {
  static final UnifiedAudioManager _instance = UnifiedAudioManager._internal();
  factory UnifiedAudioManager() => _instance;
  UnifiedAudioManager._internal();

  AudioPlayer? _audioPlayer;
  AudioSession? _audioSession;
  bool _isInitialized = false;
  
  // State tracking
  AudioType _currentAudioType = AudioType.main;
  String? _currentMainAudioUrl;
  String? _currentQuizAudioPath;
  Track? _currentTrack;
  String? _currentAuthorName;
  
  // Callbacks for state updates
  Function(bool)? _onPlayingStateChanged;
  Function(Duration)? _onPositionChanged;
  Function(Duration)? _onDurationChanged;
  Function(String?)? _onErrorChanged;

  AudioPlayer get audioPlayer {
    _audioPlayer ??= AudioPlayer();
    return _audioPlayer!;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Configure audio session
      _audioSession = await AudioSession.instance;
      await _audioSession!.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth | AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      // Set up audio player
      await audioPlayer.setVolume(1.0);
      await audioPlayer.setLoopMode(LoopMode.off);
      
      // Set up listeners
      audioPlayer.playerStateStream.listen((state) {
        _onPlayingStateChanged?.call(state.playing);
      });
      
      audioPlayer.positionStream.listen((position) {
        _onPositionChanged?.call(position);
      });
      
      audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          _onDurationChanged?.call(duration);
        }
      });

      // Handle audio interruptions
      _audioSession!.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              audioPlayer.setVolume(0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              audioPlayer.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      // Handle when headphones are unplugged
      _audioSession!.becomingNoisyEventStream.listen((_) {
        pause();
      });

      await _audioSession!.setActive(true);
      _isInitialized = true;
    } catch (e) {
      print('Error initializing UnifiedAudioManager: $e');
      _onErrorChanged?.call('Failed to initialize audio: $e');
    }
  }

  // Main audio methods
  Future<void> playMainAudio(Track track, {String? authorName}) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Stop any currently playing audio
      await audioPlayer.stop();
      
      // Small delay to ensure stop operation completes
      await Future.delayed(const Duration(milliseconds: 100));
      
      _currentTrack = track;
      _currentAuthorName = authorName ?? 'Unknown';
      _currentMainAudioUrl = track.audioPath;
      _currentAudioType = AudioType.main;
      
      // Create MediaItem for main audio
      final mediaItem = MediaItem(
        id: track.id,
        title: track.trackName.isNotEmpty
            ? track.trackName
            : _getSurahNameByNumber(track.surahNumber),
        artist: _currentAuthorName,
        artUri: Uri.parse(track.coverImagePath),
      );

      // Set the audio source
      await audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(track.audioPath),
          tag: mediaItem,
        ),
      );

      await audioPlayer.play();
    } catch (e) {
      print('Error playing main audio: $e');
      _onErrorChanged?.call('Failed to play main audio: $e');
    }
  }

  // Quiz audio methods
  Future<void> playQuizAudio(String assetPath) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Stop any currently playing audio
      await audioPlayer.stop();
      
      // Small delay to ensure stop operation completes
      await Future.delayed(const Duration(milliseconds: 100));
      
      _currentQuizAudioPath = assetPath;
      _currentAudioType = AudioType.quiz;
      
      // Create MediaItem for quiz audio
      final fileName = assetPath.split('/').last.replaceAll('.mp3', '');
      final title = fileName.replaceAll('_', ' ').replaceAll('-', ' ');
      
      final mediaItem = MediaItem(
        id: assetPath,
        title: 'Quiz Audio: $title',
        artist: 'Qawl Quiz',
        album: 'Tajweed Quiz',
        artUri: Uri.parse('https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3'),
      );

      // Set the audio source with better error handling
      await audioPlayer.setAudioSource(
        AudioSource.asset(
          assetPath,
          tag: mediaItem,
        ),
      );

      await audioPlayer.play();
    } catch (e) {
      print('Error playing quiz audio: $e');
      
      // Reset state on error
      _currentAudioType = AudioType.main;
      _currentQuizAudioPath = null;
    }
  }

  // Control methods
  Future<void> play() async {
    try {
      await audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
      _onErrorChanged?.call('Failed to play audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      await audioPlayer.pause();
    } catch (e) {
      print('Error pausing audio: $e');
      _onErrorChanged?.call('Failed to pause audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      await audioPlayer.stop();
      _currentAudioType = AudioType.main;
      _currentQuizAudioPath = null;
    } catch (e) {
      print('Error stopping audio: $e');
      _onErrorChanged?.call('Failed to stop audio: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
      _onErrorChanged?.call('Failed to seek audio: $e');
    }
  }

  // Resume main audio after quiz
  Future<void> resumeMainAudio() async {
    if (_currentTrack != null && _currentAudioType == AudioType.quiz) {
      await playMainAudio(_currentTrack!, authorName: _currentAuthorName);
    }
  }

  // Reset audio session completely
  Future<void> resetAudioSession() async {
    try {
      // Stop and dispose current player
      await audioPlayer.stop();
      _audioPlayer?.dispose();
      _audioPlayer = null;
      
      // Deactivate audio session
      await _audioSession?.setActive(false);
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Reset initialization flag
      _isInitialized = false;
      
      // Reinitialize
      await initialize();
    } catch (e) {
      print('Error resetting audio session: $e');
      _onErrorChanged?.call('Failed to reset audio session: $e');
    }
  }

  // Reset quiz audio only (doesn't affect main audio)
  Future<void> resetQuizAudio() async {
    try {
      // Only reset if we're currently playing quiz audio
      if (_currentAudioType == AudioType.quiz) {
        await audioPlayer.stop();
        _currentAudioType = AudioType.main;
        _currentQuizAudioPath = null;
      }
    } catch (e) {
      print('Error resetting quiz audio: $e');
    }
  }

  // Getters
  bool get isPlaying => audioPlayer.playing;
  AudioType get currentAudioType => _currentAudioType;
  String? get currentQuizAudioPath => _currentQuizAudioPath;
  Track? get currentTrack => _currentTrack;
  String? get currentAuthorName => _currentAuthorName;

  // Setters for callbacks
  void setOnPlayingStateChanged(Function(bool) callback) {
    _onPlayingStateChanged = callback;
  }

  void setOnPositionChanged(Function(Duration) callback) {
    _onPositionChanged = callback;
  }

  void setOnDurationChanged(Function(Duration) callback) {
    _onDurationChanged = callback;
  }

  void setOnErrorChanged(Function(String?) callback) {
    _onErrorChanged = callback;
  }

  // Helper method
  String _getSurahNameByNumber(int surahNumber) {
    return SurahMapper.getSurahNameByNumber(surahNumber);
  }

  void dispose() {
    _audioPlayer?.dispose();
    _audioSession?.setActive(false);
    _isInitialized = false;
  }
} 