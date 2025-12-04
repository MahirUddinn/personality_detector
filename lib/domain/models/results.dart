import 'package:equatable/equatable.dart';

class Results extends Equatable {
  final String mbtiType;
  final Map<String, double> big5Percentages;
  final String enneagramType;

  /// RAADS-R Subscale Percentages (0–100)
  final Map<String, double> raadsScores;

  /// RAADS-R Raw Total Score (0–240)
  final int raadsRawScore;

  /// RAADS-R Interpretation (string description)
  final String raadsInterpretation;

  const Results({
    required this.mbtiType,
    required this.big5Percentages,
    required this.enneagramType,
    required this.raadsScores,
    required this.raadsRawScore,
    required this.raadsInterpretation,
  });

  @override
  List<Object?> get props => [
    mbtiType,
    big5Percentages,
    enneagramType,
    raadsScores,
    raadsRawScore,
    raadsInterpretation,
  ];
}
