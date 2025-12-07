import 'package:flutter/material.dart';

class CalculatingView extends StatefulWidget {
  const CalculatingView({super.key, required this.totalQuestions});

  final int totalQuestions;

  @override
  State<CalculatingView> createState() => _CalculatingViewState();
}

class _CalculatingViewState extends State<CalculatingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          Color(0xFF6C63FF).withAlpha(77),
                        ),
                        strokeWidth: 8,
                      ),
                    ),
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                        strokeWidth: 4,
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.psychology_outlined,
                        size: 40,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Calculating Your Results',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Analyzing ${widget.totalQuestions} responses...',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'This may take a few moments',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              SizedBox(height: 32),
              if (widget.totalQuestions > 50)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                    backgroundColor: Colors.grey.shade200,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
