import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personality_detector/domain/models/results.dart';
import 'package:personality_detector/presentation/cubit/quiz_cubit.dart';
import 'package:personality_detector/presentation/widgets/results/action_buttons.dart';
import 'package:personality_detector/presentation/widgets/results/big_five_result_card.dart';
import 'package:personality_detector/presentation/widgets/results/enneagram_result_card.dart';
import 'package:personality_detector/presentation/widgets/results/mbti_result_card.dart';
import 'package:personality_detector/presentation/widgets/results/raads_result_card.dart';
import 'package:personality_detector/presentation/widgets/results/results_header.dart';
import 'package:share_plus/share_plus.dart';

class ResultsScreen extends StatefulWidget {
  final Results results;

  const ResultsScreen({super.key, required this.results});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  final GlobalKey _shareKey = GlobalKey();
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.easeOut);
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldGoBack = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('Go Back?'),
              content: Text('This will return you to the start screen.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('OK'),
                ),
              ],
            ),
          );

          if (shouldGoBack == true && context.mounted) {
            context.read<QuizCubit>().reset();
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.purple.shade50],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              ResultsHeader(),
              SliverPadding(
                padding: EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    RepaintBoundary(
                      key: _shareKey,
                      child: _buildShareableContent(),
                    ),
                    SizedBox(height: 40),
                    ActionButtons(
                      onShare: _shareResults,
                      onSave: _saveToDevice,
                    ),
                    SizedBox(height: 20),
                    _buildBackButton(context),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareResults() async {
    try {
      final boundary =
          _shareKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/personality_results.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Check out my personality test results!',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    }
  }

  Future<void> _saveToDevice() async {
    try {
      final boundary =
          _shareKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/personality_results_$timestamp.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to ${file.path}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  Widget _buildShareableContent() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'My Personality Results',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 24),
          _buildAnimatedCard(
            0,
            MbtiResultCard(mbtiType: widget.results.mbtiType),
          ),
          SizedBox(height: 20),
          _buildAnimatedCard(
            1,
            BigFiveResultCard(big5Percentages: widget.results.big5Percentages),
          ),
          SizedBox(height: 20),
          _buildAnimatedCard(
            2,
            EnneagramResultCard(enneagramType: widget.results.enneagramType),
          ),
          SizedBox(height: 20),
          _buildAnimatedCard(
            3,
            RaadsResultCard(
              rawScore: widget.results.raadsRawScore,
              interpretation: widget.results.raadsInterpretation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          context.read<QuizCubit>().reset();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF6C63FF),
          side: BorderSide(color: Color(0xFF6C63FF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 20),
            SizedBox(width: 12),
            Text('Back to Home'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(int index, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.3),
        end: Offset.zero,
      ).animate(_animations[index]),
      child: FadeTransition(opacity: _animations[index], child: child),
    );
  }
}
