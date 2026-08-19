import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personality_detector/domain/models/question.dart';
import 'package:personality_detector/domain/models/results.dart';
import 'package:personality_detector/domain/repositories/quiz_repository.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final QuizRepository _quizRepository;
  late List<Question> _questions;
  int _currentIndex = 0;
  final List<int> _answers;
  bool _isCalculatingResults = false;

  QuizCubit(this._quizRepository) : _answers = [], super(const QuizState());

  Future<void> startQuiz() async {
    emit(const QuizState(isLoading: true));
    try {
      _questions = await _quizRepository.getQuestions();
      _currentIndex = 0;
      _answers.clear();
      _isCalculatingResults = false;
      emit(
        QuizState(
          isLoading: false,
          questions: _questions,
          currentQuestionIndex: _currentIndex,
          totalQuestions: _questions.length,
          answers: const [],
        ),
      );
    } catch (e) {
      emit(const QuizState(isLoading: false, hasError: true));
    }
  }

  void reset() {
    _currentIndex = 0;
    _answers.clear();
    _isCalculatingResults = false;
    emit(const QuizState());
  }

  void setIndex(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      emit(state.copyWith(currentQuestionIndex: _currentIndex));
    }
  }

  void goBack() {
    if (_currentIndex > 0) {
      _currentIndex--;
      emit(state.copyWith(currentQuestionIndex: _currentIndex));
    } else {
      reset();
    }
  }

  Future<void> answer(int value) async {
    if (_currentIndex >= _questions.length || _isCalculatingResults) return;

    if (_answers.length <= _currentIndex) {
      _answers.add(value);
    } else {
      _answers[_currentIndex] = value;
    }

    _currentIndex++;

    if (_currentIndex < _questions.length) {
      emit(
        state.copyWith(
          currentQuestionIndex: _currentIndex,
          answers: List.from(_answers),
        ),
      );
    } else {
      emit(
        state.copyWith(
          currentQuestionIndex: _currentIndex,
          isCalculatingResults: true,
          answers: List.from(_answers),
        ),
      );
      await _calculateResultsAsync();
    }
  }

  Future<void> _calculateResultsAsync() async {
    _isCalculatingResults = true;
    try {
      // Simulate calculation delay for better UX
      await Future.delayed(const Duration(milliseconds: 800));
      final results = _calculateResultsSync();

      emit(
        state.copyWith(
          results: results,
          isQuizCompleted: true,
          isCalculatingResults: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          hasError: true,
          isCalculatingResults: false,
        ),
      );
    } finally {
      if (_isCalculatingResults) {
        _isCalculatingResults = false;
      }
    }
  }

  Results _calculateResultsSync() {
    final Map<String, double> mbtiScores = {
      'E': 0, 'I': 0, 'S': 0, 'N': 0, 'T': 0, 'F': 0, 'J': 0, 'P': 0,
    };

    final Map<String, double> big5Scores = {
      'Extroversion': 0, 'Agreeableness': 0, 'Conscientiousness': 0, 'Neuroticism': 0, 'Openness': 0,
    };
    final Map<String, double> big5MaxPossible = {
      'Extroversion': 0, 'Agreeableness': 0, 'Conscientiousness': 0, 'Neuroticism': 0, 'Openness': 0,
    };

    final Map<String, double> enneagramScores = {
      '1': 0, '2': 0, '3': 0, '4': 0, '5': 0, '6': 0, '7': 0, '8': 0, '9': 0,
    };

    final Map<String, double> raadsScores = {
      'social_relatedness': 0, 'circumscribed_interests': 0, 'sensory_motor': 0, 'language': 0,
    };
    final Map<String, double> raadsMaxPossible = {
      'social_relatedness': 0, 'circumscribed_interests': 0, 'sensory_motor': 0, 'language': 0,
    };

    double raadsRawTotal = 0;
    const int likertOffset = 3;

    for (int i = 0; i < _answers.length && i < _questions.length; i++) {
      final answer = _answers[i];
      final question = _questions[i];
      final double normalized = (answer - likertOffset).toDouble();

      question.mbti.forEach((key, weight) {
        if (mbtiScores.containsKey(key)) {
          mbtiScores[key] = mbtiScores[key]! + (normalized * weight);
        }
      });

      question.big5.forEach((key, weight) {
        String? mappedKey;
        if (key.toLowerCase() == 'extraversion') {
          mappedKey = 'Extroversion';
        } else {
          mappedKey = key[0].toUpperCase() + key.substring(1);
        }

        if (big5Scores.containsKey(mappedKey)) {
          big5Scores[mappedKey] = big5Scores[mappedKey]! + (normalized * weight);
          big5MaxPossible[mappedKey] = big5MaxPossible[mappedKey]! + (2.0 * weight.abs());
        }
      });

      question.enneagram.forEach((key, weight) {
        if (enneagramScores.containsKey(key)) {
          enneagramScores[key] = enneagramScores[key]! + (normalized * weight);
        }
      });

      double raadsPoint = 0;
      double maxRaadsPoint = 3; // Answer 5
      if (normalized >= 2) {
        raadsPoint = 3;
      } else if (normalized >= 1) {
        raadsPoint = 2;
      } else if (normalized >= 0) {
        raadsPoint = 1;
      } else {
        raadsPoint = 0;
      }

      question.raads.forEach((key, weight) {
        if (raadsScores.containsKey(key)) {
          raadsScores[key] = raadsScores[key]! + (raadsPoint * weight);
          raadsMaxPossible[key] = raadsMaxPossible[key]! + (maxRaadsPoint * weight);
          raadsRawTotal += (raadsPoint * weight);
        }
      });
    }

    final Map<String, double> normalizedBig5 = {};
    big5Scores.forEach((key, value) {
      double max = big5MaxPossible[key] ?? 1;
      if (max == 0) max = 1;

      double percent = ((value + max) / (2 * max)) * 100;
      normalizedBig5[key] = percent.clamp(0.0, 100.0);
    });

    String mbtiType = '';
    mbtiType += (mbtiScores['E'] ?? 0) >= (mbtiScores['I'] ?? 0) ? 'E' : 'I';
    mbtiType += (mbtiScores['S'] ?? 0) >= (mbtiScores['N'] ?? 0) ? 'S' : 'N';
    mbtiType += (mbtiScores['T'] ?? 0) >= (mbtiScores['F'] ?? 0) ? 'T' : 'F';
    mbtiType += (mbtiScores['J'] ?? 0) >= (mbtiScores['P'] ?? 0) ? 'J' : 'P';

    String mainType = '1';
    double highestScore = -double.infinity;
    enneagramScores.forEach((key, value) {
      if (value > highestScore) {
        highestScore = value;
        mainType = key;
      }
    });

    final int mainInt = int.tryParse(mainType) ?? 1;
    final int w1 = (mainInt - 2 + 9) % 9 + 1;
    final int w2 = mainInt % 9 + 1;

    final String wing =
        (enneagramScores[w1.toString()] ?? 0) >= (enneagramScores[w2.toString()] ?? 0)
            ? w1.toString()
            : w2.toString();

    final enneagramType = '${mainType}w$wing';

    final Map<String, double> normalizedRaads = {};
    raadsScores.forEach((key, value) {
      double max = raadsMaxPossible[key] ?? 1;
      if (max == 0) max = 1;
      double scaled = (value / max) * 100;
      normalizedRaads[key] = scaled.clamp(0.0, 100.0);
    });

    final int rawRaadsScore = raadsRawTotal.round();

    return Results(
      mbtiType: mbtiType,
      big5Percentages: normalizedBig5,
      enneagramType: enneagramType,
      raadsScores: normalizedRaads,
      raadsRawScore: rawRaadsScore,
      raadsInterpretation: _getRaadsInterpretation(rawRaadsScore),
    );
  }

  static String _getRaadsInterpretation(int score) {
    if (score < 25) return "You are not autistic.";
    if (score < 50) return "Some autistic traits but likely not autistic.";
    if (score < 65) return "Borderline range; autism possible.";
    if (score < 90) return "Meets the minimum threshold suggesting autism.";
    if (score < 130) return "Stronger autistic traits present.";
    if (score < 160) return "Strong evidence for autism.";
    if (score < 227) return "Very strong evidence for autism.";
    return "Extremely high RAADS-R score.";
  }

  void restartQuiz() {
    _currentIndex = 0;
    _answers.clear();
    _isCalculatingResults = false;
    _questions.shuffle();
    emit(
      QuizState(
        isLoading: false,
        questions: _questions,
        currentQuestionIndex: 0,
        totalQuestions: _questions.length,
      ),
    );
  }

  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
}
