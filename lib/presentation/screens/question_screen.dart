import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personality_detector/presentation/cubit/quiz_cubit.dart';
import 'package:personality_detector/presentation/screens/results_screen.dart';
import 'package:personality_detector/presentation/widgets/question_widget.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  bool _isNavigatingToResults = false;

  @override
  void initState() {
    super.initState();
    _isNavigatingToResults = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocListener<QuizCubit, QuizState>(
        listenWhen: (previous, current) {
          // Only navigate when calculation is complete
          return !previous.isQuizCompleted &&
              current.isQuizCompleted &&
              current.results != null &&
              !current.isCalculatingResults &&
              !_isNavigatingToResults;
        },
        listener: (context, state) {
          if (state.isQuizCompleted && state.results != null) {
            _isNavigatingToResults = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultsScreen(results: state.results!),
                ),
              );
            });
          }
        },
        child: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) {
            // Show calculating results screen
            if (state.isCalculatingResults) {
              return _buildCalculatingScreen(state.totalQuestions);
            }

            // Loading state
            if (state.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading ${state.totalQuestions} questions...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Error or no questions state
            if (state.questions == null || state.questions!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load questions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            // Check if we have a current question index
            if (state.currentQuestionIndex == null ||
                state.currentQuestionIndex! >= state.questions!.length) {
              // This case shouldn't happen anymore with isCalculatingResults flag
              return _buildCalculatingScreen(state.totalQuestions);
            }

            // Normal question state
            return _buildQuestionUI(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildCalculatingScreen(int totalQuestions) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated progress indicator
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          const Color(0xFF6C63FF).withOpacity(0.3),
                        ),
                        strokeWidth: 8,
                      ),
                    ),
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                        strokeWidth: 4,
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.psychology_outlined,
                        size: 40,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Calculating Your Results',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Analyzing $totalQuestions responses...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few moments',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 32),
              // Show a progress bar for large question sets
              if (totalQuestions > 50)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: LinearProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                    backgroundColor: Colors.grey.shade200,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionUI(BuildContext context, QuizState state) {
    final question = state.questions![state.currentQuestionIndex!];
    final totalQuestions = state.questions!.length;
    final questionNumber = state.currentQuestionIndex! + 1;
    final progress = questionNumber / totalQuestions;

    return WillPopScope(
      onWillPop: () async => _showExitConfirmationDialog(context),
      child: Stack(
        children: [
          // Background Progress Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: Colors.grey.shade200,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // Question Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Progress
                _QuestionHeader(
                  questionNumber: questionNumber,
                  totalQuestions: totalQuestions,
                  progress: progress,
                ),
                const SizedBox(height: 32),

                // Question Widget
                Expanded(
                  child: QuestionWidget(
                    question: question,
                    questionNumber: questionNumber,
                    totalQuestions: totalQuestions,
                    onAnswered: (value) {
                      context.read<QuizCubit>().answer(value);
                    },
                  ),
                ),

                // Previous Button
                if (state.currentQuestionIndex! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<QuizCubit>().goBack();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6C63FF),
                          side: const BorderSide(color: Color(0xFF6C63FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 20),
                            SizedBox(width: 8),
                            Text('Previous Question'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Close button
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.grey),
              ),
              onPressed: () => _showExitConfirmationDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<QuizCubit>().reset();
              Navigator.pop(context, true);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      Navigator.pop(context);
      return true;
    }
    return false;
  }
}

class _QuestionHeader extends StatelessWidget {
  final int questionNumber;
  final int totalQuestions;
  final double progress;

  const _QuestionHeader({
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
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% complete',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
