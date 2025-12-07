import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personality_detector/presentation/cubit/quiz_cubit.dart';
import 'package:personality_detector/presentation/screens/results_screen.dart';
import 'package:personality_detector/presentation/widgets/calculating_view.dart';
import 'package:personality_detector/presentation/widgets/error_view.dart';
import 'package:personality_detector/presentation/widgets/loading_view.dart';
import 'package:personality_detector/presentation/widgets/question_widget.dart';
import '../widgets/question_header.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
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
            return CalculatingView(totalQuestions: state.totalQuestions);
          }

          if (state.isLoading) {
            return LoadingView(state: state);
          }

          if (state.questions == null || state.questions!.isEmpty) {
            return ErrorView(ctx: context);
          }

          return _buildPageViewUI(context, state);
        },
      ),
    );
  }

  int? _currentAnswer;

  Widget _buildPageViewUI(BuildContext context, QuizState state) {
    final totalQuestions = state.questions!.length;
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
          Column(
            children: [
              SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: QuestionHeader(
                  questionNumber: currentQIndex + 1,
                  totalQuestions: totalQuestions,
                  progress: progress,
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),

                  itemCount: totalQuestions,
                  itemBuilder: (pageContext, index) {
                    final question = state.questions![index];
                    final questionNumber = index + 1;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Center(
                        child: SingleChildScrollView(
                          child: QuestionWidget(
                            question: question,
                            questionNumber: questionNumber,
                            totalQuestions: totalQuestions,
                            initialValue: state.answers.length > index
                                ? state.answers[index]
                                : 3,
                            onChanged: (value) {
                              _currentAnswer = value;
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              _buildBottomBar(context, state),
            ],
          ),

          Positioned(
            top: 8,
            right: 16,
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(51),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.close, size: 20, color: Colors.grey),
              ),
              onPressed: () => _showExitConfirmationDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, QuizState state) {
    final isFirstQuestion = (state.currentQuestionIndex ?? 0) == 0;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            offset: Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!isFirstQuestion) ...[
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    _currentAnswer = null;
                    context.read<QuizCubit>().goBack();
                    if (_pageController.hasClients) {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF6C63FF),
                    side: BorderSide(color: Color(0xFF6C63FF)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Icon(Icons.arrow_back),
                ),
              ),
              SizedBox(width: 16),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final cubit = context.read<QuizCubit>();

                  final currentIndex = state.currentQuestionIndex ?? 0;
                  final answerToSubmit =
                      _currentAnswer ??
                      (state.answers.length > currentIndex
                          ? state.answers[currentIndex]
                          : 3);

                  await cubit.answer(answerToSubmit);

                  _currentAnswer = null;

                  if (!context.mounted) return;

                  if (cubit.state.isQuizCompleted &&
                      cubit.state.results != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            ResultsScreen(results: cubit.state.results!),
                      ),
                    );
                  } else {
                    if (_pageController.hasClients) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  (state.currentQuestionIndex ?? 0) ==
                          (state.questions!.length - 1)
                      ? 'Finish Quiz'
                      : 'Next Question',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Exit Quiz?'),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldExit == true && context.mounted) {
      context.read<QuizCubit>().reset();
      Navigator.of(context).pop();
    }
  }
}
