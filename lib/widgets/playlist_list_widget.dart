import 'package:first_project/deprecated/fake_playlists_data.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/playlist_screen_content.dart';
import 'package:first_project/size_config.dart';
import 'package:flutter/material.dart';

import '../model/playlist.dart';

class PlaylistListWidget extends StatelessWidget {
  final List<QawlPlaylist> playlists_List;
  final bool isPersonal;
  const PlaylistListWidget({
    Key? key,
    required this.playlists_List, required this.isPersonal,
    //required EdgeInsets padding, required List<Widget> children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 5.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (QawlPlaylist item in playlists_List)
          PlaylistItem(title: item.name, playlist: item, isPersonal: isPersonal,),
      ],
    );
  }
}

class PlaylistItem extends StatelessWidget {
  final String title;
  final bool isPersonal;
  final QawlPlaylist playlist;
  String image;
  String noimage =
      "https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3";

  PlaylistItem({
    Key? key,
    required this.title,
    required this.playlist,
    this.image =
        "https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3", required this.isPersonal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init;
    int length = playlist.list.length;
   String lengthDisplay = length.toString() + " Recitations";
    return Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlaylistScreenContent(
                      // Playlist: playlist,
                      playlist: playlist, isPersonal: isPersonal, 
                    )),
          ),
          child: Stack(children: [
            Card(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          //playlist.list.elementAt(0).coverImagePath ?? 'https://upload.wikimedia.org/wikipedia/commons/b/b9/No_Cover.jpg',
                          'https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3',
                          fit: BoxFit.cover,
                        )),
                  ),
                  selectedTileColor: Colors.green,
                  title: Text(playlist.getName()),
                  subtitle: Text(lengthDisplay),
                ),
              ],
            )),
            Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(getProportionateScreenWidth(27)),
                  child: const Icon(Icons.arrow_forward_ios),
                ))
          ]),
        ));

    // Container(
    //   decoration: BoxDecoration(border: Border.all(color: Colors.wh)),
    //   height: 50,
    //   child: Center(
    //     child: Text(
    //       title,
    //       style: TextStyle(fontSize: getProportionateScreenWidth(15)),
    //     ),
    //   ), // pass in playlist content here
    // );
  }
}
