import 'package:first_project/deprecated/fake_playlists_data.dart';
import 'package:first_project/model/playlist.dart';
import 'package:first_project/model/track.dart';
import 'package:first_project/widgets/playlist_list_widget.dart';
import 'package:first_project/widgets/search_field.dart';
import 'package:first_project/widgets/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import '../../../../size_config.dart';

class HomePageContent extends StatefulWidget {
  //final Playlist playlist;
  //final List<Playlist> playlists;

  const HomePageContent({Key? key}) : super(key: key);
  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  // late List<Playlist> playlists;

  // _HomePageContentState(List<Playlist> playlists) {
  //   this.playlists = playlists;
  // }

  // late Playlist playlist;

  // _HomePageContentState(Playlist playlist) {
  //   this.playlist = playlist;
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            WidgetAnimator(
              incomingEffect: WidgetTransitionEffects.incomingSlideInFromTop(),
              child: SectionTitle(
                title: "My Playlists",
                press: () {},
              ),
            ),
            const SizedBox(height: 20),

            // Favorites Playlist Section
            FutureBuilder<QawlPlaylist?>(
              future: QawlPlaylist.getFavorites(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.green);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  QawlPlaylist? favoritesPlaylist = snapshot.data;
                  if (favoritesPlaylist != null &&
                      favoritesPlaylist.list.isNotEmpty) {
                    return PlaylistListWidget(
                      playlists_List: [favoritesPlaylist],
                      isPersonal: false,
                    );
                  } else {
                    return WidgetAnimator(
                      incomingEffect:
                          WidgetTransitionEffects.incomingSlideInFromBottom(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "To add to your library, add a track to your favorites with the ",
                              ),
                              WidgetSpan(
                                child: Icon(Icons.favorite, size: 18),
                              ),
                              TextSpan(
                                text:
                                    " button and follow your favorite reciters! ",
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
            ),

            // Following Playlist Section
            //const SizedBox(height: 10),
            FutureBuilder<QawlPlaylist?>(
              future: QawlPlaylist.getFollowingPlaylist(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.green);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  QawlPlaylist? followingPlaylist = snapshot.data;
                  if (followingPlaylist != null &&
                      followingPlaylist.list.isNotEmpty) {
                    return PlaylistListWidget(
                      playlists_List: [followingPlaylist],
                      isPersonal: false,
                    );
                  } else {
                    return WidgetAnimator(
                      incomingEffect:
                          WidgetTransitionEffects.incomingSlideInFromBottom(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No tracks available from the users you're following. Start following your favorite reciters to see their tracks here!",
                          style: const TextStyle(fontSize: 16.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
