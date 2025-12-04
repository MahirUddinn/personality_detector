import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:personality_detector/domain/models/question.dart';
import 'package:personality_detector/domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  @override
  Future<List<Question>> getQuestions() async {
    final jsonString = await rootBundle.loadString('assets/questions_120.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Question.fromJson(json)).toList();
  }
}
