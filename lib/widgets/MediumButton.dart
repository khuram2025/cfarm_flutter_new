import 'package:flutter/material.dart';

class MediumButton extends StatelessWidget {
  const MediumButton({
    Key? key,
    required this.btnText,
    this.fillColor,
    this.borderColor = const Color(0xFF0DA487),
    this.textColor = const Color(0xFF0DA487),
    this.onPressed,
  }) : super(key: key);

  final String btnText;
  final Color? fillColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    String capitalizedText = btnText.isEmpty
        ? btnText
        : '${btnText[0].toUpperCase()}${btnText.substring(1)}';
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Center( // Use Center for simpler alignment
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              capitalizedText,
              style: TextStyle(
                color: textColor,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}