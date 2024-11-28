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

  MultipleChoiceQuestion(String text, this.options, this.correctIndex, this.verse)
      : super(text, QuestionType.multipleChoice);
}

// Select All That Apply Question
class SelectAllQuestion extends Question {
  final List<String> options;
  final List<int> correctIndexes; // Multiple correct answers

  SelectAllQuestion(String text, this.options, this.correctIndexes)
      : super(text, QuestionType.selectAll);
}

// select correct audio question based on ayah
class AudioQuestion extends Question {
  final String audioUrl;
  final List<String> options;
  final List<int> correctIndexes; // Multiple correct answers for Select All

  AudioQuestion(String text, this.audioUrl, this.options, this.correctIndexes)
      : super(text, QuestionType.selectAll);
}


// Matching Question
class MatchingQuestion extends Question {
  final List<String> items;
  final Map<int, int> correctMatches; // Key-value pairs for matching

  MatchingQuestion(String text, this.items, this.correctMatches)
      : super(text, QuestionType.matching);
}
