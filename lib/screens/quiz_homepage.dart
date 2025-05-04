// import 'package:first_project/model/player.dart';
// import 'package:first_project/screens/verification_quiz_content.dart';
// import 'package:flutter/material.dart';

// class QuizHomePage extends StatelessWidget {
//   const QuizHomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Quiz App'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const QuizDescription(),
//             const SizedBox(height: 20),
//             Center(child: StartQuizButton(onStart: _navigateToQuiz)),
//           ],
//         ),
//       ),
//     );
//   }

//   void _navigateToQuiz(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const QuizPage()),
//     );
//   }
// }

// class QuizDescription extends StatelessWidget {
//   const QuizDescription({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const Text(
//       'To ensure quality recitation on Qawl, we\'ve added a Tajweed test for all new users before they upload.'
//       'You will have 7 minutes to answer a series of MCQs on standard Tajweed concepts. '
//       'Choose the correct answer for each question and click Submit to proceed to the next question. '
//       'Good luck!',
//       style: TextStyle(fontSize: 16),
//     );
//   }
// }

// class StartQuizButton extends StatelessWidget {
//   final void Function(BuildContext) onStart;

//   const StartQuizButton({Key? key, required this.onStart}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () => onStart(context),
//       child: const Text('Start Quiz'),
//     );
//   }

  
// }



