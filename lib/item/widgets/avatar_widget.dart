import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    final scaleFactor = MediaQuery.textScalerOf(context).textScaleFactor;
    final pixelSize = scaleFactor * 2;
    final avatarSize = pixelSize * 7;

    return CustomPaint(
      painter: _AvatarPainter(
        username: username,
        pixelSize: pixelSize,
        scaleFactor: scaleFactor,
      ),
      size: Size.square(avatarSize),
    );
  }
}

// Algorithm based on https://news.ycombinator.com/item?id=30668207 by tomxor.
class _AvatarPainter extends CustomPainter with EquatableMixin {
  const _AvatarPainter({
    required this.username,
    required this.pixelSize,
    this.scaleFactor = 1,
  });

  final String username;
  final double pixelSize;
  final double scaleFactor;

  @override
  void paint(Canvas canvas, Size size) {
    const seedSteps = 28;
    final offset = Offset(scaleFactor, scaleFactor);
    final points = <Offset>[];
    final paint = Paint()..strokeWidth = pixelSize;
    var seed = 1;

    for (var i = seedSteps + username.length - 1; i >= seedSteps; i--) {
      seed = _xorShift32(seed);
      seed += username.codeUnitAt(i - seedSteps);
    }

    paint.color = Color(seed >> 8 | 0xff000000);

    for (var i = seedSteps - 1; i >= 0; i--) {
      seed = _xorShift32(seed);

      final x = i & 3;
      final y = i >> 2;

      if (seed.toUnsigned(32) >> seedSteps + 1 > x * x / 3 + y / 2) {
        points
          ..add(Offset(pixelSize * 3 + pixelSize * x, pixelSize * y) + offset)
          ..add(Offset(pixelSize * 3 - pixelSize * x, pixelSize * y) + offset);
      }
    }

    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  @override
  List<Object?> get props => [
        username,
        pixelSize,
        scaleFactor,
      ];

  static int _xorShift32(int number) {
    var result = number;
    result ^= result << 13;
    result ^= result.toUnsigned(32) >> 17;
    result ^= result << 5;
    return result;
  }
}
