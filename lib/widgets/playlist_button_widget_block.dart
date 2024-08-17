import 'package:first_project/model/playlist.dart';
import 'package:first_project/size_config.dart';
import 'package:flutter/material.dart';
import '../screens/playlist_screen_content.dart';

class PlaylistButtonWidget extends StatelessWidget {
//  final String title;
final bool isPersonal;
  final QawlPlaylist playlist;
  const PlaylistButtonWidget({
    Key? key,
    required this.playlist, required this.isPersonal,
    //   required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlaylistScreenContent(
                    //  Playlist: playlist,
                    playlist: playlist, isPersonal: isPersonal,
                  )),
        );
      },
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color.fromARGB(255, 13, 161, 99),
              Color.fromARGB(255, 22, 181, 93),
              Color.fromARGB(255, 32, 220, 85),
            ],
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
            child: Text(playlist.getName(),
                style:  TextStyle(
                    fontWeight: FontWeight.bold, fontSize: getProportionateScreenWidth(24)))),
      ),
    );
  }
}
