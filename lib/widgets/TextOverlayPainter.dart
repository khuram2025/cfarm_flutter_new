import 'package:flutter/material.dart';

class TextOverlayPainter extends CustomPainter {
  final String allText;
  final String cowText;
  final String buffaloText;

  TextOverlayPainter(this.allText, this.cowText, this.buffaloText);

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: allText,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: ' ',
        ),
        TextSpan(
          text: cowText,
          style: TextStyle(
            color: Colors.green,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: ' ',
        ),
        TextSpan(
          text: buffaloText,
          style: TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final offset = Offset(10, size.height + 10); // Add padding from the left and below the chart
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
