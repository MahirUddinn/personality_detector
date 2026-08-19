import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'question.g.dart';

@JsonSerializable()
class Question extends Equatable {
  final int id;
  final String text;
  @JsonKey(defaultValue: <String, double>{})
  final Map<String, double> mbti;
  
  @JsonKey(defaultValue: <String, double>{})
  final Map<String, double> big5;
  
  @JsonKey(defaultValue: <String, double>{})
  final Map<String, double> enneagram;
  
  @JsonKey(defaultValue: <String, double>{})
  final Map<String, double> raads;

  const Question({
    required this.id,
    required this.text,
    this.mbti = const {},
    this.big5 = const {},
    this.enneagram = const {},
    this.raads = const {},
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  @override
  List<Object?> get props => [id, text, mbti, big5, enneagram, raads];
}
