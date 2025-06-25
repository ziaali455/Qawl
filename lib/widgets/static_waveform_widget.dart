import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:first_project/services/unified_audio_manager.dart';

class WaveformPlayButton extends StatefulWidget {
  final String audioUrl;
  final Function(bool isPlaying) onPlayPause;

  const WaveformPlayButton({
    Key? key,
    required this.audioUrl,
    required this.onPlayPause,
  }) : super(key: key);

  @override
  _WaveformPlayButtonState createState() => _WaveformPlayButtonState();
}

class _WaveformPlayButtonState extends State<WaveformPlayButton> {
  bool _isPlaying = false;
  final UnifiedAudioManager _audioManager = UnifiedAudioManager();

  @override
  void initState() {
    super.initState();
    _audioManager.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing && 
                      _audioManager.currentAudioType == AudioType.quiz &&
                      _audioManager.currentQuizAudioPath == widget.audioUrl;
        });
      }
    });
  }

  void _handleTap() async {
    if (_isPlaying) {
      await _audioManager.stop();
      widget.onPlayPause(false);
    } else {
      await _audioManager.playQuizAudio(widget.audioUrl);
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
          color: _isPlaying 
              ? Colors.green.withOpacity(0.2)
              : Colors.grey[800]?.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPlaying ? Colors.green : Colors.grey[600]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 30,
              width: 120,
              child: CustomPaint(
                painter: WaveformPainter(isPlaying: _isPlaying),
              ),
            ),
            const SizedBox(width: 16),
            
            Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: _isPlaying ? Colors.green : Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final bool isPlaying;
  
  WaveformPainter({this.isPlaying = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isPlaying ? Colors.green : Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final double barWidth = size.width / 20;
    final List<double> barHeights = [
      10, 25, 20, 30, 15, 22, 12, 28, 18, 24, 30, 10, 22, 18, 25, 10, 30, 15, 12, 20,
    ];

    for (int i = 0; i < barHeights.length; i++) {
      double x = i * barWidth;
      double y = size.height - barHeights[i];

      canvas.drawLine(Offset(x, size.height), Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}