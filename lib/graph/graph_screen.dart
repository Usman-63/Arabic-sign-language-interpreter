import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpiderGraphWeakestAreas extends StatefulWidget {
  const SpiderGraphWeakestAreas({super.key});

  @override
  State<SpiderGraphWeakestAreas> createState() =>
      _SpiderGraphWeakestAreasState();
}

class _SpiderGraphWeakestAreasState extends State<SpiderGraphWeakestAreas> {
  List<String> labels = [];
  List<double> values = [];

  @override
  void initState() {
    super.initState();
    _loadWeakest();
  }

  Future<void> _loadWeakest() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('quiz_scores');
    if (raw == null) return;

    final Map<String, dynamic> data = jsonDecode(raw);
    final sorted =
        data.entries.toList()
          ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    final top5 = sorted.take(5).toList();

    setState(() {
      labels = top5.map((e) => e.key).toList();
      values = top5.map((e) => (e.value as num).toDouble()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = labels.isNotEmpty && values.isNotEmpty;
    final displayLabels = hasData ? labels : ['-', '-', '-', '-', '-'];
    final displayValues =
        hasData
            ? values.map((v) => v.clamp(1, 5).toInt()).toList()
            : [0, 0, 0, 0, 0];

    return Card(
      elevation: 4,
      color: const Color(0xFFF5F3FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.trending_down, color: Color(0xFF7E22CE)),
                SizedBox(width: 8),
                Text(
                  'Your Weakest Areas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B21B6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Focus on these to improve your skills!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.deepPurple.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: SizedBox(
                height: 200,
                child: RadarChart(
                  features: displayLabels,
                  data: [displayValues],
                  ticks: const [1, 2, 3, 4, 5],
                  featuresTextStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5B21B6),
                  ),
                  outlineColor: const Color(0xFF7E22CE),
                  graphColors: const [Color(0xFF7E22CE)],
                  axisColor: Color(0xFF7E22CE).withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
