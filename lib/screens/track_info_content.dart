import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/deprecated/profile_content_DEPRECATED.dart';
import 'package:first_project/widgets/tag_choice_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:first_project/model/track.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:first_project/screens/record_audio_content.dart';
import 'package:firebase_core/firebase_core.dart';

// DropdownMenuEntry labels and values for the first dropdown menu.

class TrackInfoContent extends StatefulWidget {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final String trackPath;
  final record = Record();

  TrackInfoContent({Key? key, required this.trackPath}) : super(key: key);

  @override
  State<TrackInfoContent> createState() => _TrackInfoContentState(trackPath);
}

class _TrackInfoContentState extends State<TrackInfoContent> {
  String trackPath = "";
  final TextEditingController _trackNameController = TextEditingController();

  _TrackInfoContentState(String path) {
    trackPath = path;
  }
  // cleans up controller when widget is disposed
  void dispose() {
    _trackNameController
        .dispose(); // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  String? selectedStyle;
  String? selectedSurah;
  var alertStyle = AlertStyle(
    animationType: AnimationType.fromTop,
    overlayColor: Colors.green,
    isCloseButton: false,
    isButtonVisible: false,
    isOverlayTapDismiss: true,
    descStyle: const TextStyle(fontWeight: FontWeight.bold),
    descTextAlign: TextAlign.start,
    animationDuration: const Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: const BorderSide(
        color: Colors.green,
      ),
    ),
    titleStyle: const TextStyle(
      color: Colors.green,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Existing code...
              const Padding(
                padding: EdgeInsets.only(bottom: 60.0),
                child: Text(
                  "Recitation Info",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35.0,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              QawlSubtitleText(title: "Title"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _trackNameController,
                  cursorColor: Colors.green,
                  decoration: const InputDecoration(
                    floatingLabelStyle: TextStyle(color: Colors.green),
                    labelText: 'Title (optional)',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green, // set the color to green
                        width: 2.0, // set the width of the border
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              QawlSubtitleText(title: "Surah Name"),
              // Dropdown for Surah selection
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: DropdownButton<SurahLabel>(
                  value: null, // Set the initial selected value if needed
                  hint: selectedSurah != null
                      ? Text(selectedSurah!)
                      : const Text('Select a Surah'),
                  onChanged: (SurahLabel? newValue) {
                    setState(() {
                      selectedSurah = newValue?.label;
                    });
                    print('Selected Surah: $selectedSurah');
                  },
                  items: SurahLabel.values.map((SurahLabel surahLabel) {
                    return DropdownMenuItem<SurahLabel>(
                      value: surahLabel,
                      child: Text(surahLabel.label),
                    );
                  }).toList(),
                ),
              ),
              QawlSubtitleText(title: "Tags"),
              TagChoiceRow(
                onStyleSelected: (style) {
                  setState(() {
                    selectedStyle = style; // Store the selected style
                  });
                  print("SELECTED STYLE IS: " + selectedStyle!);
                },
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: CancelPostButton(
                      trackPath: trackPath,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ConfirmPostButton(
                      alertStyle: alertStyle,
                      trackPath: trackPath,
                      surah: selectedSurah ?? "",
                      trackName: _trackNameController.text,
                      style: selectedStyle ?? 'Hafs \'an Asim',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CancelPostButton extends StatelessWidget {
  final String trackPath;

  const CancelPostButton({
    required this.trackPath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: <Widget>[
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
              padding: const EdgeInsets.only(left: 20, right: 20),
              textStyle: const TextStyle(fontSize: 50),
            ),
            onPressed: () async {
              debugPrint(trackPath);
              File file = File(trackPath);
              await Track.deleteLocalFile(file);

              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Align(
                alignment: Alignment.center,
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                )),
          ),
        ],
      ),
    );
  }
}

// Future<String> getTemporaryFilePath() async {
//   Directory tempDir = await getTemporaryDirectory();
//   String tempPath = tempDir.path;
//   return '$tempPath/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
// }

// Future<String?> uploadRecordingToStorage(String? filePath) async {
//   debugPrint("Uploading recording...");
//   File file;
//   if (filePath != null) {
//     file = File(filePath);

//     try {
//       String fileName =
//           'recordings/${DateTime.now().millisecondsSinceEpoch}.m4a';
//             debugPrint(fileName);

//       TaskSnapshot uploadTask =
//           await FirebaseStorage.instance.ref(fileName).putFile(file);

//       //THIS AWAIT IS CAUSING ISSUES HERE?
//       String downloadUrl = await uploadTask.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       debugPrint("Error uploading audio file: $e");
//       return null;
//     }
//   } else {
//     debugPrint("null filepath parameter");
//     return null;
//   }
// }

// Future<void> storeRecordingInFirestore(String fileUrl, String surah) async {
//   try {
//     await FirebaseFirestore.instance.collection('QawlTracks').add({
//       'fileUrl': fileUrl,
//       'timestamp': FieldValue.serverTimestamp(),
//       // Add the additional attributes here
//       'surah': surah
//     });
//     debugPrint('File URL stored in Firestore successfully.');
//   } catch (e) {
//     debugPrint('Error storing file URL in Firestore: $e');
//   }
// }

// Future<void> deleteLocalFile(File file) async {
//   try {
//     if (await file.exists()) {
//       await file.delete();
//       debugPrint("Local file deleted successfully.");
//     }
//   } catch (e) {
//     debugPrint("Error deleting local file: $e");
//   }
// }

class ConfirmPostButton extends StatefulWidget {
  final String trackPath;
  final String surah;
  final String trackName;
  final String style;
  final AlertStyle alertStyle;

  const ConfirmPostButton({
    Key? key,
    required this.trackPath,
    required this.surah,
    required this.trackName,
    required this.alertStyle,
    required this.style,
  }) : super(key: key);

  @override
  _ConfirmPostButtonState createState() => _ConfirmPostButtonState();
}

class _ConfirmPostButtonState extends State<ConfirmPostButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: <Widget>[
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onPressed: _postContent,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.green)
                : const Text("Post"),
          ),
        ],
      ),
    );
  }

