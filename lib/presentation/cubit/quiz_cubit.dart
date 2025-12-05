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
      emit(state.copyWith(
        currentQuestionIndex: _currentIndex,
        answers: List.from(_answers),
      ));
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
      final results = await compute(_calculateResultsInIsolate, (
        answers: _answers,
        questions: _questions,
      ));

      emit(
        state.copyWith(
          results: results,
          isQuizCompleted: true,
          isCalculatingResults: false,
        ),
      );
    } catch (e) {
      final results = _calculateResultsSync();
      emit(
        state.copyWith(
          results: results,
          isQuizCompleted: true,
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
      'E': 0,
      'I': 0,
      'S': 0,
      'N': 0,
      'T': 0,
      'F': 0,
      'J': 0,
      'P': 0,
    };

    final Map<String, double> big5Scores = {
      'Extroversion': 0,
      'Agreeableness': 0,
      'Conscientiousness': 0,
      'Neuroticism': 0,
      'Openness': 0,
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
      '9': 0,
    };

    final Map<String, double> raadsScores = {
      'social_relatedness': 0,
      'circumscribed_interests': 0,
      'sensory_motor': 0,
      'language': 0,
    };

    double raadsRawTotal = 0;

    for (int i = 0; i < _answers.length && i < _questions.length; i++) {
      final answer = _answers[i];
      final question = _questions[i];
      final double normalized = (answer - 3).toDouble();

      for (final entry in question.mbti.entries) {
        mbtiScores[entry.key] =
            mbtiScores[entry.key]! + normalized * entry.value;
      }

      for (final entry in question.big5.entries) {
        String mappedKey;
        if (entry.key.toLowerCase() == 'extraversion') {
          mappedKey = 'Extroversion';
        } else {
          mappedKey = entry.key[0].toUpperCase() + entry.key.substring(1);
        }

        if (big5Scores.containsKey(mappedKey)) {
          big5Scores[mappedKey] =
              big5Scores[mappedKey]! + normalized * entry.value;
        }
      }

      for (final entry in question.enneagram.entries) {
        enneagramScores[entry.key] =
            enneagramScores[entry.key]! + normalized * entry.value;
      }

      double raadsPoint = 0;
      if (normalized >= 2) {
        raadsPoint = 3;
      } else if (normalized >= 1) {
        raadsPoint = 2;
      } else if (normalized >= 0) {
        raadsPoint = 1;
      } else {
        raadsPoint = 0;
      }

      for (final entry in question.raads.entries) {
        raadsScores[entry.key] =
            raadsScores[entry.key]! + raadsPoint * entry.value;
        raadsRawTotal += raadsPoint * entry.value;
      }
    }

    final normalizedBig5 = _normalizeScores(big5Scores, _questions.length);

    final mbtiType = _calculateMbtiType(mbtiScores);
    final enneagramType = _calculateEnneagramType(enneagramScores);
    final normalizedRaads = _normalizeRaadsScores(
      raadsScores,
      _questions.length,
    );
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
    Map<String, double> scores,
    int questionCount,
  ) {
    final Map<String, double> normalized = {};
    final double maxPossible = 2.0 * questionCount;
    final double minPossible = -2.0 * questionCount;
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
    Map<String, double> scores,
    int questionCount,
  ) {
    final Map<String, double> normalized = {};
    final double range = 2.0 * questionCount;

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

Future<Results> _calculateResultsInIsolate(
  ({List<int> answers, List<Question> questions}) data,
) async {
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
    'P': 0,
  };

  final Map<String, double> big5Scores = {
    'Extroversion': 0,
    'Agreeableness': 0,
    'Conscientiousness': 0,
    'Neuroticism': 0,
    'Openness': 0,
  };

  final Map<String, double> big5MaxPossible = {
    'Extroversion': 0,
    'Agreeableness': 0,
    'Conscientiousness': 0,
    'Neuroticism': 0,
    'Openness': 0,
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
    '9': 0,
  };

  final Map<String, double> raadsScores = {
    'social_relatedness': 0,
    'circumscribed_interests': 0,
    'sensory_motor': 0,
    'language': 0,
  };

  double raadsRawTotal = 0;

  const int likertOffset = 3;

  for (int i = 0; i < answers.length; i++) {
    if (i >= questions.length) break;

    final answer = answers[i];
    final question = questions[i];

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

        big5MaxPossible[mappedKey] =
            big5MaxPossible[mappedKey]! + (2.0 * weight.abs());
      }
    });

    question.enneagram.forEach((key, weight) {
      if (enneagramScores.containsKey(key)) {
        enneagramScores[key] = enneagramScores[key]! + (normalized * weight);
      }
    });

    double raadsPoint = 0;
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
      (enneagramScores[w1.toString()] ?? 0) >=
          (enneagramScores[w2.toString()] ?? 0)
      ? w1.toString()
      : w2.toString();

  final enneagramType = '${mainType}w$wing';

  final Map<String, double> normalizedRaads = {};
  raadsScores.forEach((key, value) {
    double scaled = (value / 60.0) * 100;
    normalizedRaads[key] = scaled.clamp(0.0, 100.0);
  });

  final int rawRaadsScore = raadsRawTotal.round();

  String getInterpretation(int score) {
    if (score < 25) return "You are not autistic.";
    if (score < 50) return "Some autistic traits but likely not autistic.";
    if (score < 65) return "Borderline range; autism possible.";
    if (score < 90) return "Meets the minimum threshold suggesting autism.";
    if (score < 130) return "Stronger autistic traits present.";
    if (score < 160) return "Strong evidence for autism.";
    if (score < 227) return "Very strong evidence for autism.";
    return "Extremely high RAADS-R score.";
  }

  return Results(
    mbtiType: mbtiType,
    big5Percentages: normalizedBig5,
    enneagramType: enneagramType,
    raadsScores: normalizedRaads,
    raadsRawScore: rawRaadsScore,
    raadsInterpretation: getInterpretation(rawRaadsScore),
  );
}
