import 'package:personality_detector/domain/models/question.dart';

abstract class QuizRepository {
  Future<List<Question>> getQuestions();
}
