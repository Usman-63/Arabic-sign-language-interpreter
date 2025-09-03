import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sign_language_interpreter/background_icons.dart';
import 'package:sign_language_interpreter/videoplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_models.dart';
import 'dart:convert';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const QuizScreen({super.key, this.onBack});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showResult = false;
  bool _quizStarted = false;
  bool _isLoading = true;
  String? _selectedAnswer;
  List<QuizQuestion> _currentQuestions = [];

  // JSON data containers
  Map<String, dynamic> _quizData = {};
  List<AlphabetData> _alphabets = [];
  List<PhraseData> _phrases = [];
  Map<String, dynamic> _questionTemplates = {};
  Map<String, dynamic> _quizSettings = {};
  Map<String, dynamic> _scoringData = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadQuizData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadQuizData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/quiz_json.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      setState(() {
        _quizData = jsonData;
        _alphabets =
            (jsonData['alphabets'] as List)
                .map((item) => AlphabetData.fromJson(item))
                .toList();
        _phrases =
            (jsonData['phrases'] as List)
                .map((item) => PhraseData.fromJson(item))
                .toList();
        _questionTemplates = jsonData['question_templates'];
        _quizSettings = jsonData['quiz_settings'];
        _scoringData = jsonData['scoring'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading quiz data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get _totalQuestions => _quizSettings['default_total_questions'] ?? 10;
  double get _alphabetRatio => _quizSettings['alphabet_question_ratio'] ?? 0.6;
  int get _answerDelay => _quizSettings['answer_delay_ms'] ?? 800;

  // Generate dynamic questions using JSON data
  List<QuizQuestion> _generateQuestions() {
    final List<QuizQuestion> questions = [];
    final Random random = Random();

    final int alphabetQuestions = (_totalQuestions * _alphabetRatio).round();
    final int phraseQuestions = _totalQuestions - alphabetQuestions;

    // Generate alphabet questions
    for (int i = 0; i < alphabetQuestions; i++) {
      questions.add(_generateAlphabetQuestion(random));
    }

    // Generate phrase questions
    for (int i = 0; i < phraseQuestions; i++) {
      questions.add(_generatePhraseQuestion(random));
    }

    return questions..shuffle();
  }

  QuizQuestion _generateAlphabetQuestion(Random random) {
    final alphabetTemplates = _questionTemplates['alphabet'];
    final templateKeys = alphabetTemplates.keys.toList();
    final templateKey = templateKeys[random.nextInt(templateKeys.length)];
    final template = alphabetTemplates[templateKey];

    final correctAlphabet = _alphabets[random.nextInt(_alphabets.length)];

    // Generate wrong options
    final wrongOptions = <AlphabetData>[];
    while (wrongOptions.length < 3) {
      final wrongOption = _alphabets[random.nextInt(_alphabets.length)];
      if (wrongOption.id != correctAlphabet.id &&
          !wrongOptions.any((option) => option.id == wrongOption.id)) {
        wrongOptions.add(wrongOption);
      }
    }

    return QuizQuestion.alphabet(
      template: template,
      correctAlphabet: correctAlphabet,
      wrongOptions: wrongOptions,
    );
  }

  QuizQuestion _generatePhraseQuestion(Random random) {
    final phraseTemplates = _questionTemplates['phrase'];
    final templateKeys = phraseTemplates.keys.toList();
    final templateKey = templateKeys[random.nextInt(templateKeys.length)];
    final template = phraseTemplates[templateKey];

    final correctPhrase = _phrases[random.nextInt(_phrases.length)];

    // Generate wrong options
    final wrongOptions = <PhraseData>[];
    while (wrongOptions.length < 3) {
      final wrongOption = _phrases[random.nextInt(_phrases.length)];
      if (wrongOption.id != correctPhrase.id &&
          !wrongOptions.any((option) => option.id == wrongOption.id)) {
        wrongOptions.add(wrongOption);
      }
    }

    return QuizQuestion.phrase(
      template: template,
      correctPhrase: correctPhrase,
      wrongOptions: wrongOptions,
    );
  }

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _showResult = false;
      _selectedAnswer = null;
      _currentQuestions = _generateQuestions();
    });
    _animationController.forward();
  }

  Future<void> _recordMistake(String id, bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('quiz_scores');
    final Map<String, dynamic> scores =
        raw != null ? Map<String, dynamic>.from(jsonDecode(raw)) : {};

    // Mistakes = high value; Correct = subtract
    if (!scores.containsKey(id)) scores[id] = 0.0;

    if (!isCorrect) {
      scores[id] = (scores[id] as num).toDouble() + 1;
    } else {
      scores[id] = (scores[id] as num).toDouble() - 0.2;
      if (scores[id] < 0) scores[id] = 0;
    }

    await prefs.setString('quiz_scores', jsonEncode(scores));
  }

  void _selectAnswer(String answer, int index) {
    if (_selectedAnswer != null) return;
    setState(() {
      _selectedAnswer = answer;
    });
    final current = _currentQuestions[_currentQuestionIndex];
    final isCorrect = index == current.correctIndex;
    final id = _currentQuestions[_currentQuestionIndex].id;
    _recordMistake(id, isCorrect);
    Future.delayed(Duration(milliseconds: _answerDelay), () {
      if (index == _currentQuestions[_currentQuestionIndex].correctIndex) {
        setState(() {
          _score++;
        });
      }

      if (_currentQuestionIndex < _currentQuestions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
        });
      } else {
        setState(() {
          _showResult = true;
        });
      }
    });
  }

  Map<String, dynamic> _getScoreData() {
    final percentage = (_score / _totalQuestions * 100).round();

    if (percentage >= (_scoringData['excellent']['min_percentage'] ?? 85)) {
      return _scoringData['excellent'];
    } else if (percentage >= (_scoringData['good']['min_percentage'] ?? 60)) {
      return _scoringData['good'];
    } else {
      return _scoringData['needs_improvement'];
    }
  }

  Color _getScoreColor(String colorName) {
    switch (colorName) {
      case 'amber':
        return Colors.amber;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getScoreIcon(String iconName) {
    switch (iconName) {
      case 'trophy':
        return Icons.emoji_events;
      case 'thumbs_up':
        return Icons.thumb_up;
      case 'school':
        return Icons.school;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7E22CE)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading Quiz Data...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7E22CE),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<BackgroundIconData> decorativeIcons = [
      BackgroundIconData(
        icon: Icons.front_hand,
        size: 120,
        angle: 0.2,
        bottom: -30,
        right: 120,
        color: Colors.deepPurple.withOpacity(0.07),
      ),
      BackgroundIconData(
        icon: Icons.pan_tool_alt_rounded,
        size: 160,
        angle: -0.4,
        left: -100,
        top: 30,
        color: Colors.deepPurpleAccent.withOpacity(0.06),
      ),
      BackgroundIconData(
        icon: Icons.back_hand,
        size: 90,
        angle: 0.7,
        right: 80,
        top: 100,
        color: Colors.deepPurple.withOpacity(0.05),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          BackgroundIcons(icons: decorativeIcons),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed:
                      widget.onBack ?? () => {Navigator.of(context).maybePop()},
                ),
                expandedHeight:
                    size.height >= 800 ? size.height * 0.15 : size.height * 0.1,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width / 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF5B21B6), Color(0xFF7E22CE)],
                          ),
                        ),
                      ),
                      BackgroundIcons(
                        icons: [
                          BackgroundIconData(
                            icon: Icons.front_hand,
                            size: 70,
                            angle: 0.3,
                            right: -30,
                            top: 20,
                            color: Colors.white.withOpacity(0.09),
                          ),
                          BackgroundIconData(
                            icon: Icons.pan_tool_alt_rounded,
                            size: 90,
                            angle: -0.5,
                            left: -40,
                            bottom: 10,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: _buildQuizContent(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    if (_showResult) {
      return _buildResultScreen();
    } else if (_quizStarted) {
      return _buildQuizScreen();
    } else {
      return _buildStartScreen();
    }
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz, size: 80, color: Color(0xFF7E22CE)),
          SizedBox(height: 24),
          Text(
            'Sign Language Quiz',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7E22CE),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Test your knowledge of Arabic Sign Language',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Quiz Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7E22CE),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Questions:', style: TextStyle(fontSize: 16)),
                    Text(
                      '$_totalQuestions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Passing Score:', style: TextStyle(fontSize: 16)),
                    Text(
                      '${_quizSettings['passing_score'] ?? 70}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: _startQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7E22CE),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Start Quiz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizScreen() {
    final question = _currentQuestions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _currentQuestions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_currentQuestions.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Score: $_score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7E22CE),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7E22CE)),
        ),
        SizedBox(height: 32),

        // Question
        Text(
          question.questionText,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7E22CE),
          ),
        ),
        SizedBox(height: 24),

        // Media or display text
        if (question.hasMedia && question.mediaAsset != null)
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child:
                  question.mediaAsset!.endsWith('.mp4')
                      ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PhraseVideoPlayer(
                                    title: question.questionText,
                                    videoUrl: question.mediaAsset!,
                                  ),
                            ),
                          );
                        },
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_fill,
                                size: 60,
                                color: const Color(0xFF7E22CE),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to Play Video',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Image.asset(
                        question.mediaAsset!,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Image not found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ),

        if (question.displayText != null)
          Center(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.displayText!,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7E22CE),
                ),
              ),
            ),
          ),

        SizedBox(height: 32),

        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
          children:
              question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = _selectedAnswer == option;
                final isCorrect = index == question.correctIndex;

                // Default styling
                Color backgroundColor = Colors.white;
                Color borderColor = Colors.grey[300]!;
                Color textColor = Colors.black;
                Color letterBgColor = const Color(0xFF7E22CE);

                // Apply selection styling only if an answer has been selected
                if (_selectedAnswer != null) {
                  if (isSelected) {
                    // Selected answer styling
                    backgroundColor =
                        isCorrect ? Colors.green[100]! : Colors.red[100]!;
                    borderColor = isCorrect ? Colors.green : Colors.red;
                    textColor =
                        isCorrect ? Colors.green[800]! : Colors.red[800]!;
                    letterBgColor = textColor;
                  } else if (isCorrect) {
                    // Correct answer styling (when another option was selected)
                    backgroundColor = Colors.green[100]!;
                    borderColor = Colors.green;
                    textColor = Colors.green[800]!;
                    letterBgColor = textColor;
                  }
                }

                return InkWell(
                  onTap:
                      _selectedAnswer == null
                          ? () => _selectAnswer(option, index)
                          : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Image or Text content
                        Center(
                          child:
                              question.mediaOptions != null &&
                                      question.mediaOptions!.length > index
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      question.mediaOptions![index],
                                      fit: BoxFit.fill,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              ),
                                    ),
                                  )
                                  : Text(
                                    option,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                        ),

                        // Letter indicator
                        Positioned(
                          top: 8,
                          left: 8,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: letterBgColor,
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    final scoreData = _getScoreData();
    final percentage = (_score / _totalQuestions * 100).round();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getScoreIcon(scoreData['icon']),
            size: 80,
            color: _getScoreColor(scoreData['color']),
          ),
          SizedBox(height: 24),
          Text(
            'Quiz Complete!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7E22CE),
            ),
          ),
          SizedBox(height: 16),
          Text(
            scoreData['message'],
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7E22CE),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '$_score/$_totalQuestions',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(scoreData['color']),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(scoreData['color']),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _quizStarted = false;
                    _showResult = false;
                    _currentQuestionIndex = 0;
                    _score = 0;
                    _selectedAnswer = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[800],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Back to Start'),
              ),
              ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7E22CE),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
