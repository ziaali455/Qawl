import 'package:first_project/deprecated/fake_playlists_data.dart';
import 'package:first_project/deprecated/fake_user_data.dart';
import 'package:first_project/screens/playlist_screen_content.dart';
import 'package:flutter/material.dart';

import '../../../../size_config.dart';
import '../model/playlist.dart';
import '../model/user.dart';

class PlaylistSectionTitle extends StatelessWidget {
  PlaylistSectionTitle({
    Key? key,
    required this.title,
    required this.press,
    required this.playlist,
    this.qaris,
    required this.isPlaylist, required this.isPersonal,
  }) : super(key: key);

  final String title;
  QawlPlaylist playlist;
  List<QawlUser>? qaris = [];
  final GestureTapCallback press;
  final bool isPlaylist;
  final bool isPersonal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: getProportionateScreenWidth(28),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          isPlaylist
              ? SeeMoreButton(playlist: playlist, isPersonal: isPersonal,)
              : SizedBox(height: 0),
        ],
      ),
    );
  }
}

class SeeMoreButton extends StatelessWidget {
  final QawlPlaylist playlist;
  final bool isPersonal;

  const SeeMoreButton({
    super.key,
    required this.playlist, required this.isPersonal,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlaylistScreenContent(
                      playlist: playlist, isPersonal: isPersonal,
                    )),
          );
        },
        child: Text(
          "See More",
          style: TextStyle(
              color: Colors.white70,
              fontSize: getProportionateScreenWidth(15)),
        ));
  }
}

class SectionTitle extends StatelessWidget {
  SectionTitle({
    Key? key,
    required this.title,
    required this.press,
  }) : super(key: key);

  final String title;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: getProportionateScreenWidth(28),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
