
import 'dart:async';

import 'package:first_project/model/user.dart';
import 'package:flutter/material.dart';

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
      child: const Text('Start Quiz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.green), fixedSize: WidgetStateProperty.all(const Size(200, 50)),)
    );
  }
}
class QuizPage extends StatefulWidget {
  final QawlUser? user;

  const QuizPage({Key? key, this.user}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<Question> _questions = [
    Question('What is 2 + 2?', ['3', '4', '5'], 1),
    Question('What is the capital of France?', ['Berlin', 'Paris', 'Madrid'], 1),
  ];

  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _selectedAnswerIndex = -1;
  bool _passedTest = false;
  int _remainingTime = 300; // 5 minutes in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    if (_selectedAnswerIndex == _questions[_currentQuestionIndex].correctIndex) {
      _correctAnswers++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = -1;
      });
    } else {
      setState(() {
        _passedTest = _correctAnswers == _questions.length;
      });
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
              _formatTime(_remainingTime), // Display the timer in the AppBar
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
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _selectedAnswerIndex == -1 ? null : _submitAnswer,
                child: const Text('Submit',
                ),
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.green), fixedSize: WidgetStateProperty.all(const Size(100, 25)))
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctIndex;

  Question(this.text, this.options, this.correctIndex);
}
