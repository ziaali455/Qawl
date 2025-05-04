import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class WaveformPlayButton extends StatefulWidget {
  final String audioUrl;
  final Function(bool isPlaying) onPlayPause;
  final AudioPlayer audioPlayer;


  const WaveformPlayButton({
    Key? key,
    required this.audioUrl,
    required this.onPlayPause,
    required this.audioPlayer,
  }) : super(key: key);

  @override
  _WaveformPlayButtonState createState() => _WaveformPlayButtonState();
}

class _WaveformPlayButtonState extends State<WaveformPlayButton> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing && 
                      widget.audioPlayer.sequenceState?.currentSource?.tag == widget.audioUrl;
        });
      }
    });
  }

  void _handleTap() async {
    if (_isPlaying) {
      await widget.audioPlayer.stop();
      widget.onPlayPause(false);
    } else {
      await widget.audioPlayer.stop();
      await widget.audioPlayer.setAudioSource(
        AudioSource.asset(widget.audioUrl, tag: widget.audioUrl)
      );
      await widget.audioPlayer.play();
      widget.onPlayPause(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 30,
              width: 120,
              child: CustomPaint(
                painter: WaveformPainter(),
              ),
            ),
            const SizedBox(width: 45),

            Row(
              children: const [
                Icon(Icons.play_arrow, color: Colors.white, size: 30),
                Icon(Icons.pause, color: Colors.white, size: 30),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final double barWidth = size.width / 20;
    final List<double> barHeights = [
      10, 25, 20, 30, 15, 22, 12, 28, 18, 24, 30, 10, 22, 18, 25, 10, 30, 15, 12, 20,
      25, 30, 18, 12, 28, 15, 30, 14
    ];

    for (int i = 0; i < barHeights.length; i++) {
      double x = i * barWidth;
      double y = size.height - barHeights[i];

      canvas.drawLine(Offset(x, size.height), Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}