import 'dart:developer';
import 'dart:io';

import 'package:database_diagrams/collections/smartline_anchor.dart';
import 'package:database_diagrams/collections/smartline_type.dart';
import 'package:flutter/material.dart';

/// SmartlinePainter.
class SmartlinePainter extends CustomPainter {
  /// Default constructor.
  const SmartlinePainter({
    required this.anchors,
  });

  /// Keys.
  final List<List<SmartlineAnchor>> anchors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final pair in anchors) {
      if (pair.length != 2) {
        continue;
      }

      final first = pair.first.key.currentContext?.findRenderObject() as RenderBox?;
      final second = pair.last.key.currentContext?.findRenderObject() as RenderBox?;

      if (first == null || second == null) {
        continue;
      }

      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2;

      // TODO(Janez): Separate card and attribute lines. Padding gets in the way (inside the card).
      const padding = 15;

      final firstCenter = first.localToGlobal(first.size.center(Offset.zero));
      final secondCenter = second.localToGlobal(second.size.center(Offset.zero));

      final firstLeft = first.localToGlobal(first.size.center(Offset(-padding - first.size.width / 2, 0)));
      final firstRight = first.localToGlobal(first.size.center(Offset(padding + first.size.width / 2, 0)));
      final firstTop = first.localToGlobal(first.size.center(Offset(0, -padding - first.size.height / 2)));
      final firstBottom = first.localToGlobal(first.size.center(Offset(0, padding + first.size.height / 2)));

      final secondLeft = second.localToGlobal(second.size.center(Offset(-padding - second.size.width / 2, 0)));
      final secondRight = second.localToGlobal(second.size.center(Offset(padding + second.size.width / 2, 0)));
      final secondTop = second.localToGlobal(second.size.center(Offset(0, -padding - second.size.height / 2)));
      final secondBottom = second.localToGlobal(second.size.center(Offset(0, padding + second.size.height / 2)));

      /// minimize distance between two points
      if (pair.first.type == SmartlineType.card || pair.last.type == SmartlineType.card) {
        double minDist = double.infinity;
        Offset firstOffset = firstRight;
        Offset secondOffset = secondRight;
        for (final first in [firstRight, firstLeft, firstTop, firstBottom]) {
          for (final second in [secondRight, secondLeft, secondTop, secondBottom]) {
            final distance = (first.dx - second.dx).abs() + (first.dy - second.dy).abs();
            if (distance < minDist) {
              firstOffset = first;
              secondOffset = second;
              minDist = distance;
            }
          }
        }
        canvas.drawLine(firstOffset, secondOffset, paint);
        continue;
      }

      final path = Path();

      const gap = 30;

      /// First left
      if (firstRight.dx < secondLeft.dx) {
        // if vgap or hgap too small
        if ((secondLeft.dx - firstRight.dx).abs() < gap || (firstCenter.dy - secondCenter.dy).abs() < gap) {
          flgs(path, firstRight, secondLeft, canvas, paint);
          continue;
        }

        // if first is above second
        if (firstCenter.dy < secondCenter.dy) {
          log('here');
          flgbfa(path, firstRight, secondLeft, canvas, paint);
          continue;
          // if first is below second
        } else {
          flgbfb(path, firstRight, secondLeft, canvas, paint);
          continue;
        }

        // First right
      } else if (firstLeft.dx > secondRight.dx) {
        // if vgap or hgap too small
        if ((secondRight.dx - firstLeft.dx).abs() < gap || (firstCenter.dy - secondCenter.dy).abs() < gap) {
          frgs(path, secondRight, firstLeft, canvas, paint);
          continue;
        }

        // if first is above second
        if (firstCenter.dy < secondCenter.dy) {
          log('here');
          frgbfa(path, secondRight, firstLeft, canvas, paint);
          continue;
          // if first is below second
        } else {
          frgbfb(path, secondRight, firstLeft, canvas, paint);
          continue;
        }
      }

      continue;
      // first left of second
      if (firstRight.dx < secondLeft.dx) {
        log('first left of second');

        // if horizontal gap too small
        if (secondLeft.dx - firstRight.dx < 30) {
          log('horizontal gap too small');

          flgs(path, firstRight, secondLeft, canvas, paint);
          continue;
        }

        // if vertical gap too small
        if ((firstCenter.dy - secondCenter.dy).abs() < 30) {
          log('vertical gap too small');

          flgs(path, firstRight, secondLeft, canvas, paint);
          continue;
        }

        // first below second
        if (firstCenter.dy > secondCenter.dy) {
          log('first below second');
          // if big enough vertical gap
          if (firstCenter.dy - secondCenter.dy > 30) {
            log('big enough vertical gap');

            path
              ..moveTo(firstRight.dx, firstRight.dy)
              ..lineTo(-15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy)
              ..arcToPoint(
                Offset(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy - 15),
                radius: const Radius.circular(20),
                clockwise: false,
                rotation: 90,
              )
              ..lineTo(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy + 15)
              ..arcToPoint(
                Offset(15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy),
                radius: const Radius.circular(20),
                rotation: 90,
              )
              ..lineTo(secondLeft.dx, secondLeft.dy);
          } else {
            log('not big enough vertical gap');
            final firstRight = first.localToGlobal(first.size.center(Offset(padding + first.size.width / 2, 0)));
            final secondLeft = second.localToGlobal(second.size.center(Offset(-padding - second.size.width / 2, 0)));

            path
              ..moveTo(firstRight.dx, firstRight.dy)
              ..cubicTo(
                firstRight.dx + 100,
                firstRight.dy,
                secondLeft.dx - 100,
                secondLeft.dy,
                secondLeft.dx,
                secondLeft.dy,
              )
              ..lineTo(secondLeft.dx, secondLeft.dy);
          }
          // first above second
        } else {
          log('first above second');

          // if big enough gap
          if (secondCenter.dy - firstCenter.dy > 30) {
            log('big enough vertical gap');

            final firstRight = first.localToGlobal(first.size.center(Offset(padding + first.size.width / 2, 0)));
            final secondLeft = second.localToGlobal(second.size.center(Offset(-padding - second.size.width / 2, 0)));

            path
              ..moveTo(firstRight.dx, firstRight.dy)
              ..lineTo(-15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy)
              ..arcToPoint(
                Offset(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy + 15),
                radius: const Radius.circular(20),
                rotation: 90,
              )
              ..lineTo(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy - 15)
              ..arcToPoint(
                Offset(15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy),
                radius: const Radius.circular(20),
                clockwise: false,
                rotation: 90,
              )
              ..lineTo(secondLeft.dx, secondLeft.dy);
          } else {
            log('not big enough vertical gap');
            final firstRight = first.localToGlobal(first.size.center(Offset(padding + first.size.width / 2, 0)));
            final secondLeft = second.localToGlobal(second.size.center(Offset(-padding - second.size.width / 2, 0)));

            path
              ..moveTo(firstRight.dx, firstRight.dy)
              ..cubicTo(
                firstRight.dx + 100,
                firstRight.dy,
                secondLeft.dx - 100,
                secondLeft.dy,
                secondLeft.dx,
                secondLeft.dy,
              )
              ..lineTo(secondLeft.dx, secondLeft.dy);
          }
        }
        // first right of second
      } else {
        log('first right of second');
      }
    }
  }

  @override
  bool shouldRepaint(covariant SmartlinePainter oldDelegate) => true;

  /// First left of second, gap too small.
  void flgs(Path path, Offset firstRight, Offset secondLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(firstRight.dx, firstRight.dy)
      ..cubicTo(
        firstRight.dx + 10,
        firstRight.dy,
        secondLeft.dx - 10,
        secondLeft.dy,
        secondLeft.dx,
        secondLeft.dy,
      )
      ..lineTo(secondLeft.dx, secondLeft.dy);
    canvas.drawPath(path, paint);
  }

  /// First left of second, first above second, gap big enough.
  void flgbfa(Path path, Offset firstRight, Offset secondLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(firstRight.dx, firstRight.dy)
      ..lineTo(-15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy)
      ..arcToPoint(
        Offset(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy + 15),
        radius: const Radius.circular(20),
        rotation: 90,
      )
      ..lineTo(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy - 15)
      ..arcToPoint(
        Offset(15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy),
        radius: const Radius.circular(20),
        clockwise: false,
        rotation: 90,
      )
      ..lineTo(secondLeft.dx, secondLeft.dy);
    canvas.drawPath(path, paint);
  }

  /// First left of second, first below second, gap big enough.
  void flgbfb(Path path, Offset firstRight, Offset secondLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(firstRight.dx, firstRight.dy)
      ..lineTo(-15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy)
      ..arcToPoint(
        Offset(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, firstRight.dy - 15),
        radius: const Radius.circular(20),
        clockwise: false,
        rotation: 90,
      )
      ..lineTo(firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy + 15)
      ..arcToPoint(
        Offset(15 + firstRight.dx + (secondLeft.dx - firstRight.dx) / 2, secondLeft.dy),
        radius: const Radius.circular(20),
        rotation: 90,
      )
      ..lineTo(secondLeft.dx, secondLeft.dy);
    canvas.drawPath(path, paint);
  }

  /// First right of second, gap too small.
  void frgs(Path path, Offset secondRight, Offset firstLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(secondRight.dx, secondRight.dy)
      ..cubicTo(
        secondRight.dx + 10,
        secondRight.dy,
        firstLeft.dx - 10,
        firstLeft.dy,
        firstLeft.dx,
        firstLeft.dy,
      )
      ..lineTo(firstLeft.dx, firstLeft.dy);
    canvas.drawPath(path, paint);
  }

  /// First right of second, first above second, gap big enough.
  void frgbfa(Path path, Offset secondRight, Offset firstLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(secondRight.dx, secondRight.dy)
      ..lineTo(-15 + secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, secondRight.dy)
      ..arcToPoint(
        Offset(secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, secondRight.dy - 15),
        radius: const Radius.circular(20),
        clockwise: false,
        rotation: 90,
      )
      ..lineTo(secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, firstLeft.dy + 15)
      ..arcToPoint(
        Offset(15 + secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, firstLeft.dy),
        radius: const Radius.circular(20),
        rotation: 90,
      )
      ..lineTo(firstLeft.dx, firstLeft.dy);
    canvas.drawPath(path, paint);
  }

  /// First right of second, first below second, gap big enough.
  void frgbfb(Path path, Offset secondRight, Offset firstLeft, Canvas canvas, Paint paint) {
    path
      ..moveTo(secondRight.dx, secondRight.dy)
      ..lineTo(-15 + secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, secondRight.dy)
      ..arcToPoint(
        Offset(secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, secondRight.dy + 15),
        radius: const Radius.circular(20),
        rotation: 90,
      )
      ..lineTo(secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, firstLeft.dy - 15)
      ..arcToPoint(
        Offset(15 + secondRight.dx + (firstLeft.dx - secondRight.dx) / 2, firstLeft.dy),
        radius: const Radius.circular(20),
        clockwise: false,
        rotation: 90,
      )
      ..lineTo(firstLeft.dx, firstLeft.dy);
    canvas.drawPath(path, paint);
  }
}
