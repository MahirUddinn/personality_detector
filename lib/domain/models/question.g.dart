part of 'question.dart';

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: (json['id'] as num).toInt(),
  text: json['text'] as String,
  mbti: (json['mbti'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  big5: (json['big5'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  enneagram: (json['enneagram'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  raads: (json['raads'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'mbti': instance.mbti,
  'big5': instance.big5,
  'enneagram': instance.enneagram,
  'raads': instance.raads,
};
