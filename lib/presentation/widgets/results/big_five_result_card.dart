import 'package:flutter/material.dart';
import 'package:personality_detector/presentation/widgets/results/result_card_container.dart';

class BigFiveResultCard extends StatelessWidget {
  final Map<String, double> big5Percentages;

  const BigFiveResultCard({super.key, required this.big5Percentages});

  @override
  Widget build(BuildContext context) {
    return ResultCardContainer(
      icon: Icons.analytics,
      iconColor: Colors.orange,
      title: 'Big Five Traits',
      child: Column(
        children: big5Percentages.entries.map((entry) {
          final value = entry.value;
          return _buildTraitBar(
            label: entry.key,
            value: value,
            color: _getTraitColor(entry.key),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTraitBar({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withAlpha(204), color]),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Color _getTraitColor(String trait) {
    const colors = {
      'Openness': Colors.blue,
      'Conscientiousness': Colors.green,
      'Extroversion': Colors.orange,
      'Agreeableness': Colors.pink,
      'Neuroticism': Colors.purple,
    };
    return colors[trait] ?? Colors.grey;
  }
}
