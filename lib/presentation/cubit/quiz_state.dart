part of 'quiz_cubit.dart';
class QuizState {
  final bool isLoading;
  final int? currentQuestionIndex;
  final List<Question>? questions;
  final Results? results;
  final int totalQuestions;
  final bool isQuizCompleted;
  final bool isCalculatingResults;

  const QuizState({
    this.isLoading = false,
    this.currentQuestionIndex,
    this.questions,
    this.results,
    this.totalQuestions = 0,
    this.isQuizCompleted = false,
    this.isCalculatingResults = false,
  });

  QuizState copyWith({
    bool? isLoading,
    int? currentQuestionIndex,
    List<Question>? questions,
    Results? results,
    int? totalQuestions,
    bool? isQuizCompleted,
    bool? isCalculatingResults,
  }) {
    return QuizState(
      isLoading: isLoading ?? this.isLoading,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      questions: questions ?? this.questions,
      results: results ?? this.results,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
      isCalculatingResults: isCalculatingResults ?? this.isCalculatingResults,
    );
  }
}