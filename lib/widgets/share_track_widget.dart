import 'package:first_project/model/track.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class QawlShareButton extends StatelessWidget {
  final Track track;

  const QawlShareButton({Key? key, required this.track}) : super(key: key);

  Future<void> _shareTrack(BuildContext context) async {
    // final trackUrl = 'https://yourdomain.com/track?id=${track.id}';
    final trackURL = track.getAudioFile();
    final trackAuthor = await track.getAuthor();
    final shareMessage = 'Check out this recitation: ${track.getSurah()} by $trackAuthor';

    final box = context.findRenderObject() as RenderBox?;
    print("pressed share");
    await Share.share(
      '$shareMessage $trackURL',
      subject: shareMessage,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.ios_share_outlined), color: Colors.green,
      onPressed: () => _shareTrack(context),
    );
  }
}