  void _postContent() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    String? fileUrl = await Track.uploadRecordingToStorage(widget.trackPath);
    if (fileUrl != null) {
      String? uid = QawlUser.getCurrentUserUid();
      if (uid != null) {
        await Track.createQawlTrack(
            uid, widget.surah, fileUrl, widget.trackName, widget.style);
      } else {
        print("Error: UID is null.");
      }
    } else {
      print("Error uploading the file.");
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
    Navigator.pop(context);

    Alert(
            image: const Icon(Icons.check, size: 100.0),
            style: widget.alertStyle,
            context: context,
            title: "Posted!")
        .show();
  }
}

class QawlSubtitleText extends StatelessWidget {
  String title = "";
  QawlSubtitleText({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
        ),
      ),
    );
  }
}

SurahLabel? getSurahLabelFromName(String surahName) {
  // Assuming SurahLabelExtension.label is a reverse mapping of labels to enum values
  try {
    return SurahLabel.values.firstWhere((label) => label.label == surahName);
  } catch (e) {
    // Handle the case where the surah name does not match any label
    print("Surah name '$surahName' not found.");
    return null;
  }
}

int? getSurahNumberByName(String surahName) {
  final surahLabel = getSurahLabelFromName(surahName);
  return surahLabel?.surahNumber;
}

extension SurahLabelExtension on SurahLabel {
  int get surahNumber {
    return this.index;
  }

