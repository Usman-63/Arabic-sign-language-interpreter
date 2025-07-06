// screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:sign_language_interpreter/background_icons.dart';

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
  String? _selectedAnswer;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the sign for the letter "\u0627" (Alif)?',
      'options': ['Option A', 'Option B', 'Option C', 'Option D'],
      'correct': 0,
    },
    {
      'question': 'Which number sign represents "5"?',
      'options': ['Option A', 'Option B', 'Option C', 'Option D'],
      'correct': 2,
    },
    {
      'question': 'What does this sign mean: "\u0645\u0631\u062d\u0628\u0627"?',
      'options': ['Goodbye', 'Hello', 'Thank you', 'Please'],
      'correct': 1,
    },
    {
      'question': 'The letter "\u0646" (Noon) is signed by:',
      'options': ['Option A', 'Option B', 'Option C', 'Option D'],
      'correct': 3,
    },
    {
      'question': 'What is the Arabic sign for "Thank You"?',
      'options': [
        '\u0645\u0631\u062d\u0628\u0627',
        '\u0634\u0643\u0631\u0627\u064b',
        '\u0639\u0632\u0631\u0627\u064b',
        '\u0645\u0646 \u0641\u0636\u0644\u0643',
      ],
      'correct': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _showResult = false;
      _selectedAnswer = null;
    });
    _animationController.forward();
  }

  void _selectAnswer(String answer, int index) {
    setState(() {
      _selectedAnswer = answer;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (index == _questions[_currentQuestionIndex]['correct']) {
        setState(() {
          _score++;
        });
      }
      if (_currentQuestionIndex < _questions.length - 1) {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Decorative icons config (same for appbar and body)
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
          // Decorative icons behind everything
          BackgroundIcons(icons: decorativeIcons),
          // Main content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed:
                      widget.onBack ?? () => Navigator.of(context).maybePop(),
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
                      fontSize: size.width / 15, // Responsive font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF5B21B6), Color(0xFF7E22CE)],
                          ),
                        ),
                      ),
                      // Decorative icons for the app bar
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
                            size: 100,
                            angle: -0.5,
                            left: -10,
                            top: 60,
                            color: Colors.white.withOpacity(0.07),
                          ),
                          BackgroundIconData(
                            icon: Icons.back_hand,
                            size: 60,
                            angle: 0.2,
                            right: -300,
                            bottom: -20,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ],
                      ),
                      // Optional: subtle overlay for depth
                      Container(color: Colors.black.withOpacity(0.04)),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child:
                        _showResult
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: const Color(0xFF7E22CE),
                                  size: 60,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Quiz Complete!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7E22CE),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Your Score:  a0$_score / ${_questions.length}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF5B21B6),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _startQuiz,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7E22CE),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Restart'),
                                ),
                              ],
                            )
                            : !_quizStarted
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Test your knowledge of Arabic Sign Language!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7E22CE),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: _startQuiz,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7E22CE),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Start Quiz'),
                                ),
                              ],
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF7E22CE),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _questions[_currentQuestionIndex]['question'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5B21B6),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ...List.generate(
                                  _questions[_currentQuestionIndex]['options']
                                      .length,
                                  (i) {
                                    final option =
                                        _questions[_currentQuestionIndex]['options'][i];
                                    final isSelected =
                                        _selectedAnswer == option;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              isSelected
                                                  ? const Color(0xFF5B21B6)
                                                  : const Color(0xFF7E22CE),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed:
                                            _selectedAnswer == null
                                                ? () => _selectAnswer(option, i)
                                                : null,
                                        child: Text(
                                          option,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
