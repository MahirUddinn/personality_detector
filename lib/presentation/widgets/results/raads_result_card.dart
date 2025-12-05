import 'package:flutter/material.dart';
import 'package:personality_detector/presentation/widgets/results/result_card_container.dart';

class RaadsResultCard extends StatelessWidget {
  final int rawScore;
  final String interpretation;

  const RaadsResultCard({
    super.key,
    required this.rawScore,
    required this.interpretation,
  });

  @override
  Widget build(BuildContext context) {
    return ResultCardContainer(
      icon: Icons.assessment,
      iconColor: Colors.redAccent,
      title: 'RAADS-R Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow(
            label: "Raw Score",
            value: rawScore.toString(),
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Text(
            interpretation,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
