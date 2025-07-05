import 'package:flutter/material.dart';

class TitleDividerWidget extends StatelessWidget {
  final String text;

  const TitleDividerWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4f6e62),
            ),
          ),
          Divider(color: Color(0xFF4f6e62), indent: 12, endIndent: 12),
        ],
      ),
    );
  }
}
