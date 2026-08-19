import 'package:flutter/material.dart';
import 'package:personality_detector/presentation/widgets/results/result_card_container.dart';

class MbtiResultCard extends StatelessWidget {
  final String mbtiType;

  const MbtiResultCard({super.key, required this.mbtiType});

  String _getFunctionStack(String mbti) {
    const stacks = {
      'INTJ': 'Ni-Te-Fi-Se',
      'INTP': 'Ti-Ne-Si-Fe',
      'ENTJ': 'Te-Ni-Se-Fi',
      'ENTP': 'Ne-Ti-Fe-Si',
      'INFJ': 'Ni-Fe-Ti-Se',
      'INFP': 'Fi-Ne-Si-Te',
      'ENFJ': 'Fe-Ni-Se-Ti',
      'ENFP': 'Ne-Fi-Te-Si',
      'ISTJ': 'Si-Te-Fi-Ne',
      'ISFJ': 'Si-Fe-Ti-Ne',
      'ESTJ': 'Te-Si-Ne-Fi',
      'ESFJ': 'Fe-Si-Ne-Ti',
      'ISTP': 'Ti-Se-Ni-Fe',
      'ISFP': 'Fi-Se-Ni-Te',
      'ESTP': 'Se-Ti-Fe-Ni',
      'ESFP': 'Se-Fi-Te-Ni',
    };
    return stacks[mbti.toUpperCase()] ?? '';
  }

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mbtiType,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                  letterSpacing: 2,
                ),
              ),
              if (_getFunctionStack(mbtiType).isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _getFunctionStack(mbtiType),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6C63FF).withAlpha(180),
                    letterSpacing: 1.5,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
