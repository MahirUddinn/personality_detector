import 'package:flutter/material.dart';
import 'package:personality_detector/domain/models/results.dart';

class ResultsScreen extends StatelessWidget {
  final Results results;

  const ResultsScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMbtiResult(),
                  const SizedBox(height: 20),
                  _buildBig5Result(),
                  const SizedBox(height: 20),
                  _buildEnneagramResult(),
                  const SizedBox(height: 20),
                  _buildRaadsResult(),
                  const SizedBox(height: 20),
                  _buildRaadsSummaryCard(), // NEW
                  const SizedBox(height: 40),
                  _buildShareButton(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration, size: 60, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Results',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Personality Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SECTIONS ----------------

  Widget _buildMbtiResult() {
    return _card(
      icon: Icons.category,
      iconColor: const Color(0xFF6C63FF),
      title: 'MBTI Type',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.1),
              const Color(0xFF4A44C6).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            results.mbtiType,
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

  Widget _buildBig5Result() {
    return _card(
      icon: Icons.analytics,
      iconColor: Colors.orange,
      title: 'Big Five Traits',
      child: Column(
        children: results.big5Percentages.entries.map((entry) {
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

  Widget _buildEnneagramResult() {
    return _card(
      icon: Icons.auto_awesome,
      iconColor: Colors.purple,
      title: 'Enneagram Type',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.1),
              Colors.deepPurple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _circle(
              color: Colors.purple,
              text: results.enneagramType.substring(0, 1),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type ${results.enneagramType}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getEnneagramDescription(results.enneagramType),
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

  // ---------------- RAADS FULL SECTION ----------------

  Widget _buildRaadsResult() {
    return _card(
      icon: Icons.health_and_safety,
      iconColor: Colors.teal,
      title: 'RAADS-R Subscale Scores',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: results.raadsScores.entries.map((entry) {
          return _buildScoreChip(label: entry.key, score: entry.value);
        }).toList(),
      ),
    );
  }

  /// NEW — Raw RAADS Score + Interpretation
  Widget _buildRaadsSummaryCard() {
    return _card(
      icon: Icons.assessment,
      iconColor: Colors.redAccent,
      title: 'RAADS-R Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow(
            label: "Raw Score",
            value: results.raadsRawScore.toString(),
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Text(
            results.raadsInterpretation,
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

  // ---------------- COMMON COMPONENTS ----------------

  Widget _card({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circleIcon(icon, iconColor),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
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
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildScoreChip({required String label, required double score}) {
    final Color color = score < 30
        ? Colors.green
        : score < 60
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Will add that later'),
              action: SnackBarAction(label: 'Undo', onPressed: () {}),
              backgroundColor:
                  Colors.blueGrey, // Optional: set background color
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share, size: 20),
            SizedBox(width: 12),
            Text(
              'Share Results',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTraitColor(String trait) {
    const colors = {
      'Openness': Colors.blue,
      'Conscientiousness': Colors.green,
      'Extraversion': Colors.orange,
      'Agreeableness': Colors.pink,
      'Neuroticism': Colors.purple,
    };
    return colors[trait] ?? Colors.grey;
  }

  String _getEnneagramDescription(String type) {
    final descriptions = {
      '1': 'The Reformer - Principled, Purposeful, Self-Controlled',
      '2': 'The Helper - Caring, Interpersonal, Generous',
      '3': 'The Achiever - Success-Oriented, Pragmatic, Image-Conscious',
      '4': 'The Individualist - Sensitive, Withdrawn, Expressive',
      '5': 'The Investigator - Intense, Cerebral, Perceptive',
      '6': 'The Loyalist - Committed, Security-Oriented, Engaging',
      '7': 'The Enthusiast - Busy, Fun-Loving, Spontaneous',
      '8': 'The Challenger - Powerful, Dominating, Self-Confident',
      '9': 'The Peacemaker - Easygoing, Self-Effacing, Receptive',
    };
    final cleaned = type.replaceAll(RegExp(r'[^0-9]'), '');
    return descriptions[cleaned] ?? 'Enneagram Type';
  }
}
