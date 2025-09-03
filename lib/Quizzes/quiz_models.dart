class AlphabetData {
  final String id;
  final String char;
  final String name;
  final String imageAsset;

  AlphabetData({
    required this.id,
    required this.char,
    required this.name,
    required this.imageAsset,
  });

  factory AlphabetData.fromJson(Map<String, dynamic> json) {
    return AlphabetData(
      id: json['id']?.toString() ?? '',
      char: json['char']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageAsset: json['image_path']?.toString() ?? '',
    );
  }
}

class PhraseData {
  final String id;
  final String english;
  final String arabic;
  final String category;
  final String videoAsset;

  PhraseData({
    required this.id,
    required this.english,
    required this.arabic,
    required this.category,
    required this.videoAsset,
  });

  factory PhraseData.fromJson(Map<String, dynamic> json) {
    return PhraseData(
      id: json['id']?.toString() ?? '',
      english: json['english']?.toString() ?? '',
      arabic: json['arabic']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      videoAsset: json['video_path']?.toString() ?? '',
    );
  }
}

class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final bool hasMedia;
  final String? displayText;
  final String? mediaAsset;
  final QuestionType type;
  final List<String>? mediaOptions;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    this.hasMedia = false,
    this.displayText,
    this.mediaAsset,
    required this.type,
    this.mediaOptions,
  });

  factory QuizQuestion.alphabet({
    required Map<String, dynamic> template,
    required AlphabetData correctAlphabet,
    required List<AlphabetData> wrongOptions,
  }) {
    final allOptions = [correctAlphabet, ...wrongOptions];
    allOptions.shuffle();
    final correctIndex = allOptions.indexOf(correctAlphabet);
    final templateId = template['id'] as String;

    final isSignToLetter = templateId == 'sign_to_letter';

    return QuizQuestion(
      id: correctAlphabet.id,
      type: QuestionType.alphabet,
      questionText: template['question_text'] as String,
      options:
          isSignToLetter
              ? allOptions.map((e) => e.char).toList()
              : List.filled(allOptions.length, ''),
      mediaOptions:
          isSignToLetter ? null : allOptions.map((e) => e.imageAsset).toList(),
      correctIndex: correctIndex,
      hasMedia: true,
      displayText: isSignToLetter ? null : correctAlphabet.char,
      mediaAsset: isSignToLetter ? correctAlphabet.imageAsset : null,
    );
  }

  factory QuizQuestion.phrase({
    required Map<String, dynamic> template,
    required PhraseData correctPhrase,
    required List<PhraseData> wrongOptions,
  }) {
    final allOptions = [correctPhrase, ...wrongOptions];
    allOptions.shuffle();
    final correctIndex = allOptions.indexOf(correctPhrase);
    final templateId = template['id'] as String;

    List<String> optionTexts;
    String? displayText;
    String? mediaAsset;
    bool hasMedia = false;

    switch (templateId) {
      case 'sign_to_english':
        optionTexts = allOptions.map((e) => e.english).toList();
        hasMedia = true;
        mediaAsset = correctPhrase.videoAsset;
        break;
      case 'arabic_to_english':
        optionTexts = allOptions.map((e) => e.english).toList();
        displayText = correctPhrase.arabic;
        break;
      case 'english_to_arabic':
        optionTexts = allOptions.map((e) => e.arabic).toList();
        displayText = correctPhrase.english;
        break;
      case 'category_identification':
        optionTexts = allOptions.map((e) => e.category).toList();
        displayText = correctPhrase.english;
        break;
      default:
        optionTexts = allOptions.map((e) => e.english).toList();
        displayText = correctPhrase.english;
    }

    return QuizQuestion(
      id: correctPhrase.id,
      type: QuestionType.phrase,
      questionText: template['question_text'] as String,
      options: optionTexts,
      correctIndex: correctIndex,
      hasMedia: hasMedia,
      displayText: displayText,
      mediaAsset: mediaAsset,
    );
  }
}

enum QuestionType { alphabet, phrase }
