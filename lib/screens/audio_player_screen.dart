// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
// import 'package:cached_network_image/cached_network_image.dart';


// class AudioPlayerScreen extends StatefulWidget {
//   @override
//   _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
// }

// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   late ConcatenatingAudioSource _playlist;

//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }

//   Future<void> _init() async {
//     _playlist = ConcatenatingAudioSource(children: [
//       AudioSource.asset(
//         'assets/audio/nature.mp3',
//         tag: MediaItem(
//           id: '1',
//           title: 'Nature Sound',
//           artist: 'Unknown',
//           artUri: Uri.parse('https://example.com/nature.jpg'),
//         ),
//       ),
//       AudioSource.uri(
//         Uri.parse('https://example.com/audio.mp3'),
//         tag: MediaItem(
//           id: '2',
//           title: 'Online Audio',
//           artist: 'Unknown',
//           artUri: Uri.parse('https://example.com/audio.jpg'),
//         ),
//       ),
//     ]);
//     await _audioPlayer.setAudioSource(_playlist);
//     _audioPlayer.setLoopMode(LoopMode.all);
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Audio Player'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           StreamBuilder<MediaItem?>(
//             stream: _audioPlayer.sequenceStateStream
//                 .map((state) => state?.currentSource?.tag as MediaItem?),
//             builder: (context, snapshot) {
//               final mediaItem = snapshot.data;
//               return mediaItem == null
//                   ? SizedBox()
//                   : MediaMetadata(
//                       title: mediaItem.title,
//                       artist: mediaItem.artist ?? '',
//                       imageUrl: mediaItem.artUri.toString(),
//                     );
//             },
//           ),
//           SizedBox(height: 20),
//           StreamBuilder<PositionData>(
//             stream: _positionDataStream,
//             builder: (context, snapshot) {
//               final positionData = snapshot.data;
//               return ProgressBar(
//                 progress: positionData?.position ?? Duration.zero,
//                 buffered: positionData?.bufferedPosition ?? Duration.zero,
//                 total: positionData?.duration ?? Duration.zero,
//                 onSeek: _audioPlayer.seek,
//               );
//             },
//           ),
//           Controls(audioPlayer: _audioPlayer),
//         ],
//       ),
//     );
//   }

//   Stream<PositionData> get _positionDataStream =>
//       Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//         _audioPlayer.positionStream,
//         _audioPlayer.bufferedPositionStream,
//         _audioPlayer.durationStream,
//         (position, bufferedPosition, duration) =>
//             PositionData(position, bufferedPosition, duration ?? Duration.zero),
//       );
// }

// class Controls extends StatelessWidget {
//   final AudioPlayer audioPlayer;

//   Controls({required this.audioPlayer});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: Icon(Icons.skip_previous),
//           onPressed: () => audioPlayer.seekToPrevious(),
//         ),
//         StreamBuilder<bool>(
//           stream: audioPlayer.playingStream,
//           builder: (context, snapshot) {
//             final playing = snapshot.data ?? false;
//             return IconButton(
//               icon: Icon(playing ? Icons.pause : Icons.play_arrow),
//               onPressed: () => playing ? audioPlayer.pause() : audioPlayer.play(),
//             );
//           },
//         ),
//         IconButton(
//           icon: Icon(Icons.skip_next),
//           onPressed: () => audioPlayer.seekToNext(),
//         ),
//       ],
//     );
//   }
// }

// class MediaMetadata extends StatelessWidget {
//   final String title;
//   final String artist;
//   final String imageUrl;

//   MediaMetadata({required this.title, required this.artist, required this.imageUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CachedNetworkImage(
//           imageUrl: imageUrl,
//           placeholder: (context, url) => CircularProgressIndicator(),
//           errorWidget: (context, url, error) => Icon(Icons.music_note, size: 100),
//           imageBuilder: (context, imageProvider) => Container(
//             width: 200,
//             height: 200,
//             decoration: BoxDecoration(
//               image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         Text(artist, style: TextStyle(fontSize: 14, color: Colors.grey)),
//       ],
//     );
//   }
// }

// class PositionData {
//   final Duration position;
//   final Duration bufferedPosition;
//   final Duration duration;

//   PositionData(this.position, this.bufferedPosition, this.duration);
// }
