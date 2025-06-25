import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:first_project/screens/record_audio_content.dart';
import 'package:first_project/screens/track_info_content.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:first_project/blocs/now_playing/now_playing_bloc.dart';
import 'package:first_project/blocs/now_playing/now_playing_event.dart';

class UploadPopupWidget extends StatelessWidget {
  const UploadPopupWidget
({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
              title: Text(
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                  'Record'),
              leading: Icon(Icons.mic, color: Colors.green, size: 30.0),
              onTap: () {
                // Pause main audio before navigating to record page
                final nowPlayingBloc = NowPlayingBloc.instance;
                if (nowPlayingBloc.state.isPlaying) {
                  nowPlayingBloc.add(PauseAudio());
                }
                
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordAudioContent(),
                    ));
              }),
          ListTile(
            title: Text(
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                'Upload'),
            leading: Icon(Icons.file_upload_outlined,
                color: Colors.green, size: 30.0),
            onTap: () async {

              // Pause main audio before navigating to upload page
              final nowPlayingBloc = NowPlayingBloc.instance;
              if (nowPlayingBloc.state.isPlaying) {
                nowPlayingBloc.add(PauseAudio());
              }

              FilePickerResult? result = await FilePicker.platform.pickFiles();

              if (result != null) {
                File file = File(result.files.single.path!);
                Uint8List? fileBytes =
                    result.files.first.bytes; // fileBytes is nullable
                String fileName = result.files.first.name;

                if (fileBytes != null) {
                  //upload to firebase storage
                  //         await FirebaseStorage.instance
                  //           .ref('recordings/$fileName')
                  //         .putFile(file);
                }
                String? pickedFilePath = result.files.single.path;
                // debugPrint(pickedFilePath);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackInfoContent(
                        trackPath: pickedFilePath!,
                      ),
                    ));

  
                // // Navigator.push(
                // //     context,
                // //     MaterialPageRoute(
                // //       builder: (context) => TrackInfoContent(trackPath: downloadUrl,),
                // //     ));
                // //upload to cloud firestore
                // await FirebaseFirestore.instance.collection('tracks').add({
                //   'fileUrl': downloadUrl,
                //   'timestamp': FieldValue.serverTimestamp(),
                //   //'surah' : surah
                // });
              } else {
                // User canceled the picker
              }
            },
          ),
        ],
      ),
    ));
  }
}