  String get label {
    switch (this) {
      case SurahLabel.none:
        return 'None';
      case SurahLabel.alFatiha:
        return 'Al-Fatiha (The Opening)';
      case SurahLabel.alBaqarah:
        return 'Al-Baqarah (The Cow)';
      case SurahLabel.alImran:
        return 'Aal-E-Imran (The Family of Imran)';
      case SurahLabel.anNisa:
        return 'An-Nisa\' (The Women)';
      case SurahLabel.alMaidah:
        return 'Al-Maidah (The Table Spread)';
      case SurahLabel.alAnam:
        return 'Al-Anam (The Cattle)';
      case SurahLabel.alAraf:
        return 'Al-Araf (The Heights)';
      case SurahLabel.alAnfal:
        return 'Al-Anfal (The Spoils of War)';
      case SurahLabel.atTawbah:
        return 'At-Tawbah (The Repentance)';
      case SurahLabel.yunus:
        return 'Yunus (Jonah)';
      case SurahLabel.hud:
        return 'Hud (Hud)';
      case SurahLabel.yusuf:
        return 'Yusuf (Joseph)';
      case SurahLabel.arRad:
        return 'Ar-Ra\'d (The Thunder)';
      case SurahLabel.ibrahim:
        return 'Ibrahim (Abraham)';
      case SurahLabel.alHijr:
        return 'Al-Hijr (The Rocky Tract)';
      case SurahLabel.anNahl:
        return 'An-Nahl (The Bee)';
      case SurahLabel.alIsra:
        return 'Al-Isra (The Night Journey)';
      case SurahLabel.alKahf:
        return 'Al-Kahf (The Cave)';
      case SurahLabel.maryam:
        return 'Maryam (Mary)';
      case SurahLabel.taHa:
        return 'Ta-Ha (Ta-Ha)';
      case SurahLabel.alAnbiya:
        return 'Al-Anbiya (The Prophets)';
      case SurahLabel.alHajj:
        return 'Al-Hajj (The Pilgrimage)';
      case SurahLabel.alMuminun:
        return 'Al-Mu\'minun (The Believers)';
      case SurahLabel.anNur:
        return 'An-Nur (The Light)';
      case SurahLabel.alFurqan:
        return 'Al-Furqan (The Criterion)';
      case SurahLabel.ashShuara:
        return 'Ash-Shu\'ara (The Poets)';
      case SurahLabel.anNaml:
        return 'An-Naml (The Ant)';
      case SurahLabel.alQasas:
        return 'Al-Qasas (The Stories)';
      case SurahLabel.alAnkabut:
        return 'Al-Ankabut (The Spider)';
      case SurahLabel.arRum:
        return 'Ar-Rum (The Romans)';
      case SurahLabel.luqman:
        return 'Luqman (Luqman)';
      case SurahLabel.asSajda:
        return 'As-Sajda (The Prostration)';
      case SurahLabel.alAhzab:
        return 'Al-Ahzab (The Combined Forces)';
      case SurahLabel.saba:
        return 'Saba\' (Sheba)';
      case SurahLabel.fatir:
        return 'Fatir (The Originator)';
      case SurahLabel.yaSin:
        return 'Ya-Sin (Ya-Sin)';
      case SurahLabel.asSaffat:
        return 'As-Saffat (Those who set the Ranks)';
      case SurahLabel.sad:
        return 'Sad (The Letter Sad)';
      case SurahLabel.azZumar:
        return 'Az-Zumar (The Troops)';
      case SurahLabel.ghafir:
        return 'Ghafir (The Forgiver)';
      case SurahLabel.fussilat:
        return 'Fussilat (Explained in Detail)';
      case SurahLabel.ashShura:
        return 'Ash-Shura (The Consultation)';
      case SurahLabel.azZukhruf:
        return 'Az-Zukhruf (The Gold Adornments)';
      case SurahLabel.adDukhan:
        return 'Ad-Dukhan (The Smoke)';
      case SurahLabel.alJathiya:
        return 'Al-Jathiya (The Crouching)';
      case SurahLabel.alAhqaf:
        return 'Al-Ahqaf (The Wind-Curved Sandhills)';
      case SurahLabel.muhammad:
        return 'Muhammad (Muhammad)';
      case SurahLabel.alFath:
        return 'Al-Fath (The Victory)';
      case SurahLabel.alHujurat:
        return 'Al-Hujurat (The Rooms)';
      case SurahLabel.qaf:
        return 'Qaf (The Letter Qaf)';
      case SurahLabel.adhDhariyat:
        return 'Adh-Dhariyat (The Winnowing Winds)';
      case SurahLabel.atTur:
        return 'At-Tur (The Mount)';
      case SurahLabel.anNajm:
        return 'An-Najm (The Star)';
      case SurahLabel.alQamar:
        return 'Al-Qamar (The Moon)';
      case SurahLabel.arRahman:
        return 'Ar-Rahman (The Beneficent)';
      case SurahLabel.alWaqia:
        return 'Al-Waqi\'a (The Inevitable)';
      case SurahLabel.alHadid:
        return 'Al-Hadid (The Iron)';
      case SurahLabel.alMujadila:
        return 'Al-Mujadila (The Pleading Woman)';
      case SurahLabel.alHashr:
        return 'Al-Hashr (The Exile)';
      case SurahLabel.alMumtahina:
        return 'Al-Mumtahina (The Woman to be examined)';
      case SurahLabel.asSaff:
        return 'As-Saff (The Ranks)';
      case SurahLabel.alJumua:
        return 'Al-Jumu\'a (The Congregation)';
      case SurahLabel.alMunafiqun:
        return 'Al-Munafiqun (The Hypocrites)';
      case SurahLabel.atTaghabun:
        return 'At-Taghabun (The Mutual Disillusion)';
      case SurahLabel.atTalaq:
        return 'At-Talaq (The Divorce)';
      case SurahLabel.atTahrim:
        return 'At-Tahrim (The Prohibition)';
      case SurahLabel.alMulk:
        return 'Al-Mulk (The Sovereignty)';
      case SurahLabel.alQalam:
        return 'Al-Qalam (The Pen)';
      case SurahLabel.alHaaqqa:
        return 'Al-Haaqqa (The Reality)';
      case SurahLabel.alMaarij:
        return 'Al-Ma\'arij (The Ascending Stairways)';
      case SurahLabel.nuh:
        return 'Nuh (Noah)';
      case SurahLabel.alJinn:
        return 'Al-Jinn (The Jinn)';
      case SurahLabel.alMuzzammil:
        return 'Al-Muzzammil (The Enshrouded One)';
      case SurahLabel.alMuddathir:
        return 'Al-Muddathir (The Cloaked One)';
      case SurahLabel.alQiyama:
        return 'Al-Qiyama (The Resurrection)';
      case SurahLabel.alInsan:
        return 'Al-Insan (Man)';
      case SurahLabel.alMursalat:
        return 'Al-Mursalat (The Emissaries)';
      case SurahLabel.anNaba:
        return 'An-Naba\' (The Tidings)';
      case SurahLabel.anNaziat:
        return 'An-Naziat (Those who drag forth)';
      case SurahLabel.abasa:
        return 'Abasa (He frowned)';
      case SurahLabel.atTakwir:
        return 'At-Takwir (The Overthrowing)';
      case SurahLabel.alInfitar:
        return 'Al-Infitar (The Cleaving)';
      case SurahLabel.alMutaffifin:
        return 'Al-Mutaffifin (Defrauding)';
      case SurahLabel.alInshiqaq:
        return 'Al-Inshiqaq (The Splitting Open)';
      case SurahLabel.alBuruj:
        return 'Al-Buruj (The Mansions of the Stars)';
      case SurahLabel.atTariq:
        return 'At-Tariq (The Morning Star)';
      case SurahLabel.alAla:
        return 'Al-Ala (The Most High)';
      case SurahLabel.alGhashiya:
        return 'Al-Ghashiyah (The Overwhelming)';
      case SurahLabel.alFajr:
        return 'Al-Fajr (The Dawn)';
      case SurahLabel.alBalad:
        return 'Al-Balad (The City)';
      case SurahLabel.ashShams:
        return 'Ash-Shams (The Sun)';
      case SurahLabel.alLayl:
        return 'Al-Layl (The Night)';
      case SurahLabel.adhDhuha:
        return 'Adh-Dhuha (The Morning Hours)';
      case SurahLabel.ashSharh:
        return 'Ash-Sharh (The Relief)';
      case SurahLabel.atTeen:
        return 'At-Tin (The Fig)';
      case SurahLabel.alAlaq:
        return 'Al-Alaq (The Clot)';
      case SurahLabel.alQadr:
        return 'Al-Qadr (The Power)';
      case SurahLabel.alBayyina:
        return 'Al-Bayyina (The Clear Proof)';
      case SurahLabel.azZalzala:
        return 'Az-Zalzala (The Earthquake)';
      case SurahLabel.alAdiyat:
        return 'Al-Adiyat (The Courser)';
      case SurahLabel.alQaria:
        return 'Al-Qaria (The Calamity)';
      case SurahLabel.atTakathur:
        return 'At-Takathur (The Rivalry in World Increase)';
      case SurahLabel.alAsr:
        return 'Al-Asr (The Declining Day)';
      case SurahLabel.alHumaza:
        return 'Al-Humaza (The Traducer)';
      case SurahLabel.alFil:
        return 'Al-Fil (The Elephant)';
      case SurahLabel.quraish:
        return 'Quraish (Quraish)';
      case SurahLabel.alMaun:
        return 'Al-Ma\'un (Acts of Kindness)';
      case SurahLabel.alKawthar:
        return 'Al-Kawthar (The Abundance)';
      case SurahLabel.alKafirun:
        return 'Al-Kafirun (The Disbelievers)';
      case SurahLabel.anNasr:
        return 'An-Nasr (The Help)';
      case SurahLabel.alMasad:
        return 'Al-Masad (The Palm Fiber)';
      case SurahLabel.alIkhlas:
        return 'Al-Ikhlas (The Sincerity)';
      case SurahLabel.alFalaq:
        return 'Al-Falaq (The Daybreak)';
      case SurahLabel.anNas:
        return 'An-Nas (Mankind)';
    }
  }
}

