import 'package:equatable/equatable.dart';

class Results extends Equatable {
  final String mbtiType;
  final Map<String, double> big5Percentages;
  final String enneagramType;
  final Map<String, double> raadsScores;
  final int raadsRawScore;
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
