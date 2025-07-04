import 'package:flutter/material.dart';
import 'package:sign_language_interpreter/background_icons.dart'; // <-- Add this import

class AlphabetScreen extends StatefulWidget {
  final VoidCallback? onBack;
  AlphabetScreen({super.key, this.onBack});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;

  final List<Map<String, String>> letters = const [
    {'char': 'ا', 'name': 'Alif'},
    {'char': 'ب', 'name': 'Ba'},
    {'char': 'ت', 'name': 'Ta'},
    {'char': 'ث', 'name': 'Tha'},
    {'char': 'ج', 'name': 'Jeem'},
    {'char': 'ح', 'name': 'Ha'},
    {'char': 'خ', 'name': 'Kha'},
    {'char': 'د', 'name': 'Dal'},
    {'char': 'ذ', 'name': 'Dhal'},
    {'char': 'ر', 'name': 'Ra'},
    {'char': 'ز', 'name': 'Zay'},
    {'char': 'س', 'name': 'Seen'},
    {'char': 'ش', 'name': 'Sheen'},
    {'char': 'ص', 'name': 'Sad'},
    {'char': 'ض', 'name': 'Dad'},
    {'char': 'ط', 'name': 'Taa'},
    {'char': 'ظ', 'name': 'Zaa'},
    {'char': 'ع', 'name': 'Ayn'},
    {'char': 'غ', 'name': 'Ghayn'},
    {'char': 'ف', 'name': 'Fa'},
    {'char': 'ق', 'name': 'Qaf'},
    {'char': 'ك', 'name': 'Kaf'},
    {'char': 'ل', 'name': 'Lam'},
    {'char': 'م', 'name': 'Meem'},
    {'char': 'ن', 'name': 'Noon'},
    {'char': 'ه', 'name': 'Ha'},
    {'char': 'و', 'name': 'Waw'},
    {'char': 'ي', 'name': 'Ya'},
    {'char': 'ال', 'name': 'Al'},
    {'char': 'ء', 'name': 'Hamza'},
    {'char': 'ة', 'name': 'Taa Marbuuta'},
    {'char': 'أ', 'name': 'Alif Hamza Above'},
    {'char': 'ؤ', 'name': 'Waaw Hamza'},
    {'char': 'ئ', 'name': 'Alif Maqsura Hamza'},
    {'char': 'ئـ', 'name': 'Hamza Line'},
    {'char': 'إ', 'name': 'Alif Hamza Below'},
    {'char': 'آ', 'name': 'Alif Maad'},
    {'char': 'لا', 'name': 'Laam Alif'},
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
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredLetters {
    return letters.where((letter) {
      final matchesSearch =
          letter['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          letter['char']!.contains(_searchQuery);
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double letterFontSize = size.width / 10;
    final double nameFontSize = size.width / 40;

    return Scaffold(
      body: Stack(
        children: [
          // Decorative icons behind everything
          BackgroundIcons(
            icons: [
              BackgroundIconData(
                icon: Icons.front_hand,
                size: 140,
                angle: 0.2,
                right: -500,
                top: 120,
                color: Colors.deepPurple.withOpacity(0.07),
              ),
              BackgroundIconData(
                icon: Icons.pan_tool_alt_rounded,
                size: 180,
                angle: -0.4,
                right: -60,
                top: 300,
                color: Colors.deepPurpleAccent.withOpacity(0.06),
              ),
              BackgroundIconData(
                icon: Icons.back_hand,
                size: 100,
                angle: 0.7,
                left: 60,
                bottom: 80,
                color: Colors.deepPurple.withOpacity(0.05),
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
                    'Alphabet',
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
                            colors: [
                              Color(0xFF5B21B6),
                              Color(0xFF7E22CE),
                              Color(0xFF9333EA),
                            ],
                          ),
                        ),
                      ),
                      // AppBar-specific icons (optional, or remove if you want only global icons)
                      BackgroundIcons(
                        icons: [
                          BackgroundIconData(
                            icon: Icons.front_hand,
                            size: 90,
                            angle: 0.4,
                            left: -60,
                            top: 30,
                            color: Colors.white.withOpacity(0.09),
                          ),
                          BackgroundIconData(
                            icon: Icons.pan_tool_alt_rounded,
                            size: 120,
                            angle: -0.5,
                            right: -40,
                            top: 80,
                            color: Colors.white.withOpacity(0.07),
                          ),
                          BackgroundIconData(
                            icon: Icons.back_hand,
                            size: 70,
                            angle: 0.2,
                            left: 40,
                            bottom: -30,
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
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search letter or name...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF7E22CE),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF7E22CE)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final letter = filteredLetters[index];
                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                letter['char']!,
                                style: TextStyle(
                                  color: const Color(0xFF7E22CE),
                                  fontSize: letterFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                letter['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: nameFontSize,
                                  color: const Color(0xFF7E22CE),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: filteredLetters.length),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
