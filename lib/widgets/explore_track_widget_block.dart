import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/deprecated/fake_track_data.dart';
import 'package:first_project/model/player.dart';
import 'package:first_project/screens/track_info_content.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../../../../size_config.dart';
import '../model/playlist.dart';
import '../model/track.dart';
import '../model/playlist.dart';
import '../screens/now_playing_content.dart';
import 'section_title_widget.dart';

class ExploreTrackWidgetRow extends StatelessWidget {
  const ExploreTrackWidgetRow({
    Key? key,
    required this.title,
    required this.playlist, required this.isPersonal,
  }) : super(key: key);
  final String title;
  final QawlPlaylist playlist;
  final bool isPersonal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(5)),
          child: PlaylistSectionTitle(
            title: title,
            isPlaylist: true,
            playlist: playlist,
            press: () {}, isPersonal: isPersonal,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: playlist.list.map((track) {
              return FutureBuilder<Tuple2<String, String>>(
                future: getPlaybackContents(track),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(color: Colors.green); // Placeholder while loading
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final data = snapshot.data;
                    final displayName = data?.item1 ?? 'Unknown';
                    String coverImagePath = data!.item2;

                    // Use displayName and coverImagePath as needed
                    return TrackCard(
                      playlist: playlist,
                      image: coverImagePath,
                      title:
                          SurahMapper.getSurahNameByNumber(track.surahNumber),
                      author: displayName,
                      track: track,
                    );
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

Future<Tuple2<String, String>> getPlaybackContents(Track track) async {
  var userDoc = await FirebaseFirestore.instance
      .collection('QawlUsers')
      .doc(track.userId)
      .get();
  final displayName = userDoc.get('name') as String;
  String coverImagePath = userDoc.get('imagePath') as String;
  if (coverImagePath == "") {
    coverImagePath =
        "https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3";
  }

  return Tuple2(
    displayName,
    coverImagePath,
  );
}

class TrackCard extends StatelessWidget {
  const TrackCard({
    Key? key,
    required this.track,
    required this.title,
    required this.image,
    required this.author,
    required this.playlist,
  }) : super(key: key);

  final String title, image, author;
  final Track track;
  final QawlPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Padding(
      padding: EdgeInsets.all(getProportionateScreenWidth(10)),
      child: GestureDetector(
        onTap: () {
          playTrackWithList(track, playlist);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NowPlayingContent(playedTrack: track),
            ),
          );
        },
        child: SizedBox(
          width: getProportionateScreenWidth(135),
          height: getProportionateScreenWidth(135),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Container(
                  height: getProportionateScreenWidth(150),
                  width: getProportionateScreenWidth(150),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(.0),
                        Colors.black.withOpacity(.8),
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(12.0),
                      vertical: getProportionateScreenWidth(12),
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: "$title\n",
                            style: TextStyle(
                              fontSize: getProportionateScreenWidth(18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "$author\n",
                            style: TextStyle(
                              fontSize: getProportionateScreenWidth(18),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SurahMapper {
  static String getSurahNameByNumber(int surahNumber) {
    switch (surahNumber) {
      case 0:
        return 'None';
      case 1:
        return 'Al-Fatiha (The Opening)';
      case 2:
        return 'Al-Baqarah (The Cow)';
      case 3:
        return 'Aal-E-Imran (The Family of Imran)';
      case 4:
        return 'An-Nisa\' (The Women)';
      case 5:
        return 'Al-Maidah (The Table Spread)';
      case 6:
        return 'Al-An`am (The Cattle)';
      case 7:
        return 'Al-A`raf (The Heights)';
      case 8:
        return 'Al-Anfal (The Spoils of War)';
      case 9:
        return 'At-Tawbah (The Repentance)';
      case 10:
        return 'Yunus (Jonah)';
      case 11:
        return 'Hud (Hud)';
      case 12:
        return 'Yusuf (Joseph)';
      case 13:
        return 'Ar-Ra`d (The Thunder)';
      case 14:
        return 'Ibrahim (Abraham)';
      case 15:
        return 'Al-Hijr (The Rocky Tract)';
      case 16:
        return 'An-Nahl (The Bee)';
      case 17:
        return 'Al-Isra (The Night Journey)';
      case 18:
        return 'Al-Kahf (The Cave)';
      case 19:
        return 'Maryam (Mary)';
      case 20:
        return 'Ta-Ha (Ta-Ha)';
      case 21:
        return 'Al-Anbiya (The Prophets)';
      case 22:
        return 'Al-Hajj (The Pilgrimage)';
      case 23:
        return 'Al-Mu\'minun (The Believers)';
      case 24:
        return 'An-Nur (The Light)';
      case 25:
        return 'Al-Furqan (The Criterion)';
      case 26:
        return 'Ash-Shu`ara (The Poets)';
      case 27:
        return 'An-Naml (The Ant)';
      case 28:
        return 'Al-Qasas (The Stories)';
      case 29:
        return 'Al-Ankabut (The Spider)';
      case 30:
        return 'Ar-Rum (The Romans)';
      case 31:
        return 'Luqman (Luqman)';
      case 32:
        return 'As-Sajda (The Prostration)';
      case 33:
        return 'Al-Ahzab (The Combined Forces)';
      case 34:
        return 'Saba\' (Sheba)';
      case 35:
        return 'Fatir (The Originator)';
      case 36:
        return 'Ya-Sin (Ya-Sin)';
      case 37:
        return 'As-Saffat (Those who set the Ranks)';
      case 38:
        return 'Sad (The Letter Sad)';
      case 39:
        return 'Az-Zumar (The Troops)';
      case 40:
        return 'Ghafir (The Forgiver)';
      case 41:
        return 'Fussilat (Explained in Detail)';
      case 42:
        return 'Ash-Shura (The Consultation)';
      case 43:
        return 'Az-Zukhruf (The Gold Adornments)';
      case 44:
        return 'Ad-Dukhan (The Smoke)';
      case 45:
        return 'Al-Jathiya (The Crouching)';
      case 46:
        return 'Al-Ahqaf (The Wind-Curved Sandhills)';
      case 47:
        return 'Muhammad (Muhammad)';
      case 48:
        return 'Al-Fath (The Victory)';
      case 49:
        return 'Al-Hujurat (The Rooms)';
      case 50:
        return 'Qaf (The Letter Qaf)';
      case 51:
        return 'Adh-Dhariyat (The Winnowing Winds)';
      case 52:
        return 'At-Tur (The Mount)';
      case 53:
        return 'An-Najm (The Star)';
      case 54:
        return 'Al-Qamar (The Moon)';
      case 55:
        return 'Ar-Rahman (The Beneficent)';
      case 56:
        return 'Al-Waqi`a (The Inevitable)';
      case 57:
        return 'Al-Hadid (The Iron)';
      case 58:
        return 'Al-Mujadila (The Pleading Woman)';
      case 59:
        return 'Al-Hashr (The Exile)';
      case 60:
        return 'Al-Mumtahina (The Woman to be examined)';
      case 61:
        return 'As-Saff (The Ranks)';
      case 62:
        return 'Al-Jumu\'a (The Congregation)';
      case 63:
        return 'Al-Munafiqun (The Hypocrites)';
      case 64:
        return 'At-Taghabun (The Mutual Disillusion)';
      case 65:
        return 'At-Talaq (The Divorce)';
      case 66:
        return 'At-Tahrim (The Prohibition)';
      case 67:
        return 'Al-Mulk (The Sovereignty)';
      case 68:
        return 'Al-Qalam (The Pen)';
      case 69:
        return 'Al-Haaqqa (The Reality)';
      case 70:
        return 'Al-Ma\'arij (The Ascending Stairways)';
      case 71:
        return 'Nuh (Noah)';
      case 72:
        return 'Al-Jinn (The Jinn)';
      case 73:
        return 'Al-Muzzammil (The Enshrouded One)';
      case 74:
        return 'Al-Muddathir (The Cloaked One)';
      case 75:
        return 'Al-Qiyama (The Resurrection)';
      case 76:
        return 'Al-Insan (Man)';
      case 77:
        return 'Al-Mursalat (The Emissaries)';
      case 78:
        return 'An-Naba (The Tidings)';
      case 79:
        return 'An-Naziat (Those who drag forth)';
      case 80:
        return 'Abasa (He frowned)';
      case 81:
        return 'At-Takwir (The Overthrowing)';
      case 82:
        return 'Al-Infitar (The Cleaving)';
      case 83:
        return 'Al-Mutaffifin (Defrauding)';
      case 84:
        return 'Al-Inshiqaq (The Splitting Open)';
      case 85:
        return 'Al-Buruj (The Mansions of the Stars)';
      case 86:
        return 'At-Tariq (The Morning Star)';
      case 87:
        return 'Al-Ala (The Most High)';
      case 88:
        return 'Al-Ghashiyah (The Overwhelming)';
      case 89:
        return 'Al-Fajr (The Dawn)';
      case 90:
        return 'Al-Balad (The City)';
      case 91:
        return 'Ash-Shams (The Sun)';
      case 92:
        return 'Al-Layl (The Night)';
      case 93:
        return 'Adh-Dhuha (The Morning Hours)';
      case 94:
        return 'Al-Inshirah (The Relief)';
      case 95:
        return 'At-Tin (The Fig)';
      case 96:
        return 'Al-Alaq (The Clot)';
      case 97:
        return 'Al-Qadr (The Power)';
      case 98:
        return 'Al-Bayyina (The Clear Evidence)';
      case 99:
        return 'Az-Zalzalah (The Earthquake)';
      case 100:
        return 'Al-Adiyat (The Courser)';
      case 101:
        return 'Al-Qaria (The Calamity)';
      case 102:
        return 'At-Takathur (The Rivalry in world increase)';
      case 103:
        return 'Al-Asr (The Declining Day)';
      case 104:
        return 'Al-Humazah (The Traducer)';
      case 105:
        return 'Al-Fil (The Elephant)';
      case 106:
        return 'Quraish (Quraish)';
      case 107:
        return 'Al-Maun (The Small Kindnesses)';
      case 108:
        return 'Al-Kawthar (Abundance)';
      case 109:
        return 'Al-Kafirun (The Disbelievers)';
      case 110:
        return 'An-Nasr (The Help)';
      case 111:
        return 'Al-Masad (The Palm Fiber)';
      case 112:
        return 'Al-Ikhlas (The Purity)';
      case 113:
        return 'Al-Falaq (The Daybreak)';
      case 114:
        return 'An-Nas (The Mankind)';
      default:
        return 'Unknown';
    }
  }
}
