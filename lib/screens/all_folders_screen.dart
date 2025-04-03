import 'package:first_project/model/playlist.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/widgets/playlist_manager_widget.dart';
import 'package:flutter/material.dart';
import 'package:first_project/size_config.dart';
import 'package:first_project/neu_box.dart';

class AllFoldersScreen extends StatefulWidget {
  final List<QawlPlaylist> playlists;
  final bool isPersonal;

  const AllFoldersScreen({
    Key? key,
    required this.playlists,
    required this.isPersonal,
  }) : super(key: key);

  @override
  State<AllFoldersScreen> createState() => _AllFoldersScreenState(playlists, isPersonal);
}

class _AllFoldersScreenState extends State<AllFoldersScreen> {
  late List<QawlPlaylist> playlists;
  final bool isPersonal;

  _AllFoldersScreenState(List<QawlPlaylist> playlists, this.isPersonal) {
    this.playlists = playlists;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(children: [
            // back button and menu button
            const SizedBox(height: 50),
            QawlBackButton(),

            Container(
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "All Collections",
                  style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            if (playlists.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_outlined, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      "No Collections found",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              for (var playlist in playlists)
                Material(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: FolderListItem(
                      playlist: playlist,
                      isPersonal: isPersonal,
                      onAddTracks: (_) {}, // Empty callback
                      onRefresh: () {}, // Empty callback since we don't refresh this list
                    ),
                  ),
                ),
          ]),
        ),
      ),
    );
  }
}