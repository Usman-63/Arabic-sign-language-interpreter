import 'package:flutter/material.dart';
import 'package:sign_language_interpreter/background_icons.dart'; // <-- Add this import

class PhrasesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  PhrasesScreen({super.key, this.onBack});

  @override
  State<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends State<PhrasesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedCategory = 'All';

  final List<Map<String, String>> phrases = const [
    {
      'english': 'Salam',
      'arabic':
          '\u0627\u0644\u0633\u0644\u0627\u0645 \u0639\u0644\u064a\u0643\u0645', // السلام عليكم
      'category': 'Greetings',
    },
    {
      'english': 'I Am Sorry',
      'arabic': '\u0623\u0646\u0627 \u0622\u0633\u0641', // أنا آسف
      'category': 'Courtesy',
    },
    {
      'english': 'Good Evening',
      'arabic': '\u0645\u0633\u0627\u0621 \u0627\u0644\u062e\u064a\u0631',
      'category': 'Greetings',
    },
    {
      'english': 'Thank You',
      'arabic': '\u0634\u0643\u0631\u0627\u064b',
      'category': 'Courtesy',
    },
    {
      'english': 'Please',
      'arabic': '\u0645\u0646 \u0641\u0636\u0644\u0643',
      'category': 'Courtesy',
    },
    {
      'english': 'I Am Fine',
      'arabic': '\u0623\u0646\u0627 \u0628\u062e\u064a\u0631', // أنا بخير
      'category': 'Emotions',
    },
    {
      'english': 'Alhamdulillah',
      'arabic':
          '\u0627\u0644\u062d\u0645\u062f \u0644\u0644\u0647', // الحمد لله
      'category': 'Emotions',
    },
    {
      'english': 'What?',
      'arabic': '\u0645\u0627\u0632\u0627\u061f',
      'category': 'Questions',
    }, // ماذا؟
    {
      'english': 'Come Here',
      'arabic':
          '\u062a\u0639\u0627\u0644 \u0625\u0644\u0649 \u0647\u0646\u0627', // تعال إلى هنا
      'category': 'Basic',
    },
    {
      'english': 'How are you?',
      'arabic': '\u0643\u064a\u0641 \u062d\u0627\u0644\u0643\u061f',
      'category': 'Questions',
    },
  ];

  final List<String> categories = [
    'All',
    'Greetings',
    'Courtesy',
    'Emotions',
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredPhrases {
    if (_selectedCategory == 'All') {
      return phrases;
    }
    return phrases
        .where((phrase) => phrase['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double letterFontSize = size.width / 25;
    final double nameFontSize = size.width / 30;
    return Scaffold(
      body: Stack(
        children: [
          // Decorative icons behind everything
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
                    size.height >= 800
                        ? size.height * 0.25
                          : size.height * 0.35,
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
                      // Optional: subtle overlay for depth
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
                            fontSize:
                                letterFontSize, // Use dynamic font size for English
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7E22CE),
                          ),
                        ),
                        subtitle: Text(
                          phrase['arabic']!,
                          style: TextStyle(
                            fontSize:
                                nameFontSize, // Use dynamic font size for Arabic
                            color: const Color(0xFF5B21B6),
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
