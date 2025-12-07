import 'package:flutter/material.dart';
import 'package:personality_detector/presentation/cubit/quiz_cubit.dart';
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, required this.state});

  final QuizState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF6C63FF)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading ${state.totalQuestions} questions...',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
