import 'package:flutter/material.dart';

class QuestionHeader extends StatelessWidget {
  final int questionNumber;
  final int totalQuestions;
  final double progress;

   const QuestionHeader({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $questionNumber of $totalQuestions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
         SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient:  LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
         SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% complete',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
