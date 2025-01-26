import 'package:just_audio/just_audio.dart';

enum QuestionType {
  multipleChoice,
  selectAll,
  audioBased,
  matching,
}

abstract class Question {
  final String text;
  final QuestionType type;

  Question(this.text, this.type);
}

// Multiple Choice Question
class MultipleChoiceQuestion extends Question {
  final List<String> options;
  final int correctIndex;
  final String verse; // New field for Arabic text

  MultipleChoiceQuestion(
      String text, this.options, this.correctIndex, this.verse)
      : super(text, QuestionType.multipleChoice);
}

// Select All That Apply Question
class SelectAllQuestion extends Question {
  final List<String> options;
  final List<int> correctIndexes; // Multiple correct answers

  SelectAllQuestion(String text, this.options, this.correctIndexes)
      : super(text, QuestionType.selectAll);
}

// select options based on a single audio clip
class SelectFromSingleAudioQuestion extends Question {
  final String audioUrl;
  final List<String> options;
  final List<int> correctIndexes; // Multiple correct answers for Select All

  SelectFromSingleAudioQuestion(
      String text, this.audioUrl, this.options, this.correctIndexes)
      : super(text, QuestionType.selectAll);
}

// select the correct audio of ayah, each choice is audio player
class SelectCorrectAudioQuestion extends Question {
  final List<String?> audioURLs;
  final int correctAudioIndex;
  final String arabicText;

  SelectCorrectAudioQuestion(
      String text, this.audioURLs, this.correctAudioIndex, this.arabicText)
      : super(text, QuestionType.audioBased);

}

// Matching Question (uses generic typs for both string to string and string to int maps)
class MatchingQuestion<T> extends Question {
  final Map<String, T> correctMatches;
  late final List<String> shuffledKeys;
  late final List<T> shuffledValues;

  MatchingQuestion(String text, this.correctMatches)
      : super(text, QuestionType.matching) {
    shuffledKeys = correctMatches.keys.toList()..shuffle();
    shuffledValues = (correctMatches.values.toList()..shuffle());
  }
}
