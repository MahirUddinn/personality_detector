import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personality_detector/presentation/cubit/quiz_cubit.dart';
import 'package:personality_detector/data/repositories/quiz_repository_impl.dart';
import 'package:personality_detector/presentation/screens/results_screen.dart';
import 'package:personality_detector/presentation/screens/start_screen.dart';
import 'package:personality_detector/presentation/widgets/question_widget.dart';
import '../widgets/question_header.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          if (state.isQuizCompleted || state.isCalculatingResults) {
            return _buildCalculatingScreen(state.totalQuestions);
          }

          if (state.isLoading) {
            return _buildLoadingState(state);
          }

          if (state.questions == null || state.questions!.isEmpty) {
            return _buildErrorState(context);
          }

          return _buildPageViewUI(context, state);
        },
      ),
    );
  }

  Widget _buildLoadingState(QuizState state) {
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
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

  Widget _buildCalculatingScreen(int totalQuestions) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          const Color(0xFF6C63FF).withAlpha(77),
                        ),
                        strokeWidth: 8,
                      ),
                    ),
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF6C63FF)),
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
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few moments',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 32),
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

  Widget _buildPageViewUI(BuildContext context, QuizState state) {
    final questions = state.questions!;
    final totalQuestions = questions.length;
    final currentQIndex = state.currentQuestionIndex ?? 0;

    final progress = (currentQIndex + 1) / totalQuestions;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _showExitConfirmationDialog(context);
        }
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalQuestions,
              itemBuilder: (context, index) {
                final question = questions[index];
                final questionNumber = index + 1;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      QuestionHeader(
                        questionNumber: questionNumber,
                        totalQuestions: totalQuestions,
                        progress: questionNumber / totalQuestions,
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: QuestionWidget(
                          question: question,
                          questionNumber: questionNumber,
                          totalQuestions: totalQuestions,
                          initialValue: state.answers.length > index
                              ? state.answers[index]
                              : 3,
                          onAnswered: (value) async {
                            final cubit = context.read<QuizCubit>();

                            // 1. Update State
                            await cubit.answer(value);

                            if (!context.mounted) return;

                            // 2. Check for Completion
                            if (cubit.state.isQuizCompleted &&
                                cubit.state.results != null) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => ResultsScreen(
                                    results: cubit.state.results!,
                                  ),
                                ),
                              );
                            } else {
                              // 3. Animate Next
                              if (_pageController.hasClients) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                          },
                        ),
                      ),

                      // Previous Button
                      if (questionNumber > 1) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              context.read<QuizCubit>().goBack();
                              if (_pageController.hasClients) {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
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
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Progress Bar
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

          // Close Button
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(51),
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

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldExit == true && context.mounted) {
      context.read<QuizCubit>().reset();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => QuizCubit(QuizRepositoryImpl()),
            child: const StartScreen(),
          ),
        ),
      );
    }
  }
}
