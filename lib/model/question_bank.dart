import 'question.dart';

class QuestionBank {
  static List<Question> getQuestions() {
    return [
      MultipleChoiceQuestion(
          'What tajweed rule is applied in the ayah below?',
          ['Idhaar', 'Iqlaab', 'Ikhfaa', "Ghunna", "Idgham"],
          4, // Correct index
          "لَا يَسْمَعُونَ فِيهَا لَغْوًۭا وَلَا تَأْثِيمًا"),
      SelectAllQuestion(
        'Select the Heavy Letters below. (Scroll to see all letters)',
        ['ص', 'ق', 'ب', 'ت', 'د', 'ز', 'غ', 'خ', 'ك', 'ط', 'ل', 'ي'],
        [0, 1, 6, 7, 9],
      ),
      MultipleChoiceQuestion(
        'What Tajweed rule is applied when Meem Saakinah is followed by another Meem, as in the words أَمْ مَنْ?',
          ['Ikhfaa Shafawi', 'Idgham Shafawi', 'Idhaar Shafawi', 'Qalqala'],
          1,
          ""
          ),
      SelectFromSingleAudioQuestion(
        'Identify the Tajweed rules in this audio snippet.',
        'assets/Safaat_19_Hussary.mp3', // LOAD IN HERE AND ADD TO PUBSPEC, THEN CLEAN/PUB GET
        ['Idgham', 'Ikhfaa', 'Qalqala', 'Ghunna'],
        [0, 1, 3], // Multiple correct answers: Idgham, Ikhfaa, Ghunna
      ),
       MultipleChoiceQuestion(
          'What is the ruling for the letter Ra (ر) in the word رِزْقًا ?',
          ['Tafkheem', 'Tarqeeq', 'Ghunna', 'Ikhfaa'],
          1,
          ""),
      MatchingQuestion('Match the Madd (extension) to its accceptable length.',
          {"Laazim": 6, "Tabee'ee (natural madd)": 2, "Muttasil": 4}),
      SelectAllQuestion(
        'Select all Letters of Idhaar. (Scroll to see all letters)',
        [
          'ق',
          'غ',
          'خ',
          'ح',
          'ل',
          'ز',
          'ع',
          'ه',
          'ف',
          'ن',
          'ء',
          'د',
          'ص'
        ],
        [1, 2, 3, 7, 8, 11], // Correct indices for throat letters
      ),
      MatchingQuestion('Match the following rules to their examples', {
        "Ikhfaa": "مِن شَرٍّ",
        "Idgham": "مَنْ يَعْمَلُ",
        "Qalqalah	": "قَدْ أَفْلَحَ",
        "Ghunna": "إِنَّا"
      }),
      MultipleChoiceQuestion(
        'Which word in the following verse contains Iqlaab?',
        ['إِنَّ', 'مِن', 'ٱلنَّخِيلَ', 'يُنۢبِتُ'],
        3, // Correct index
        "يُنۢبِتُ لَكُم بِهِ ٱلزَّرْعَ وَٱلزَّيْتُونَ وَٱلنَّخِيلَ وَٱلْأَعْنَـٰبَ وَمِن كُلِّ ٱلثَّمَرَٰتِ ۗ إِنَّ فِى ذَٰلِكَ لَـَٔايَةًۭ لِّقَوْمٍۢ يَتَفَكَّرُونَ",
      ),
      SelectFromSingleAudioQuestion(
        'Identify the Tajweed rules in this audio snippet.',
        'assets/Hussary_Dukhaan_13.mp3', // LOAD IN HERE AND ADD TO PUBSPEC, THEN CLEAN/PUB GET
        ['Idgham', 'Ikhfaa', 'Qalqala', 'Ghunna'],
        [0, 3], // Multiple correct answers: Qalqala and Ghunna
      ),
       MultipleChoiceQuestion(
        'What Tajweed rule is applied in the phrase: مَنْ يَعْمَلُ',
        ['Ikhfaa', 'Idgham without Ghunna', "Idgham with Ghunna", "Qalqala"],
        2, // Correct index
      "",
      ),
      // SelectCorrectAudioQuestion(
      //     "Select the correct pronounciation of the ayah:",
      //     [
      //       'assets/Hussary_Dukhan_13.mp3',
      //       'assets/Hussary_Dukhan_13.mp3', // add audio to pubspec, assets...
      //       'assets/Hussary_Dukhan_13.mp3',
      //       'assets/Hussary_Dukhan_13.mp3',
      //     ],
      //     1, // correct option
      //     "Arabic Text"),
    ];
  }
}
