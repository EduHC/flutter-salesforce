import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int starCount;
  final double rating;
  final Color color;
  final double size;

  const StarRatingWidget({
    this.starCount = 5,
    required this.rating,
    this.color = Colors.orange,
    this.size = 24,
    super.key,
  });

  Widget buildStar(int index) {
    IconData icon;
    if (rating >= index + 1) {
      icon = Icons.star;
    } else if (rating > index && rating < index + 1) {
      icon = Icons.star_half;
    } else {
      icon = Icons.star_border;
    }
    return Icon(icon, color: color, size: size);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) => buildStar(index)),
    );
  }
}
