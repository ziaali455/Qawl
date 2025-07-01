import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/widgets/playlist_manager_widget.dart';
import 'package:first_project/widgets/qawl_back_button_widget.dart';
import 'package:first_project/widgets/explore_track_widget_block.dart';
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

  void _showAddTracksDialog(QawlPlaylist playlist) async {
    // Fetch user's uploaded tracks
    QawlUser? currentUser = await QawlUser.getCurrentQawlUser();
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get current user')),
      );
      return;
    }

    List<Track> userTracks = await Track.getTracksByUser(currentUser);

    // Filter out tracks that are already in the playlist
    List<String> playlistTrackIds =
        playlist.list.map((track) => track.id).toList();
    List<Track> availableTracks = userTracks
        .where((track) => !playlistTrackIds.contains(track.id))
        .toList();

    if (availableTracks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to add any uploads to this collection')),
      );
      return;
    }

    // Show dialog with available tracks
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add uploads to ${playlist.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableTracks.length,
            itemBuilder: (context, index) {
              final track = availableTracks[index];
              return ListTile(
                title: Text(track.trackName),
                subtitle: Text(
                    'Surah ${SurahMapper.getSurahNameByNumber(track.surahNumber)}'),
                onTap: () async {
                  await QawlPlaylist.addTrackToPlaylist(playlist.id, track.id);
                  Navigator.pop(context);
                  _refreshPlaylists();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Added ${track.trackName} to ${playlist.name}')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _refreshPlaylists() async {
    if (isPersonal) {
      QawlUser? currentUser = await QawlUser.getCurrentQawlUser();
      if (currentUser != null) {
        List<QawlPlaylist> updatedPlaylists = await QawlPlaylist.getUserPlaylists(currentUser.id);
        setState(() {
          playlists = updatedPlaylists;
        });
      }
    }
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
                      onAddTracks: _showAddTracksDialog,
                      onRefresh: _refreshPlaylists,
                    ),
                  ),
                ),
          ]),
        ),
      ),
    );
  }
}