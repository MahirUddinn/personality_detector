import 'dart:async';
import 'package:flutter/foundation.dart';
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

  QuizCubit(this._quizRepository)
      : _answers = [],
        super(const QuizState());

  Future<void> startQuiz() async {
    emit(state.copyWith(isLoading: true));
    try {
      _questions = await _quizRepository.getQuestions();
      _currentIndex = 0;
      _answers.clear();
      _isCalculatingResults = false;
      emit(QuizState(
        isLoading: false,
        questions: _questions,
        currentQuestionIndex: _currentIndex,
        totalQuestions: _questions.length,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  void reset() {
    _currentIndex = 0;
    _answers.clear();
    _isCalculatingResults = false;
    emit(const QuizState());
  }

  void goBack() {
    if (_currentIndex > 0) {
      _currentIndex--;
      emit(state.copyWith(
        currentQuestionIndex: _currentIndex,
      ));
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
      emit(state.copyWith(
        currentQuestionIndex: _currentIndex,
      ));
    } else {
      emit(state.copyWith(
        currentQuestionIndex: _currentIndex,
        isCalculatingResults: true,
      ));
      await _calculateResultsAsync();
    }
  }

  Future<void> _calculateResultsAsync() async {
    _isCalculatingResults = true;
    try {
      final results = await compute(_calculateResultsInIsolate,
          (answers: _answers, questions: _questions));

      emit(state.copyWith(
        results: results,
        isQuizCompleted: true,
        isCalculatingResults: false,
      ));
    } catch (e) {
      final results = _calculateResultsSync();
      emit(state.copyWith(
        results: results,
        isQuizCompleted: true,
        isCalculatingResults: false,
      ));
    } finally {
      if (_isCalculatingResults) {
        _isCalculatingResults = false;
      }
    }
  }

  Results _calculateResultsSync() {
    final Map<String, double> mbtiScores = {
      'E': 0,
      'I': 0,
      'S': 0,
      'N': 0,
      'T': 0,
      'F': 0,
      'J': 0,
      'P': 0
    };

    final Map<String, double> big5Scores = {
      'extraversion': 0,
      'agreeableness': 0,
      'conscientiousness': 0,
      'neuroticism': 0,
      'openness': 0
    };

    final Map<String, double> enneagramScores = {
      '1': 0,
      '2': 0,
      '3': 0,
      '4': 0,
      '5': 0,
      '6': 0,
      '7': 0,
      '8': 0,
      '9': 0
    };

    final Map<String, double> raadsScores = {
      'social_relatedness': 0,
      'circumscribed_interests': 0,
      'sensory_motor': 0,
      'language': 0
    };

    double raadsRawTotal = 0;

    for (int i = 0; i < _answers.length && i < _questions.length; i++) {
      final answer = _answers[i];
      final question = _questions[i];
      final double normalized = (answer - 4).toDouble();

      for (final entry in question.mbti.entries) {
        mbtiScores[entry.key] =
            mbtiScores[entry.key]! + normalized * entry.value;
      }

      for (final entry in question.big5.entries) {
        big5Scores[entry.key] =
            big5Scores[entry.key]! + normalized * entry.value;
      }

      for (final entry in question.enneagram.entries) {
        enneagramScores[entry.key] =
            enneagramScores[entry.key]! + normalized * entry.value;
      }

      final double raadsItemRaw = ((normalized + 3) / 3).clamp(0.0, 2.0);
      for (final entry in question.raads.entries) {
        raadsScores[entry.key] =
            raadsScores[entry.key]! + normalized * entry.value;
        raadsRawTotal += raadsItemRaw * entry.value;
      }
    }

    final normalizedBig5 = _normalizeScores(big5Scores, _questions.length);

    final mbtiType = _calculateMbtiType(mbtiScores);
    final enneagramType = _calculateEnneagramType(enneagramScores);
    final normalizedRaads =
        _normalizeRaadsScores(raadsScores, _questions.length);
    final int rawRaadsScore = raadsRawTotal.round();
    final String interpretation = _getRaadsInterpretation(rawRaadsScore);

    return Results(
      mbtiType: mbtiType,
      big5Percentages: normalizedBig5,
      enneagramType: enneagramType,
      raadsScores: normalizedRaads,
      raadsRawScore: rawRaadsScore,
      raadsInterpretation: interpretation,
    );
  }

  Map<String, double> _normalizeScores(
      Map<String, double> scores, int questionCount) {
    final Map<String, double> normalized = {};
    final double maxPossible = 3.0 * questionCount;
    final double minPossible = -3.0 * questionCount;
    final double range = maxPossible - minPossible;

    scores.forEach((key, value) {
      final scaled = ((value - minPossible) / range) * 100;
      normalized[key] = scaled.clamp(0.0, 100.0);
    });

    return normalized;
  }

  String _calculateMbtiType(Map<String, double> scores) {
    String type = '';
    type += scores['E']! >= scores['I']! ? 'E' : 'I';
    type += scores['S']! >= scores['N']! ? 'S' : 'N';
    type += scores['T']! >= scores['F']! ? 'T' : 'F';
    type += scores['J']! >= scores['P']! ? 'J' : 'P';
    return type;
  }

  String _calculateEnneagramType(Map<String, double> scores) {
    String mainType = '1';
    double highestScore = -double.infinity;

    scores.forEach((key, value) {
      if (value > highestScore) {
        highestScore = value;
        mainType = key;
      }
    });

    final int mainInt = int.parse(mainType);
    final int wing1 = (mainInt - 2 + 9) % 9 + 1;
    final int wing2 = mainInt % 9 + 1;

    final String wing = scores[wing1.toString()]! >= scores[wing2.toString()]!
        ? wing1.toString()
        : wing2.toString();

    return '${mainType}w$wing';
  }

  Map<String, double> _normalizeRaadsScores(
      Map<String, double> scores, int questionCount) {
    final Map<String, double> normalized = {};
    final double range = 3.0 * questionCount;

    scores.forEach((key, value) {
      double normalizedScore = ((value + (range * 0.5)) / range) * 100;
      normalizedScore = normalizedScore.clamp(0, 100);
      normalized[key] = normalizedScore;
    });

    return normalized;
  }

  static String _getRaadsInterpretation(int score) {
    if (score < 25) return "You are not autistic.";
    if (score < 50) return "Some autistic traits but likely not autistic.";
    if (score < 65) return "Borderline range; autism possible.";
    if (score < 90) return "Meets the minimum threshold suggesting autism.";
    if (score < 130) return "Stronger autistic traits present.";
    if (score < 160) return "Strong evidence for autism.";
    if (score < 227) return "Very strong evidence for autism.";
    if (score < 240) return "Extremely high RAADS-R score.";
    return "Maximum possible RAADS-R score (240).";
  }

  void restartQuiz() {
    _currentIndex = 0;
    _answers.clear();
    _isCalculatingResults = false;
    emit(QuizState(
      isLoading: false,
      questions: _questions,
      currentQuestionIndex: 0,
      totalQuestions: _questions.length,
    ));
  }

  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
}

Future<Results> _calculateResultsInIsolate(
    ({List<int> answers, List<Question> questions}) data) async {
  final answers = data.answers;
  final questions = data.questions;
  final Map<String, double> mbtiScores = {
    'E': 0,
    'I': 0,
    'S': 0,
    'N': 0,
    'T': 0,
    'F': 0,
    'J': 0,
    'P': 0
  };

  final Map<String, double> big5Scores = {
    'extraversion': 0,
    'agreeableness': 0,
    'conscientiousness': 0,
    'neuroticism': 0,
    'openness': 0
  };

  final Map<String, double> enneagramScores = {
    '1': 0,
    '2': 0,
    '3': 0,
    '4': 0,
    '5': 0,
    '6': 0,
    '7': 0,
    '8': 0,
    '9': 0
  };

  final Map<String, double> raadsScores = {
    'social_relatedness': 0,
    'circumscribed_interests': 0,
    'sensory_motor': 0,
    'language': 0
  };

  double raadsRawTotal = 0;

  final batchSize = 20;
  for (int i = 0; i < answers.length; i++) {
    if (i >= questions.length) break;

    final answer = answers[i];
    final question = questions[i];
    final double normalized = (answer - 4).toDouble();

    question.mbti.forEach((key, value) {
      mbtiScores[key] = mbtiScores[key]! + normalized * value;
    });

    question.big5.forEach((key, value) {
      big5Scores[key] = big5Scores[key]! + normalized * value;
    });

    question.enneagram.forEach((key, value) {
      enneagramScores[key] = enneagramScores[key]! + normalized * value;
    });

    final double raadsItemRaw = ((normalized + 3) / 3).clamp(0.0, 2.0);

    question.raads.forEach((key, value) {
      raadsScores[key] = raadsScores[key]! + normalized * value;
      raadsRawTotal += raadsItemRaw * value;
    });

    if (i % batchSize == 0) {
      await Future.delayed(const Duration(milliseconds: 1));
    }
  }

  final Map<String, double> normalizedBig5 = {};
  final double maxPossible = 3.0 * questions.length;
  final double minPossible = -3.0 * questions.length;
  final double range = maxPossible - minPossible;

  big5Scores.forEach((key, value) {
    final scaled = ((value - minPossible) / range) * 100;
    normalizedBig5[key] = scaled.clamp(0.0, 100.0);
  });

  String mbtiType = '';
  mbtiType += mbtiScores['E']! >= mbtiScores['I']! ? 'E' : 'I';
  mbtiType += mbtiScores['S']! >= mbtiScores['N']! ? 'S' : 'N';
  mbtiType += mbtiScores['T']! >= mbtiScores['F']! ? 'T' : 'F';
  mbtiType += mbtiScores['J']! >= mbtiScores['P']! ? 'J' : 'P';

  String mainType = '1';
  double highestScore = -double.infinity;
  enneagramScores.forEach((key, value) {
    if (value > highestScore) {
      highestScore = value;
      mainType = key;
    }
  });

  final int mainInt = int.parse(mainType);
  final int wing1 = (mainInt - 2 + 9) % 9 + 1;
  final int wing2 = mainInt % 9 + 1;

  final String wing =
      enneagramScores[wing1.toString()]! >= enneagramScores[wing2.toString()]!
          ? wing1.toString()
          : wing2.toString();

  final enneagramType = '${mainType}w$wing';

  final Map<String, double> normalizedRaads = {};
  final double raadsRange = 3.0 * questions.length;

  raadsScores.forEach((key, value) {
    double normalizedScore = ((value + (raadsRange * 0.5)) / raadsRange) * 100;
    normalizedScore = normalizedScore.clamp(0, 100);
    normalizedRaads[key] = normalizedScore;
  });

  final int rawRaadsScore = raadsRawTotal.round();
  final String interpretation =
      QuizCubit._getRaadsInterpretation(rawRaadsScore);

  return Results(
    mbtiType: mbtiType,
    big5Percentages: normalizedBig5,
    enneagramType: enneagramType,
    raadsScores: normalizedRaads,
    raadsRawScore: rawRaadsScore,
    raadsInterpretation: interpretation,
  );
}