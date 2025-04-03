import 'package:first_project/model/playlist.dart';
import 'package:first_project/widgets/playlist_manager_widget.dart';
import 'package:flutter/material.dart';

class AllFoldersScreen extends StatelessWidget {
  final List<QawlPlaylist> playlists;
  final bool isPersonal;

  const AllFoldersScreen({
    Key? key,
    required this.playlists,
    required this.isPersonal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Collections"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: playlists.isEmpty
          ? const Center(
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
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return FolderListItem(
                  playlist: playlist,
                  isPersonal: isPersonal,
                  onAddTracks: (_) {}, // Empty callback
                  onRefresh: () {}, // Empty callback since we don't refresh this list
                );
              },
            ),
    );
  }
}