import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/presentation/utils/math.dart';

/// Function that paints a diagonal line
/// Starts from the top left corner and ends at the bottom right corner
/// [inverse] determines if the line is inverted
/// [color] determines the color of the line
/// [strokeWidth] determines the width of the line
class DiagonalPainter extends CustomPainter {
  final bool inverse;
  final Color color;
  final double strokeWidth;

  DiagonalPainter({super.repaint, this.inverse = false, this.color = Colors.grey, this.strokeWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color 
      ..strokeWidth = strokeWidth 
      ..style = PaintingStyle.stroke; 

    if (inverse) {
      canvas.drawLine(
        Offset(size.width, 0),
        Offset(0, size.height),
        paint,
      );
    } else {
      canvas.drawLine(
          const Offset(0, 0), Offset(size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// Function that paints an arc and a circle
/// [sunset] and [sunrise] determine when the line is stroked or dashed
/// Circle is painted at the point of change of line stroke
/// [dashWidth] and [dashSpace] determine the length and space of the dashes
class SunArcPainter extends CustomPainter {
  final DateTime sunrise;
  final DateTime sunset;
  final double dashWidth;
  final double dashSpace;

  SunArcPainter({super.repaint, required this.sunset, required this.sunrise, this.dashWidth = 10, this.dashSpace = 2});
  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    late double nowRatio;

    if (now.isBefore(sunrise)) {
      nowRatio = 0.0;
    } else if (now.isAfter(sunset)) {
      nowRatio = 1.0;
    } else {
      final x = (now.millisecondsSinceEpoch - sunrise.millisecondsSinceEpoch) /
          (sunset.millisecondsSinceEpoch - sunrise.millisecondsSinceEpoch);

      nowRatio =
          interpolateBetweenPoints(y0: 0.0, y1: 1.0, x: x, x0: 0.0, x1: 1.0)
              .clamp(0.0, 1.0);
    }

    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final circlePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Path of the complete arc
    path.moveTo(0, size.height); // initial position
    path.quadraticBezierTo(
        // final position with curve
        size.width / 2,
        -size.height,
        size.width,
        size.height);

    // Compute path metrics
    final PathMetrics pathMetrics = path.computeMetrics();

    // Draw continuous part
    final PathMetric firstPathMetric = pathMetrics.first;
    final double continuousLength =
        firstPathMetric.length * nowRatio; // End of continuous part
    canvas.drawPath(
      firstPathMetric.extractPath(0, continuousLength),
      linePaint,
    );

    // Draw dashed arc
    double distance =
        continuousLength; // Start from where the continuous part ends
    double totalLength = firstPathMetric.length;

    while (distance < totalLength) {
      // Draw a line segment
      final double start = distance;
      final double end = distance + dashWidth;

      if (end > totalLength) {
        break; // Avoid drawing beyond the path
      }

      // Cut the path for the current segment
      final Path dashPath = firstPathMetric.extractPath(start, end);
      canvas.drawPath(dashPath, linePaint);

      // Advance by pattern
      distance += dashWidth + dashSpace;
    }

    // Draw circle
    Tangent? tangent = firstPathMetric.getTangentForOffset(continuousLength);

    canvas.drawCircle(tangent!.position, 10, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
