import 'package:flutter/material.dart';
import 'package:personality_detector/presentation/widgets/results/result_card_container.dart';

class MbtiResultCard extends StatelessWidget {
  final String mbtiType;

  const MbtiResultCard({super.key, required this.mbtiType});

  @override
  Widget build(BuildContext context) {
    return ResultCardContainer(
      icon: Icons.category,
      iconColor: const Color(0xFF6C63FF),
      title: 'MBTI Type',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6C63FF).withAlpha(26),
              const Color(0xFF4A44C6).withAlpha(26),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            mbtiType,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C63FF),
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
