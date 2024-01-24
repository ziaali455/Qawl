import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:first_project/screens/record_audio_content.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class ModalFit extends StatelessWidget {
  const ModalFit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(style: TextStyle( fontWeight: FontWeight.bold, color: Colors.green),'Record'),
            leading: Icon(Icons.mic, color: Colors.green, size: 30.0),
            onTap: () => 
            Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecordAudioContent(),
                  )),
            
          ),
          ListTile(
            title: Text(style: TextStyle( fontWeight: FontWeight.bold, color: Colors.green),'Upload'),
            leading: Icon(Icons.file_upload_outlined, color: Colors.green, size: 30.0),
            onTap: () async {

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

                TaskSnapshot uploadTask = await FirebaseStorage.instance
                    .ref('recordings/$fileName')
                    .putFile(file);
                String downloadUrl = await uploadTask.ref.getDownloadURL();

                //upload to cloud firestore
                await FirebaseFirestore.instance.collection('tracks').add({
                  'fileUrl': downloadUrl,
                  'timestamp': FieldValue.serverTimestamp(),
                  //'surah' : surah
                });
              } else {
                // User canceled the picker
              }},
          ),

        ],
      ),
    ));
  }
}
