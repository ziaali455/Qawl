import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/model/sound_recorder.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/screens/track_info_content.dart';
import 'package:first_project/widgets/qawl_back_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:first_project/model/track.dart';

class RecordAudioContent extends StatefulWidget {
  const RecordAudioContent({Key? key}) //required this.playlist
      : super(key: key);
  @override
  // ignore: no_logic_in_create_state
  State<RecordAudioContent> createState() => _RecordAudioContentState();
}

class _RecordAudioContentState extends State<RecordAudioContent> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String messageText =
      "Once you press the mic button, your recording will show up here.";
  //final record = Record();
  String? _recordedFilePath;
  DateTime? recordingStartTime;
  late final RecorderController recorderController; // new recorder for waves
  late final PlayerController playerController;
  AudioPlayer main_player = AudioPlayer();
  int _lastPosition =
      0; // This will hold the last playback position in milliseconds

  bool isCapturing = false;
  bool isPlaying = false;
  PlayerController controller = PlayerController(); // Initialise
  bool showWaveforms = false;
  bool showCheck = false;
  bool doneRecording = false;

  @override
  void initState() {
    super.initState();
    _initialiseController();
    initRecorder().then((_) {
      playerController = PlayerController();
      playerController.onCurrentDurationChanged.listen((position) {
        _lastPosition = position;
      });

      playerController.onCompletion.listen((_) {
        setState(() {
          isPlaying = false;
        });
        preparePlayerForReplay();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    recorderController.dispose();
    playerController.dispose();
    main_player.dispose();
  }

  Future<void> preparePlayerForReplay() async {
    if (_recordedFilePath != null) {
      await playerController.preparePlayer(path: _recordedFilePath!);
    }
  }

  void _initialiseController() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 48000
      ..bitRate = 128000;
    // playerController = PlayerController();
  }

  Future<void> initRecorder() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        print('Mic permission not granted'); // Debug print
      } else {
        print('Mic permission granted'); // Debug print
      }
    } else {
      print('Mic permission already granted'); // Debug print
    }
  }

//using a temporary filepath to store the file locally, then delete the path after stopping the recording
  Future<void> start() async {
    // if (await Permission.microphone.isGranted) {
    // Delete the previous recording if it exists
    if (_recordedFilePath != null) {
      File previousRecording = File(_recordedFilePath!);
      if (await previousRecording.exists()) {
        await deleteLocalFile(previousRecording);
      }
    }

    recordingStartTime = DateTime.now();
    _recordedFilePath = await getTemporaryFilePath(); // Set the new file path
    // await record.start(path: _recordedFilePath);
    playerController.preparePlayer(path: _recordedFilePath!);
    await recorderController.record(path: _recordedFilePath!);

    setState(() {
      showWaveforms = true;
      isCapturing = true;
    });
    debugPrint("Recording started");
    // }  else {
    //    await initRecorder();
    //    if (await Permission.microphone.isGranted) {
    //      await start();
    //    }
    //}
  }

// user id plus milliseconds
  Future<String> getTemporaryFilePath() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    return '$tempPath/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

// delete the local file after uploading to storage
  Future<void> deleteLocalFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        debugPrint("Local file deleted successfully.");
      }
    } catch (e) {
      debugPrint("Error deleting local file: $e");
    }
  }

// Get the state of the recorder
  Future<bool> isRecording() async {
    // bool isRecording = await record.isRecording();
    bool isRecording = await recorderController.isRecording;
    return isRecording;
  }

  void stopRecording() async {
    await recorderController.stop();
    debugPrint("Recording stopped");

    // Prepare player controller with the recorded file path
    if (_recordedFilePath != null) {
      await playerController.preparePlayer(path: _recordedFilePath!);
    }

    setState(() {
      showWaveforms = true; // Keep waveform visible
      isCapturing = false;
      doneRecording = true;
      isPlaying = false;
    });
  }

  Future<void> pauseAudio() async {
    await playerController.pausePlayer();
    setState(() {
      isPlaying = false;
      // isCapturing = false;
    });
    debugPrint("Playback paused at position: $_lastPosition ms");
  }

  Future<void> playAudio() async {
    if (_recordedFilePath == null) {
      debugPrint("No recording has been made yet");
      return;
    }
    try {
      await playerController.seekTo(_lastPosition);
      debugPrint("Seeking to position: $_lastPosition ms");
      // if (playerController.playerState == PlayerState.paused) {
      //   await playerController
      //       .seekTo(_lastPosition); // Seek to the last known position
      // }
      await playerController.startPlayer();
      setState(() {
        isPlaying = true;
      });
      debugPrint("Playback started from position: $_lastPosition ms");
    } catch (e) {
      debugPrint("Error during playback: $e");
    }
  }

