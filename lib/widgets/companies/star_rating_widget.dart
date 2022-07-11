import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int stars;

  StarRatingWidget(this.stars);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star_border,
          color: stars > 0 ? Colors.yellow.shade700 : Colors.grey.shade600,
        ),
        Icon(
          Icons.star_border,
          color: stars > 1 ? Colors.yellow.shade700 : Colors.grey.shade600,
        ),
        Icon(
          Icons.star_border,
          color: stars > 2 ? Colors.yellow.shade700 : Colors.grey.shade600,
        ),
        Icon(
          Icons.star_border,
          color: stars > 3 ? Colors.yellow.shade700 : Colors.grey.shade600,
        ),
        Icon(
          Icons.star_border,
          color: stars > 4 ? Colors.yellow.shade700 : Colors.grey.shade600,
        ),
      ],
    );
  }
}
