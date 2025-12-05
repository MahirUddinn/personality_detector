import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personality_detector/data/repositories/quiz_repository_impl.dart';
import 'package:personality_detector/presentation/cubit/quiz_cubit.dart';
import 'package:personality_detector/presentation/screens/start_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizCubit(QuizRepositoryImpl()),
      child: MaterialApp(
        title: 'Personality Detector',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const StartScreen(),
      ),
    );
  }
}