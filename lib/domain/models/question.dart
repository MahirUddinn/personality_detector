import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'question.g.dart';

@JsonSerializable()
class Question extends Equatable {
  final int id;
  final String text;
  final Map<String, double> mbti;
  final Map<String, double> big5;
  final Map<String, double> enneagram;
  final Map<String, double> raads;

  const Question({
    required this.id,
    required this.text,
    required this.mbti,
    required this.big5,
    required this.enneagram,
    required this.raads,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  @override
  List<Object?> get props => [id, text, mbti, big5, enneagram, raads];
}