enum SurahLabel {
  none,
  alFatiha,
  alBaqarah,
  alImran,
  anNisa,
  alMaidah,
  alAnam,
  alAraf,
  alAnfal,
  atTawbah,
  yunus,
  hud,
  yusuf,
  arRad,
  ibrahim,
  alHijr,
  anNahl,
  alIsra,
  alKahf,
  maryam,
  taHa,
  alAnbiya,
  alHajj,
  alMuminun,
  anNur,
  alFurqan,
  ashShuara,
  anNaml,
  alQasas,
  alAnkabut,
  arRum,
  luqman,
  asSajda,
  alAhzab,
  saba,
  fatir,
  yaSin,
  asSaffat,
  sad,
  azZumar,
  ghafir,
  fussilat,
  ashShura,
  azZukhruf,
  adDukhan,
  alJathiya,
  alAhqaf,
  muhammad,
  alFath,
  alHujurat,
  qaf,
  adhDhariyat,
  atTur,
  anNajm,
  alQamar,
  arRahman,
  alWaqia,
  alHadid,
  alMujadila,
  alHashr,
  alMumtahina,
  asSaff,
  alJumua,
  alMunafiqun,
  atTaghabun,
  atTalaq,
  atTahrim,
  alMulk,
  alQalam,
  alHaaqqa,
  alMaarij,
  nuh,
  alJinn,
  alMuzzammil,
  alMuddathir,
  alQiyama,
  alInsan,
  alMursalat,
  anNaba,
  anNaziat,
  abasa,
  atTakwir,
  alInfitar,
  alMutaffifin,
  alInshiqaq,
  alBuruj,
  atTariq,
  alAla,
  alGhashiya,
  alFajr,
  alBalad,
  ashShams,
  alLayl,
  adhDhuha,
  ashSharh,
  atTeen,
  alAlaq,
  alQadr,
  alBayyina,
  azZalzala,
  alAdiyat,
  alQaria,
  atTakathur,
  alAsr,
  alHumaza,
  alFil,
  quraish,
  alMaun,
  alKawthar,
  alKafirun,
  anNasr,
  alMasad,
  alIkhlas,
  alFalaq,
  anNas,
}
