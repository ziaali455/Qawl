import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/screens/all_folders_screen.dart';
import 'package:first_project/widgets/explore_track_widget_block.dart';
import 'package:flutter/material.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/playlist_screen_content.dart';
import 'package:first_project/size_config.dart';

class PlaylistFoldersWidget extends StatefulWidget {
  final QawlUser user;
  final bool isPersonal;

  const PlaylistFoldersWidget({
    Key? key,
    required this.user,
    required this.isPersonal,
  }) : super(key: key);

  @override
  _PlaylistFoldersWidgetState createState() => _PlaylistFoldersWidgetState();
}

class _PlaylistFoldersWidgetState extends State<PlaylistFoldersWidget> {
  late Future<List<QawlPlaylist>> _playlistsFuture;
  final TextEditingController _playlistNameController = TextEditingController();
  final int _maxFoldersToShow =
      1; // Only show 1 folder in preview, then "See More"

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  void _loadPlaylists() {
    _playlistsFuture = QawlPlaylist.getUserPlaylists(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Collections',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              FutureBuilder<List<QawlPlaylist>>(
                future: _playlistsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  } else if (snapshot.hasError) {
                    return const SizedBox.shrink();
                  } else {
                    final playlists = snapshot.data ?? [];
                    final bool hasMorePlaylists =
                        playlists.length > _maxFoldersToShow;

                    if (hasMorePlaylists) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to a screen showing all playlists
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllFoldersScreen(
                                playlists: playlists,
                                isPersonal: widget.isPersonal,
                              ),
                            ),
                          ).then((_) => _refreshPlaylists());
                        },
                        child: Text(
                          "See More",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: getProportionateScreenWidth(15),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                },
              ),
            ],
          ),
        ),
        FutureBuilder<List<QawlPlaylist>>(
          future: _playlistsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)));
            } else {
              final playlists = snapshot.data ?? [];
              final bool hasMorePlaylists =
                  playlists.length > _maxFoldersToShow;

              // Only show up to the maximum number of folders
              final displayedPlaylists = hasMorePlaylists
                  ? playlists.sublist(0, _maxFoldersToShow)
                  : playlists;

              return Column(
                children: [
                  if (widget.isPersonal) _buildNewFolderButton(),
                  if (displayedPlaylists.isEmpty && !widget.isPersonal)
                    // Empty state for other users' collections
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This user has not added any collections yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (displayedPlaylists.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedPlaylists.length,
                      itemBuilder: (context, index) {
                        return FolderListItem(
                          playlist: displayedPlaylists[index],
                          isPersonal: widget.isPersonal,
                          onAddTracks: _showAddTracksDialog,
                          onRefresh: _refreshPlaylists,
                        );
                      },
                    ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  void _refreshPlaylists() {
    setState(() {
      _loadPlaylists();
    });
  }

  Widget _buildNewFolderButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: InkWell(
        onTap: _showCreateFolderDialog,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.green.withOpacity(0.2),
                  child: const Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
              ),
            ),
            title: const Text(
              'New Collection',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Create a new collection',
              style: TextStyle(
                color: Colors.grey[400],
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ),
      ),
    );
  }

  void _showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Collection'),
        content: TextField(
          controller: _playlistNameController,
          decoration: const InputDecoration(
            hintText: 'Collection Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _createPlaylist,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPlaylist() async {
    if (_playlistNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a collection name')),
      );
      return;
    }

    await QawlPlaylist.createUserPlaylist(
      widget.user.id,
      _playlistNameController.text.trim(),
    );

    _playlistNameController.clear();
    setState(() {
      _loadPlaylists();
    });

    Navigator.pop(context);
  }

  void _showAddTracksDialog(QawlPlaylist playlist) async {
    // Fetch user's uploaded tracks
    List<Track> userTracks = await Track.getTracksByUser(widget.user);

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
                  setState(() {
                    _loadPlaylists();
                  });
                  Navigator.pop(context);
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
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class FolderListItem extends StatelessWidget {
  final QawlPlaylist playlist;
  final bool isPersonal;
  final Function(QawlPlaylist) onAddTracks;
  final VoidCallback onRefresh;

  const FolderListItem({
    Key? key,
    required this.playlist,
    required this.isPersonal,
    required this.onAddTracks,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int length = playlist.list.length;
    String lengthDisplay = "$length Recitations";

    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistScreenContent(
              playlist: playlist,
              isPersonal: isPersonal,
            ),
          ),
        ).then((_) => onRefresh()),
        child: Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: AspectRatio(
                      aspectRatio: 1.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.green.withOpacity(0.2),
                          child: const Icon(
                            Icons.folder,
                            color: Colors.green,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      playlist.getName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      lengthDisplay,
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                    trailing: isPersonal
                        ? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.green),
                            onSelected: (value) =>
                                _handleMenuAction(context, value),
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(
                                value: 'add_tracks',
                                child: Text('Add Recitations'),
                              ),
                              const PopupMenuItem(
                                value: 'remove_tracks',
                                child: Text('Remove Recitations'),
                              ),
                              const PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          )
                        : null,
                  ),
                ],
              ),
            ),
            if (!isPersonal)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(getProportionateScreenWidth(27)),
                  child:
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'add_tracks':
        onAddTracks(playlist);
        break;
      case 'remove_tracks':
        _showRemoveTracksDialog(context);
        break;
      case 'rename':
        _showRenameDialog(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showRemoveTracksDialog(BuildContext context) {
    if (playlist.list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This collection is empty')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove tracks from ${playlist.name}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlist.list.length,
            itemBuilder: (context, index) {
              final track = playlist.list[index];
              return ListTile(
                title: Text(track.trackName),
                subtitle: Text(
                    'Surah ${SurahMapper.getSurahNameByNumber(track.surahNumber)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red),
                  onPressed: () async {
                    await QawlPlaylist.removeTrackFromPlaylist(playlist, track);
                    Navigator.pop(context);
                    onRefresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Removed ${track.trackName} from ${playlist.name}')),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'New Collection Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('QawlPlaylists')
                    .doc(playlist.id)
                    .update({'name': controller.text.trim()});

                Navigator.pop(context);
                onRefresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Collection renamed to "${controller.text.trim()}"')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text(
            'Are you sure you want to delete "${playlist.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('QawlPlaylists')
                  .doc(playlist.id)
                  .delete();

              Navigator.pop(context);
              onRefresh();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Collection "${playlist.name}" deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
