import 'package:flutter/material.dart';
import 'package:personality_detector/presentation/widgets/results/result_card_container.dart';

class EnneagramResultCard extends StatelessWidget {
  final String enneagramType;

  const EnneagramResultCard({super.key, required this.enneagramType});

  @override
  Widget build(BuildContext context) {
    return ResultCardContainer(
      icon: Icons.auto_awesome,
      iconColor: Colors.purple,
      title: 'Enneagram Type',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withAlpha(26),
              Colors.deepPurple.withAlpha(26),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _circle(
              color: Colors.purple,
              text: enneagramType.substring(0, 1),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type $enneagramType',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getEnneagramDescription(enneagramType),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle({required Color color, required String text}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getEnneagramDescription(String type) {
    final descriptions = {
      '1': 'The Reformer - Principled, Purposeful, Self-Controlled',
      '2': 'The Helper - Caring, Interpersonal, Generous',
      '3': 'The Achiever - Success-Oriented, Pragmatic, Image-Conscious',
      '4': 'The Individualist - Sensitive, Withdrawn, Expressive',
      '5': 'The Investigator - Intense, Cerebral, Perceptive',
      '6': 'The Loyalist - Committed, Security-Oriented, Anxious',
      '7': 'The Enthusiast - Spontaneous, Versatile, Distractible',
      '8': 'The Challenger - Powerful, Dominating, Self-Confident',
      '9': 'The Peacemaker - Easygoing, Self-Effacing, Reassuring',
    };
    return descriptions[type] ?? 'Unknown Type';
  }
}
