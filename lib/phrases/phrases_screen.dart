import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_language_interpreter/videoplayer.dart';
import 'package:sign_language_interpreter/background_icons.dart';

class PhrasesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const PhrasesScreen({super.key, this.onBack});

  @override
  State<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends State<PhrasesScreen>
    with TickerProviderStateMixin {
  List<dynamic> _phrases = [];
  bool _loading = true;
  String _selectedCategory = 'All';

  late AnimationController _animationController;

  final List<String> categories = [
    'All',
    'Greetings',
    'Courtesy',
    'Basic',
    'Questions',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
    _loadPhrases();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPhrases() async {
    final jsonString = await rootBundle.loadString('assets/quiz_json.json');
    final jsonData = json.decode(jsonString);
    setState(() {
      _phrases = jsonData['phrases'];
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get filteredPhrases {
    if (_selectedCategory == 'All') {
      return List<Map<String, dynamic>>.from(_phrases);
    }
    return _phrases
        .where((phrase) => phrase['category_display'] == _selectedCategory)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          BackgroundIcons(
            icons: [
              BackgroundIconData(
                icon: Icons.front_hand,
                size: 120,
                angle: 0.2,
                left: -30,
                top: 120,
                color: Colors.deepPurple.withOpacity(0.07),
              ),
            ],
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed:
                      widget.onBack ?? () => Navigator.of(context).maybePop(),
                ),
                expandedHeight:
                    size.height >= 800
                        ? size.height * 0.18
                        : size.height * 0.12,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Phrases',
                    style: TextStyle(color: Colors.white),
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
                            left: -30,
                            top: 20,
                            color: Colors.white.withOpacity(0.09),
                          ),
                          BackgroundIconData(
                            icon: Icons.pan_tool_alt_rounded,
                            size: 100,
                            angle: -0.4,
                            right: -20,
                            top: 60,
                            color: Colors.white.withOpacity(0.07),
                          ),
                          BackgroundIconData(
                            icon: Icons.back_hand,
                            size: 60,
                            angle: 0.2,
                            right: -360,
                            bottom: -10,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ],
                      ),
                      Container(color: Colors.black.withOpacity(0.04)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          categories.map((cat) {
                            final selected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: selected,
                                selectedColor: const Color(0xFF7E22CE),
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color:
                                      selected
                                          ? Colors.white
                                          : const Color(0xFF7E22CE),
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedCategory = cat);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color:
                                        selected
                                            ? const Color(0xFF7E22CE)
                                            : Colors.grey[300]!,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final phrase = filteredPhrases[index];
                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(
                          phrase['english']!,
                          style: TextStyle(
                            fontSize: size.width / 25,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7E22CE),
                          ),
                        ),
                        subtitle: Text(
                          phrase['arabic']!,
                          style: TextStyle(
                            fontSize: size.width / 30,
                            color: const Color(0xFF5B21B6),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.play_circle_fill,
                          color: Color(0xFF7E22CE),
                        ),
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => PhraseVideoPlayer(
                                      title: phrase['english']!,
                                      videoUrl: phrase['video_path']!,
                                    ),
                              ),
                            ),
                      ),
                    );
                  }, childCount: filteredPhrases.length),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
