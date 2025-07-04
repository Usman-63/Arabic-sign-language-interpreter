import 'package:flutter/material.dart';
import 'package:sign_language_interpreter/background_icons.dart'; // Add this import
import 'package:sign_language_interpreter/home/app_bar_header.dart';
import 'package:sign_language_interpreter/home/feature_card.dart';
import 'package:sign_language_interpreter/home/graph_screen.dart';
import '../alphabets/alphabet_screen.dart';
import '../phrases/phrases_screen.dart';
import '../Quizzes/quiz_screen.dart';
import '../recognition_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(onNavigate: _onNavigate),
      AlphabetScreen(onBack: () => _onNavigate(0)), // Pass onBack
      PhrasesScreen(onBack: () => _onNavigate(0)),
      QuizScreen(onBack: () => _onNavigate(0)),
      RecognitionScreen(onBack: () => _onNavigate(0)),
    ];
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
            ),
            child: child,
          );
        },
        child: pages[_selectedIndex],
      ),
    );
  }
}

// Home Content Widget
class HomeContent extends StatefulWidget {
  final void Function(int) onNavigate;
  const HomeContent({super.key, required this.onNavigate});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  double _scrollOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      body: Stack(
        children: [
          // Decorative icons behind everything using BackgroundIcons
          BackgroundIcons(
            icons: [
              BackgroundIconData(
                icon: Icons.front_hand,
                size: 180,
                angle: -0.3,
                right: -100,
                top: 180,
                color: Colors.deepPurpleAccent.withOpacity(0.25),
              ),
              BackgroundIconData(
                icon: Icons.pan_tool_alt_rounded,
                size: 120,
                angle: 0.5,
                left: 30,
                top: -10,
                color: Colors.deepPurple.withOpacity(0.25),
              ),
              BackgroundIconData(
                icon: Icons.pan_tool_alt_rounded,
                size: 140,
                angle: 0.2,
                left: 110,
                bottom: 80,
                color: Colors.deepPurpleAccent.withOpacity(0.25),
              ),
            ],
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.axis == Axis.vertical) {
                setState(() {
                  _scrollOffset = scrollNotification.metrics.pixels;
                });
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight:
                      size.height >= 800
                          ? size.height * 0.25
                          : size.height *
                              0.29, // Increased for better collapse effect
                  floating: false,
                  pinned: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient background
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF5B21B6),
                                Color(0xFF7E22CE),
                                Color(0xFF9333EA),
                              ],
                            ),
                          ),
                        ),
                        // Decorative overlay (optional, can use an SVG or asset here)
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Icon(
                            Icons.pan_tool_alt_rounded,
                            size: 120,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                        Positioned(
                          right: -70,
                          bottom: -20,
                          child: Icon(
                            Icons.pan_tool_alt_rounded,
                            size: 120,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                        Positioned(
                          left: -70,
                          top: 50,
                          child: Icon(
                            Icons.pan_tool_alt_rounded,
                            size: 120,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                        // Semi-transparent overlay for depth
                        Container(color: Colors.black.withOpacity(0.08)),
                        // Content
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 36, 24, 16),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      'Learn Arabic Signs',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            height: 1.1,
                                            letterSpacing: 1.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(
                                                  0.18,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Interactive guide to master Arabic Sign Language\nwith practice, real-time recognition and quizzes.',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: Colors.white.withOpacity(
                                              0.96,
                                            ),
                                            height: 1.4,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(
                                                  0.10,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                    ),
                                    const Spacer(),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPersistentHeader(
                  floating: false,
                  pinned: true,
                  delegate: StartLearningHeaderDelegate(
                    onPressed: () => widget.onNavigate(1),
                    minExtentHeight: 60,
                    maxExtentHeight: 100,
                  ),
                ),

                // Feature Cards
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      childAspectRatio: 1.08,
                    ),
                    delegate: SliverChildListDelegate([
                      buildFeatureCard(
                        icon: Icons.abc,
                        title: 'Alphabet',
                        subtitle: '28 Arabic Letters',
                        color: const Color(0xFF7E22CE),
                        onTap: () => widget.onNavigate(1),
                      ),
                      buildFeatureCard(
                        icon: Icons.chat_bubble,
                        title: 'Phrases',
                        subtitle: 'Common Expressions',
                        color: const Color(0xFF7E22CE),
                        onTap: () => widget.onNavigate(2),
                      ),
                      buildFeatureCard(
                        icon: Icons.quiz,
                        title: 'Practice Quiz',
                        subtitle: 'Test Your Skills',
                        color: const Color(0xFF7E22CE),
                        onTap: () => widget.onNavigate(3),
                      ),
                      buildFeatureCard(
                        icon: Icons.camera_alt,
                        title: 'Recognition',
                        subtitle: 'Real-time Camera',
                        color: const Color(0xFF5B21B6),
                        onTap: () => widget.onNavigate(4),
                      ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 60,
                        color: Colors.deepPurple.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),

                // Spider Graph with animated opacity
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity:
                        (_scrollOffset > 100)
                            ? ((_scrollOffset - 100) / 120).clamp(0.0, 1.0)
                            : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: spidergraph,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
