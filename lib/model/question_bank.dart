import 'question.dart';

class QuestionBank {
  static List<Question> getQuestions() {
    return [
      // MultipleChoiceQuestion(
      //     'What tajweed rule is applied in the ayah below?',
      //     ['Idhaar', 'Iqlaab', 'Ikhfaa', "Idgham"],
      //     3, // Correct index
      //     "لَا يَسْمَعُونَ فِيهَا لَغْوًۭا وَلَا تَأْثِيمًا"),
      MultipleChoiceQuestion(
          'How many harakat (counts) should the madd in the word يُحَآدُّونَ be held?',
          ['8', '6', '2', "4"],
          1, // Correct index
          "إِنَّ ٱلَّذِينَ يُحَآدُّونَ ٱللَّهَ وَرَسُولَهُۥ كُبِتُوا۟ كَمَا كُبِتَ ٱلَّذِينَ مِن قَبْلِهِمْ ۚ وَقَدْ أَنزَلْنَآ ءَايَـٰتٍۭ بَيِّنَـٰتٍۢ ۚ وَلِلْكَـٰفِرِينَ عَذَابٌۭ مُّهِينٌۭ"),
      // SelectAllQuestion(
      //   'Select the Heavy Letters below. (Scroll to see all letters)',
      //   ['ص', 'ق', 'ب', 'ت', 'د', 'ز', 'غ', 'خ', 'ك', 'ط', 'ل', 'ي'],
      //   [0, 1, 6, 7, 9],
      // ),
      SelectCorrectAudioQuestion(
          "Select the correct pronunciation of the ayah",
          [
            "assets/qawl_dukhan_correct.mp3",
            "assets/qawl_dukhan_incorrect.mp3",
            "assets/qawl_dukhan_incorrect2.mp3"
          ],
          0,
          "أَنَّىٰ لَهُمُ ٱلذِّكْرَىٰ وَقَدْ جَآءَهُمْ رَسُولٌۭ مُّبِينٌۭ"),
      // SelectFromSingleAudioQuestion(
      //   'Identify the Tajweed rules in this audio snippet.',
      //   'assets/Safaat_19_Hussary.mp3', // LOAD IN HERE AND ADD TO PUBSPEC, THEN CLEAN/PUB GET
      //   ['Idgham', 'Ikhfaa', 'Qalqala', 'Ghunna'],
      //   [0, 1, 3], // Multiple correct answers: Idgham, Ikhfaa, Ghunna
      // ),
      MultipleChoiceQuestion(
          'What is the ruling for the letter Ra (ر) in the word رِزْقًا ?',
          ['Tafkheem (Heavy)', 'Tarqeeq (Light)', 'Ghunna', 'Ikhfaa'],
          1,
          ""),
      MatchingQuestion(
          'Match the Madd (extension) and its example to its accceptable length.',
          {
            "Laazim (ٱلطَّآمَّةُ)": 6,
            "Tabee'ee (فَمَاذَا)": 2,
            "Muttasil (ٱلسَّمَآءِ)": 4
          }),
      MultipleChoiceQuestion(
          // FIX
          'Which word in the following verse contains Ghunna?',
          ['غَفَّارًۭا', 'إِنَّهُۥ', 'ٱسْتَغْفِرُوا۟', 'فَقُلْتُ'],
          1, // Correct index
          "فَقُلْتُ ٱسْتَغْفِرُوا۟ رَبَّكُمْ إِنَّهُۥ كَانَ غَفَّارًۭا"),
      // SelectAllQuestion(
      //   'Select all Letters of Idhaar. (Scroll to see all letters)',
      //   [
      //     'ق',
      //     'غ',
      //     'خ',
      //     'ح',
      //     'ل',
      //     'ز',
      //     'ع',
      //     'ه',
      //     'ف',
      //     'ن',
      //     'ء',
      //     'د',
      //     'ص'
      //   ],
      //   [1, 2, 3, 7, 8, 11], // Correct indices for throat letters
      // ),
      MatchingQuestion('Match the following rules to their examples', {
        "Ikhfaa": "مِن شَرٍّ",
        "Idgham": "مَنْ يَعْمَلُ",
        "Qalqalah	": "قَدْ أَفْلَحَ",
        "Ghunna": "إِنَّا"
      }),
      MultipleChoiceQuestion(
          'How many harakat (counts) should the madd in the word أُو۟لَـٰٓئِكَ be held?',
          ['8', '6', '2', "4"],
          3, // Correct index
          "إِنَّ ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ أُو۟لَـٰٓئِكَ هُمْ خَيْرُ ٱلْبَرِيَّةِ"),
      // MultipleChoiceQuestion(
      //   'Which word in the following verse contains Iqlaab?',
      //   ['إِنَّ', 'مِن', 'ٱلنَّخِيلَ', 'يُنۢبِتُ'],
      //   3, // Correct index
      //   "يُنۢبِتُ لَكُم بِهِ ٱلزَّرْعَ وَٱلزَّيْتُونَ وَٱلنَّخِيلَ وَٱلْأَعْنَـٰبَ وَمِن كُلِّ ٱلثَّمَرَٰتِ ۗ إِنَّ فِى ذَٰلِكَ لَـَٔايَةًۭ لِّقَوْمٍۢ يَتَفَكَّرُونَ",
      // ),
      SelectCorrectAudioQuestion(
          "Select the correct pronunciation of the ayah",
          [
            "assets/qawl_yunus_incorrect1.mp3",
            "assets/qawl_yunus_correct.mp3",
            "assets/qawl_yunus_incorrect2.mp3",
          ],
          1,
          "فَكَفَىٰ بِٱللَّهِ شَهِيدًۢا بَيْنَنَا وَبَيْنَكُمْ إِن كُنَّا عَنْ عِبَادَتِكُمْ لَغَـٰفِلِينَ"),
      // SelectFromSingleAudioQuestion(
      //   'Identify the Tajweed rules in this audio snippet.',
      //   'assets/Hussary_Dukhaan_13.mp3', // LOAD IN HERE AND ADD TO PUBSPEC, THEN CLEAN/PUB GET
      //   ['Idhaar', 'Ikhfaa', 'Qalqala', 'Ghunna'],
      //   [2, 3], // Multiple correct answers: Qalqala and Ghunna
      // ),
      MultipleChoiceQuestion(
        'What Tajweed rule is applied in the phrase: مَنْ يَعْمَلُ',
        ['Ikhfaa', 'Idgham without Ghunna', "Idgham with Ghunna", "Qalqala"],
        2, // Correct index
        "",
      ),
      SelectCorrectAudioQuestion(
          "Select the correct pronunciation of the Ayah",
          [
            "assets/qawl_adiyaat_incorrect2v2.mp3",
            "assets/qawl_adiyaat_incorrect3v2.mp3",
            "assets/qawl_adiyaat_incorrect1v2.mp3",
            "assets/qawl_adiyaat_correctv2.mp3"
          ],
          3,
          "إِنَّ رَبَّهُم بِهِمْ يَوْمَئِذٍۢ لَّخَبِيرٌۢ"),
    ];
  }
}
