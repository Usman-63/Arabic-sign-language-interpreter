import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sign_language_interpreter/alphabets/alphabets.dart';
import 'package:sign_language_interpreter/background_icons.dart';

class AlphabetScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const AlphabetScreen({super.key, this.onBack});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;

  List<Map<String, dynamic>> _jsonAlphabets = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
    _loadJson();
  }

  Future<void> _loadJson() async {
    final String jsonString = await rootBundle.loadString(
      'assets/quiz_json.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _jsonAlphabets = List<Map<String, dynamic>>.from(jsonData['alphabets']);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredLetters {
    return _jsonAlphabets.where((letter) {
      final matchesSearch =
          letter['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          letter['char'].toString().contains(_searchQuery);
      return matchesSearch;
    }).toList();
  }

  void _showDemoImage(BuildContext context, String id) {
    final images = signAlphabetDemoImages[id];
    if (images == null || images.isEmpty) return;

    int selectedIndex = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              images[selectedIndex],
                              fit: BoxFit.contain,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: List.generate(images.length, (index) {
                              return GestureDetector(
                                onTap:
                                    () => setState(() {
                                      selectedIndex = index;
                                    }),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      images[index],
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Dataset Attribution"),
                                    content: const Text(
                                      "Images are used from:\n\n"
                                      "• ArASL Dataset by Ganna Yasser\n"
                                      "• RGB ArSL Dataset by Muhammad Albrham\n\n"
                                      "Sourced via Kaggle for educational and demo use.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double letterFontSize = size.width / 10;
    final double nameFontSize = size.width / 44;

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
                        ? size.height * 0.18
                        : size.height * 0.12,
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
                      // AppBar-specific icons
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
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showDemoImage(context, letter['id']),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Center(
                                child: Text(
                                  letter['char'],
                                  style: TextStyle(
                                    color: const Color(0xFF7E22CE),
                                    fontSize: letterFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Center(
                                child: Text(
                                  letter['name'],
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
