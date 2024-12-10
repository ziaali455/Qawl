import 'question.dart';

class QuestionBank {
  static List<Question> getQuestions() {
    return [
      MultipleChoiceQuestion(
        'What Rule is applied below?',
        ['3', '4', '5'],
        1, // Correct index
        "AYAH Y"
      ),
      SelectAllQuestion(
        'Select all Heavy Letters.',
        ['2', '3', '4', '5', '6'],
        [0, 1, 3], // Correct indices
      ),
      SelectAllQuestion(
        'Select all Letters of the Throat.',
        ['2', '3', '4', '5', '6'],
        [0, 1, 3], // Correct indices
      ),
       MultipleChoiceQuestion(
        'Which word in the following verse contains Ghunna?',
        ['x', 'y', 'z'],
        1, // Correct index
        "AYAH X",
      ),
      AudioQuestion(
        'Identify the Tajweed rules in this audio snippet.',
        'assets/100-KB-MP3.mp3', // LOAD IN HERE AND ADD TO PUBSPEC, THEN CLEAN/PUB GET
        ['Idgham', 'Ikhfa', 'Qalqala', 'Ghunna'],
        [0, 1], // Multiple correct answers: Idgham and Ikhfa
      ),
      MatchingQuestion(
        'Match the Madd (extension) to its Length.',
        ['Laazim', 'Badal (natural madd)', 'Muttasil'],
        {0: 1, 1: 2, 2: 0}
      ),
    ];
  }
}
