import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  Map<String, dynamic> _selectedMatches = {}; // For Matching

  Widget _buildOptions(
      List<String> options, int selectedIndex, ValueChanged<int> onSelect) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return ListTile(
          title: Text(option, style: TextStyle(fontSize: 20),),
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
    return SingleChildScrollView(
      child: Column(
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
              title: Text(option, style: TextStyle(fontSize: 20),),
              leading: Radio<int>(
                value: index,
                groupValue: _selectedAnswerIndex,
                focusColor: Colors.green,
                activeColor: Colors.green,
                
                onChanged: (value) {
                  setState(() {
                    _selectedAnswerIndex = value!;
                  });
                  print(
                      "SELECTED INDEX IS: " + _selectedAnswerIndex.toString());
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Select All That Apply Widget
  Widget _buildSelectAll(SelectAllQuestion question) {
    return SingleChildScrollView(
      child: Column(
        children: question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return CheckboxListTile(
            
            activeColor: Colors.green,
            checkColor: Colors.white,
            title: Text(option, style: TextStyle(fontSize: 20),),
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
    );
  }

  // Select rules from audio
  Widget _buildAudioSelectAllQuestion(SelectFromSingleAudioQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
 
            onPressed: () async {
              // Load and play the audio
              print("AUDIO PATH IS: " + question.audioUrl);
              await _quizAudioPlayer.stop();
              await _quizAudioPlayer.setAsset(question.audioUrl);
              _quizAudioPlayer.play();
            },
            child: const Text('Play Audio', style: TextStyle(fontSize: 20),),
          ),
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
              activeColor: Colors.green,
              checkColor: Colors.white,
              title: Text(option, style: TextStyle(fontSize: 20),),
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
//inactive but works
  // Widget _buildMultipleChoiceAudio(SelectCorrectAudioQuestion question) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const SizedBox(height: 16),
  //       Center(
  //         child: Text(
  //           question.arabicText,
  //           style: const TextStyle(
  //             fontSize: 24,
  //             fontWeight: FontWeight.bold,
  //             fontFamily: 'Amiri',
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       ...question.audioURLs.asMap().entries.map((entry) {
  //         final index = entry.key;
  //         final audioUrl = entry.value;

  //         return ListTile(
  //           title: ElevatedButton(
  //             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
  //             onPressed: () async {
  //               await _quizAudioPlayer.stop();
  //               await _quizAudioPlayer.setAsset(audioUrl ?? '');
  //               _quizAudioPlayer.play();
  //             },
  //             child: Text('Play Option ${index + 1}'),
  //           ),
  //           leading: Radio<int>(
  //             value: index,
  //             groupValue: _selectedAnswerIndex,
  //             onChanged: (value) {
  //               setState(() {
  //                 _selectedAnswerIndex = value!;
  //               });
  //             },
  //             // fillColor: WidgetStateProperty.resolveWith<Color>((states) {
  //             //   if (states.contains(WidgetState.selected)) {
  //             //     return Colors.green; // Selected color
  //             //   }
  //             //   return Colors.green.withOpacity(0.6); // Unselected color
  //             // }),
  //           ),
  //         );
  //       }).toList(),
  //     ],
  //   );
  // }

  // Matching Widget
  Widget _buildMatching<T>(MatchingQuestion<T> question) {
  return Column(
    children: question.shuffledKeys.map((key) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Display the shuffled key
          Text(key, style: TextStyle(fontSize: 20),),

          // Dropdown for shuffled values
          DropdownButton<T>(
            value: _selectedMatches[key] as T?, // Cast to T
            items: question.shuffledValues.map((value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Text(value.toString(), style: TextStyle(fontSize: 18),), // Convert value to String for display
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMatches[key] = value; // Store the selected value
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
      // audioHandler.dispose();
      //
    }
  }
            
  @override
  void dispose() {
    _timer?.cancel();
    // _quizAudioPlayer.dispose();
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
            child: const Text('OK', style: TextStyle(color: Colors.green),),
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
    _quizAudioPlayer.stop();
    // Check answer based on question type
    if (question is MultipleChoiceQuestion) {
      if (_selectedAnswerIndex == question.correctIndex) {
        _correctAnswers++;
      }
    } else if (question is SelectAllQuestion ||
        question is SelectFromSingleAudioQuestion) {
      // For Select All questions, compare selected answers with the correct set
      final correctIndexes = (question as dynamic).correctIndexes;
      if (_selectedAnswers.toSet().containsAll(correctIndexes) &&
          correctIndexes.toSet().containsAll(_selectedAnswers)) {
        _correctAnswers++;
      }
    } else if (question is MatchingQuestion) {
      // For Matching questions, ensure all matches are correct
      bool isCorrect = question.correctMatches.entries.every((entry) {
        final key = entry.key;
        final value = entry.value;
        return _selectedMatches[key] == value;
      });
      if (isCorrect) {
        _correctAnswers++;
      }
    } else if (question is SelectCorrectAudioQuestion) {
      if (_selectedAnswerIndex == question.correctAudioIndex) {
        _correctAnswers++;
      }
    }

    // Move to the next question or finish the quiz
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
    final passingScore = (_questions.length * 0.9).ceil();
    _passedTest = _correctAnswers >= passingScore;

    if (_passedTest) {
      await _verifyUser();
    }
    _showResultsDialog();
  }

// Future<void> _updateUserVerification() async {
//   final docRef = FirebaseFirestore.instance
//       .collection('QawlUsers')
//       .doc(currentUserUid);

//   await docRef.update({'isVerified': true});
//   _fetchFirebaseData(); // Manually reload after the update
// }

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
            child: const Text('OK', style: TextStyle(color: Colors.green),),
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
            const Text('Tajweed Quiz'),
            Text(
              _formatTime(_remainingTime),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                style:
                    const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                question.text,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              if (question is MultipleChoiceQuestion)
                _buildMultipleChoice(question),
              if (question is SelectAllQuestion) _buildSelectAll(question),
              if (question is SelectFromSingleAudioQuestion)
                _buildAudioSelectAllQuestion(question),
              // if (question is SelectCorrectAudioQuestion)
              //   _buildMultipleChoiceAudio(question),
              if (question is MatchingQuestion) _buildMatching(question),
              const SizedBox(height: 20),
              Center(

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _canSubmitAnswer() ? _submitAnswer : null,
                  
                  child: const Text('Submit', style: TextStyle(fontSize: 20),),
                ),
              ),
            ],
          ),
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
