import 'dart:async';

import 'package:first_project/model/player.dart';
import 'package:first_project/model/question.dart';
import 'package:first_project/model/question_bank.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/quiz_homepage.dart' hide Question;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class QuizHomePage extends StatelessWidget {
  const QuizHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tajweed Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const QuizDescription(),
            const SizedBox(height: 50),
            Center(child: StartQuizButton(onStart: _navigateToQuiz)),
          ],
        ),
      ),
    );
  }

  void _navigateToQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizPage()),
    );
  }
}

class QuizDescription extends StatelessWidget {
  const QuizDescription({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'To ensure quality recitation on Qawl, we\'ve added a Tajweed test for all new users before they can upload. '
      'You will have 4 minutes to answer a series of MCQs on standard Tajweed concepts. '
      'Choose the correct answer for each question and click Submit to proceed to the next question. '
      'Good luck!',
      style: TextStyle(fontSize: 25),
    );
  }
}

class StartQuizButton extends StatelessWidget {
  final void Function(BuildContext) onStart;

  const StartQuizButton({Key? key, required this.onStart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => onStart(context),
        child: const Text(
          'Start Quiz',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.green),
          fixedSize: WidgetStateProperty.all(const Size(200, 50)),
        ));
  }
}

class QuizPage extends StatefulWidget {
  final QawlUser? user;

  const QuizPage({Key? key, this.user}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final List<Question> _questions;
  final AudioPlayer _quizAudioPlayer =
      AudioPlayer(); // Quiz-specific audio player

  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _selectedAnswerIndex = -1;
  bool _passedTest = false;
  int _remainingTime = 300; // 5 minutes in seconds
  Timer? _timer;
  Set<int> _selectedAnswers = {}; // For Select All
  Map<String, int> _selectedMatches = {}; // For Matching

  Widget _buildOptions(
      List<String> options, int selectedIndex, ValueChanged<int> onSelect) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return ListTile(
          title: Text(option),
          leading: Radio<int>(
            value: index,
            groupValue: selectedIndex,
            onChanged: (value) {
              onSelect(value!);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoice(MultipleChoiceQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Text(
            question.verse,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri', // Optional Arabic font
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ...question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return ListTile(
            title: Text(option),
            leading: Radio<int>(
              value: index,
              groupValue: _selectedAnswerIndex,
              onChanged: (value) {
                setState(() {
                  _selectedAnswerIndex = value!;
                });
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  // Select All That Apply Widget
  Widget _buildSelectAll(SelectAllQuestion question) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return CheckboxListTile(
          title: Text(option),
          value: _selectedAnswers.contains(index),
          onChanged: (isChecked) {
            setState(() {
              if (isChecked!) {
                _selectedAnswers.add(index);
              } else {
                _selectedAnswers.remove(index);
              }
            });
          },
        );
      }).toList(),
    );
  }

  // Audio-Based Question Widget
  Widget _buildAudioQuestion(AudioQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () async {
            // Load and play the audio
            //print("AUDIO PATH IS: " + question.audioUrl);
            await _quizAudioPlayer.setAsset(question.audioUrl); 
            _quizAudioPlayer.play();
          },
          child: const Text('Play Audio'),
        ),
        const SizedBox(height: 16),
        Text(
          'Select all that apply:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Column(
          children: question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;

            return CheckboxListTile(
              title: Text(option),
              value: _selectedAnswers.contains(index),
              onChanged: (isChecked) {
                setState(() {
                  if (isChecked!) {
                    _selectedAnswers.add(index);
                  } else {
                    _selectedAnswers.remove(index);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Matching Widget
  Widget _buildMatching(MatchingQuestion question) {
    return Column(
      children: question.items.map((item) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item),
            DropdownButton<int>(
              value: _selectedMatches[item],
              items: question.items.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMatches[item] = value!;
                });
              },
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _questions = QuestionBank.getQuestions();
    _startTimer();

    // pause the global audio handler, why is it disposed?
    if (audioHandler.playbackState.value.playing) {
      audioHandler.pause();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quizAudioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    // Called when the timer reaches 0
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time is up!'),
        content: const Text('You have run out of time to complete the quiz.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _submitAnswer() {
    final question = _questions[_currentQuestionIndex];

    if (question is MultipleChoiceQuestion &&
        _selectedAnswerIndex == question.correctIndex) {
      _correctAnswers++;
    } else if (question is SelectAllQuestion || question is AudioQuestion) {
      // Includes Select All and Audio Questions
      final correctIndexes = (question as dynamic)
          .correctIndexes; // Access correctIndexes dynamically
      if (_selectedAnswers.toSet().containsAll(correctIndexes) &&
          correctIndexes.toSet().containsAll(_selectedAnswers)) {
        _correctAnswers++;
      }
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = -1;
        _selectedAnswers.clear();
      });
    } else {
      _handleQuizCompletion();
    }
  }

  Future<void> _handleQuizCompletion() async {
    if (_passedTest) {
      await _verifyUser();
    }
    _showResultsDialog();
  }

  Future<void> _verifyUser() async {
    QawlUser? currentUser =
        await QawlUser.getQawlUserOrCurr(true, user: widget.user);
    if (currentUser != null) {
      currentUser.isVerified = true;
      await QawlUser.updateUserField(currentUser.id, 'isVerified', true);
      print('User verified successfully.');
    } else {
      print('User verification failed.');
    }
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text(
          _passedTest
              ? 'Congratulations! You passed the test.'
              : 'You did not pass. Better luck next time!',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Quiz'),
            Text(
              _formatTime(_remainingTime),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              question.text,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (question is MultipleChoiceQuestion)
              _buildMultipleChoice(question),
            if (question is SelectAllQuestion) _buildSelectAll(question),
            if (question is AudioQuestion) _buildAudioQuestion(question),
            if (question is MatchingQuestion) _buildMatching(question),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _canSubmitAnswer() ? _submitAnswer : null,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Method to determine if an answer can be submitted
  bool _canSubmitAnswer() {
    // if (_selectedAnswerIndex == -1 && _selectedAnswers.isEmpty) return false;
    return true;
  }
}