//temp widget for waveform
  Widget QawlWaveforms() {
    if (isCapturing && !doneRecording) {
      return AudioWaveforms(
        enableGesture: true,
        size: Size(MediaQuery.of(context).size.width, 100),
        recorderController: recorderController,
        waveStyle: const WaveStyle(
          waveColor: Colors.green,
          extendWaveform: true,
          waveThickness: 4.0,
          scaleFactor: 125.0,
          showMiddleLine: false,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: const Color(0xFF1E1B26),
        ),
        padding: const EdgeInsets.only(left: 18),
        margin: const EdgeInsets.symmetric(horizontal: 15),
      );
    } else if (doneRecording) {
      return AudioFileWaveforms(
        size: Size(MediaQuery.of(context).size.width, 100),
        playerController: playerController,
        playerWaveStyle: const PlayerWaveStyle(
          scaleFactor: 200.0,
          fixedWaveColor: Colors.green,
          liveWaveColor: Colors.green,
          waveCap: StrokeCap.butt,
        ),
        enableSeekGesture: false,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: const Color(0xFF1E1B26),
        ),
        padding: const EdgeInsets.only(left: 18),
        margin: const EdgeInsets.symmetric(horizontal: 15),
      );
    } else {
      return Container(
        height: 100,
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              messageText,
              textAlign: TextAlign
                  .center, // Optional: TextAlign.center for text alignment
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _visible = true;
    return Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: QawlBackButton(),
                    ),
                    // AudioFileWaveforms(
                    //   size: Size(MediaQuery.of(context).size.width, 100.0),
                    //   playerController: playerController,
                    // ),

                    QawlWaveforms(),
                    const SizedBox(height: 10),
                    Center(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: QawlRecordButton()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: QawlPlayBackButton(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: QawlDeleteRecordingButton(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: QawlConfirmRecordingButton(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        )));
  }

  Widget QawlDeleteRecordingButton() {
    if (doneRecording) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(children: <Widget>[
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color.fromARGB(255, 13, 161, 99),
                      Color.fromARGB(255, 22, 181, 93),
                      Color.fromARGB(255, 32, 220, 85),
                    ],
                  ),
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                fixedSize: const Size(125, 70),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.only(left: 10, right: 10),
                textStyle: const TextStyle(fontSize: 50),
              ),
              onPressed: () {
                //should go back one step to recording main screen
                Navigator.pop(context);
                File file = File(_recordedFilePath!);
                deleteLocalFile(file);
                debugPrint(_recordedFilePath);
              },
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Delete",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  )),
            ),
          ]));
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget QawlConfirmRecordingButton() {
    if (doneRecording) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(children: <Widget>[
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color.fromARGB(255, 13, 161, 99),
                      Color.fromARGB(255, 22, 181, 93),
                      Color.fromARGB(255, 32, 220, 85),
                    ],
                  ),
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                fixedSize: const Size(125, 70),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.only(left: 10, right: 10),
                textStyle: const TextStyle(fontSize: 50),
              ),
              onPressed: () {
                if (_recordedFilePath != null) {
                  // Check that the recorded file path is not null
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackInfoContent(
                          trackPath:
                              _recordedFilePath!, // Pass the non-null recorded file path
                        ),
                      ));
                } else {
                  // Inform the user that the file path is not available
                  debugPrint("Recorded file path is null");
                }
              },
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Confirm",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  )),
            ),
          ]));
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget QawlRecordButton() {
    if (doneRecording) {
      return Container(height: 0);
    } else {
      return Stack(children: <Widget>[
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: <Color>[
                  Color.fromARGB(255, 13, 161, 99),
                  Color.fromARGB(255, 22, 181, 93),
                  Color.fromARGB(255, 32, 220, 85),
                ],
              ),
            ),
          ),
        ),
        ElevatedButton(
            child: isCapturing
                ? const Icon(Icons.pause, size: 80.0)
                : const Icon(Icons.mic, size: 80.0),
            onPressed: () async {
              if (isCapturing) {
                stopRecording();
              } else {
                await start();
              }
            },
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            ))
      ]);
    }
  }

  Widget QawlPlayBackButton() {
    if (doneRecording) {
      return Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[
              Color.fromARGB(255, 13, 161, 99),
              Color.fromARGB(255, 22, 181, 93),
              Color.fromARGB(255, 32, 220, 85),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius:
              BorderRadius.circular(10), // Add some rounding to match button
        ),
        child: ElevatedButton(
          onPressed: () async {
            if (isPlaying) {
              pauseAudio();
            } else {
              await playAudio();
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            backgroundColor: Colors.transparent, // Make background transparent
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
              size: 60.0, color: Colors.white),
        ),
      );
    }
    return Container(height: 0);
  }
}
