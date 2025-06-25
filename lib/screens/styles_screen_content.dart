import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/screens/playlist_screen_content.dart';
import 'package:first_project/size_config.dart';
import 'package:first_project/widgets/qawl_back_button_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class StylesContent extends StatefulWidget {
  @override
  _StylesContentState createState() => _StylesContentState();
}

class _StylesContentState extends State<StylesContent> {
  bool _isVisible = true; // Initialize _isVisible

  // void _toggleVisibility() {
  //   setState(() {
  //     _isVisible = !_isVisible; // Toggle the visibility when the button is pressed
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const QawlBackButton(), // Optional: Replace with your custom button
                Tooltip(
                    showDuration: Duration(seconds: 10),
                    message:
                        'The Prophet صلى الله عليه وسلم said in a Hadith, \“The Qur\ʾān has been revealed in seven aḥruf (modes). Recite it in a way that is easy for you.\” Scholars understand this to mean that the Qur\ʾān was revealed with variations in pronunciation, vocabulary, and meaning to accommodate different Arabic dialects. These variations are preserved in ten canonical recitation styles (qirā\ʾāt) taught worldwide. They make the Qur\ʾān easier to recite for Muslims globally and highlight its depth, with all differences carefully preserved through oral transmission. (Basil Farooq, Saima Yacoob)  (Narrated by al-Bukhaari, 2287; Muslim, 818)',
                    child: Row(children: [
                      Text("What are styles? (tap and hold)"),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          // Optionally, you could display a dialog or snackbar here
                          print("Info button tapped");
                        },
                      ),
                    ])),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // Two items per row
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              padding: const EdgeInsets.all(16.0),
              children: List.generate(items.length, (index) {
                return GestureDetector(
                  onTap: () async {
                    // MUSA: This is where the playlist of X style will be loaded. An example of this can be seen in Top 100, Recent, etc
                    String selectedStyle = items[index];
                    //await Track.setDefaultStyleForAllTracks("Hafs 'an Asim");

                    QawlPlaylist stylePlaylist =
                        await QawlPlaylist.getStylesPlaylist(selectedStyle);
                    if (stylePlaylist.getCount() == 0) {
                      // add snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No uploads found for ${items[index]}.'),
                          duration: Duration(
                              seconds:
                                  1),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlaylistScreenContent(
                                playlist: stylePlaylist, isPersonal: false)),
                      );
                    }
                    print("Tapped on item ${items[index]}");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 13, 161, 99),
                          Color.fromARGB(255, 22, 181, 93),
                          Color.fromARGB(255, 32, 220, 85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Center(
                      child: Text(
                        items[index],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

final List<String> items = [
  'Hafs \'an Asim',
  'Shu\'bah \'an Asim',
  'Warsh \'an Nafi\'',
  'Qaloon \'an Nafi\'',
  'Duri \'an Abu Amr',
  'Susi \'an Abu Amr',
  'Bazzi Ibn Kathir',
  'Qunbul Ibn Kathir',
  'Duri an Kisa\'i',
  'Abu al-Harith an Kisa\'i',
  'Hisham \'an Ibn Amir',
  'Ibn Dakhwan \'an Ibn Amir',
  'Khalaf \'an Hamzah',
  'Khallad \'an Hamzah',
  'Ibn Wardan \'an Abu Ja\'far',
  'Ibn Jammaz \'an Abu Ja\'far',
  'Ruwais an Ya\'qub',
  'Rawh \'an Ya\'qub',
  'Ishaq \'an Khalaf',
  'Idris \'an Khalaf'
];
// AnimatedOpacity(
//                   duration: const Duration(seconds: 1), // Animation duration
//                   opacity: _isVisible ? 1.0 : 0.0, // Opacity value based on visibility
//                   child: Text(
//                         'Fading Box', // Text displayed inside the box
//                         style: TextStyle(
//                           color: Colors.white, // Text color
//                           fontSize: 20.0, // Text font size
//                         ),
//                       ),
//                 ),