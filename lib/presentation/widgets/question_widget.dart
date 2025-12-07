import 'package:flutter/material.dart';
import 'package:personality_detector/domain/models/question.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final ValueChanged<int> onChanged;
  final int initialValue;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onChanged,
    this.initialValue = 3,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.initialValue.toDouble();
  }

  @override
  void didUpdateWidget(QuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _sliderValue = widget.initialValue.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF6C63FF).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Question ${widget.questionNumber}',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              widget.question.text,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),
            _buildSlider(),
            SizedBox(height: 32),
            _buildScaleLabels(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Color(0xFF6C63FF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6C63FF).withAlpha(77),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _sliderValue.round().toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 16,
              elevation: 4,
            ),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 28),
            activeTrackColor: Color(0xFF6C63FF),
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: Colors.white,
            overlayColor: Color(0xFF6C63FF).withAlpha(51),
            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: Color(0xFF6C63FF),
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: _sliderValue,
            min: 1,
            max: 5,
            divisions: 4,
            label: _sliderValue.round().toString(),
            onChanged: (value) {
              setState(() {
                _sliderValue = value;
              });
              widget.onChanged(value.round());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScaleLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Strongly\nDisagree',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Disagree',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Neutral',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Agree',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Strongly\nAgree',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
