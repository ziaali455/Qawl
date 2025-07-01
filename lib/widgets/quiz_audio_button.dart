import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:first_project/services/unified_audio_manager.dart';

class QuizAudioButton extends StatefulWidget {
  final String audioPath;
  final VoidCallback? onPressed;
  final bool isSelected;

  const QuizAudioButton({
    Key? key,
    required this.audioPath,
    this.onPressed,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<QuizAudioButton> createState() => _QuizAudioButtonState();
}

class _QuizAudioButtonState extends State<QuizAudioButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isPlaying = false;
  final UnifiedAudioManager _audioManager = UnifiedAudioManager();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Listen to audio state changes
    _audioManager.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          // Check if this specific quiz audio is playing
          bool isThisAudioPlaying = state.playing && 
                      _audioManager.currentAudioType == AudioType.quiz &&
                      _audioManager.currentQuizAudioPath == widget.audioPath;
          
          // Also check if audio has completed (processingState.completed)
          bool isAudioCompleted = state.processingState == ProcessingState.completed &&
                      _audioManager.currentAudioType == AudioType.quiz &&
                      _audioManager.currentQuizAudioPath == widget.audioPath;
          
          // Update playing state - stop if audio completed or not playing
          _isPlaying = isThisAudioPlaying && !isAudioCompleted;
        });
        
        if (_isPlaying) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    try {
      if (_isPlaying) {
        await _audioManager.stop();
      } else {
        await _audioManager.playQuizAudio(widget.audioPath);
      }
      widget.onPressed?.call();
    } catch (e) {
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to play audio: ${widget.audioPath.split('/').last}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Reset the playing state
      setState(() {
        _isPlaying = false;
      });
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isPlaying 
              ? Colors.green.withOpacity(0.2)
              : widget.isSelected 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey[800]?.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isPlaying 
                ? Colors.green 
                : widget.isSelected 
                    ? Colors.green.withOpacity(0.7)
                    : Colors.grey[600]!,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Soundwave container - now expanded to fill available space
            Expanded(
              child: Container(
                height: 30,
                child: _isPlaying 
                    ? AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: AnimatedWaveformPainter(
                              animation: _animation,
                              isPlaying: _isPlaying,
                            ),
                          );
                        },
                      )
                    : CustomPaint(
                        painter: StaticWaveformPainter(),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Play/Pause icon - now at the very right
            Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: _isPlaying ? Colors.green : Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedWaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isPlaying;

  AnimatedWaveformPainter({
    required this.animation,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final double barWidth = size.width / 24;
    final double maxHeight = size.height * 0.8; // Use 80% of container height
    final List<double> baseHeights = [
      10, 25, 20, 30, 15, 22, 12, 28, 18, 24, 30, 10, 22, 18, 25, 10, 30, 15, 12, 20, 16, 26, 14, 19,
    ];

    // Find the maximum base height to scale properly
    final double maxBaseHeight = baseHeights.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < baseHeights.length; i++) {
      double x = i * barWidth;
      
      // Scale the base height to fit within the container
      double scaledBaseHeight = (baseHeights[i] / maxBaseHeight) * maxHeight;
      
      // Animate the height based on the animation value
      double animatedHeight = scaledBaseHeight * (0.5 + 0.5 * animation.value);
      
      // Add some variation based on the bar index for more dynamic effect
      if (isPlaying) {
        animatedHeight *= 0.8 + 0.4 * (animation.value * (i % 3 + 1));
      }
      
      // Ensure the height doesn't exceed the container bounds
      animatedHeight = animatedHeight.clamp(2.0, maxHeight);
      
      double y = size.height - animatedHeight;

      canvas.drawLine(
        Offset(x, size.height), 
        Offset(x, y), 
        paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StaticWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final double barWidth = size.width / 24;
    final double maxHeight = size.height * 0.8; // Use 80% of container height
    final List<double> barHeights = [
      10, 25, 20, 30, 15, 22, 12, 28, 18, 24, 30, 10, 22, 18, 25, 10, 30, 15, 12, 20, 16, 26, 14, 19,
    ];

    // Find the maximum base height to scale properly
    final double maxBaseHeight = barHeights.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < barHeights.length; i++) {
      double x = i * barWidth;
      
      // Scale the height to fit within the container
      double scaledHeight = (barHeights[i] / maxBaseHeight) * maxHeight;
      
      // Ensure the height doesn't exceed the container bounds
      scaledHeight = scaledHeight.clamp(2.0, maxHeight);
      
      double y = size.height - scaledHeight;

      canvas.drawLine(Offset(x, size.height), Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 