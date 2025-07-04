import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

final Widget spidergraph = Card(
  elevation: 4,
  color: const Color(0xFFF5F3FF),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_down, color: Color(0xFF7E22CE)),
            const SizedBox(width: 8),
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
              features: const ["Alif", "Ba", "Ta", "tha", "jeem"],
              data: const [
                [1, 3, 5, 2, 4], // Dummy user scores
              ],
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
