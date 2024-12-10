import 'package:first_project/model/player.dart';
import 'package:first_project/screens/verification_quiz_content.dart';
import 'package:flutter/material.dart';

class QuizHomePage extends StatelessWidget {
  const QuizHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QuizDescription(),
            const SizedBox(height: 20),
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
      'To ensure quality recitation on Qawl, we\'ve added a Tajweed test for all new users before they upload.'
      'You will have 4 minutes to answer a series of MCQs on standard Tajweed concepts. '
      'Choose the correct answer for each question and click Submit to proceed to the next question. '
      'Good luck!',
      style: TextStyle(fontSize: 16),
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
      child: const Text('Start Quiz'),
    );
  }

  
}



class _QuizPageState extends State<QuizPage> {
  final List<Question> _questions = [
    Question('What is 2 + 2?', ['3', '4', '5'], 1),
    Question('What is the capital of France?', ['Berlin', 'Paris', 'Madrid'], 1),
  ];
  // @override
  // void initState() {
  //   super.initState();

  //   // Pause the global audio handler if it's playing
  //   if (audioHandler.playbackState.value.playing) {
  //     audioHandler.pause();
  //   }

  //   }

  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _selectedAnswerIndex = -1;
  bool _passedTest = false;

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
      _showResultsDialog();
    }
  }

 


  void _showResultsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text(
          _passedTest
              ? 'Congratulations! You passed the test. You are now a verified reciter'
              : 'You did not pass. Please try again!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Ok'),
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.green), fixedSize: WidgetStateProperty.all(const Size(100, 25)))
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
        title: const Text('Quiz'),
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
                child: const Text('Submit'),
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
