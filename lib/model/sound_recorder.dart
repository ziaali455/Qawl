import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';

const pathToSaveAudio = 'example';

class SoundRecorder {
  bool isRecorderInitialized = false;
  FlutterSoundRecorder? _audioRecorder;
  bool get isRecording => _audioRecorder!.isRecording;
  Future _record() async {
    if (!isRecorderInitialized) return;

    await _audioRecorder!.startRecorder(toFile: pathToSaveAudio);
  }

  Future _stop() async {
    if (!isRecorderInitialized) return;
    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecording() async {
    if (_audioRecorder!.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission needed');
    }
    await _audioRecorder!.openAudioSession();
    isRecorderInitialized = true;
  }

  void dispose() {
    if (!isRecorderInitialized) return;

    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    isRecorderInitialized = false;
  }
}
