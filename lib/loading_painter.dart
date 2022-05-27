import 'dart:math' as math;
import 'package:flutter/material.dart';

class LoadingPainter extends CustomPainter {
  LoadingPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;
  final double baseLength = 60;
  late double shorterLength = math.sqrt(baseLength * baseLength / 2);
  final double circleRadius = 7;
  final Paint circlePaint = Paint()..color = Colors.white;
  final Paint linePaint = Paint()
    ..color = Colors.white70
    ..strokeWidth = 1.5;

  /// 所有的初始点位
  ///   0  1
  /// 7      2
  /// 6      3
  ///   5  4
  late final List<Offset> originOffsets = <Offset>[
    Offset(shorterLength, 0),
    Offset(baseLength + shorterLength, 0),
    Offset(baseLength + shorterLength * 2, shorterLength),
    Offset(baseLength + shorterLength * 2, baseLength + shorterLength),
    Offset(baseLength + shorterLength, shorterLength * 2 + baseLength),
    Offset(shorterLength, shorterLength * 2 + baseLength),
    Offset(0, baseLength + shorterLength),
    Offset(0, shorterLength),
  ];
  late final List<CustomPointer> pointers = List.generate(
    originOffsets.length,
    (int index) {
      final bool isRotated = index.isEven;
      final int endIndex = isRotated ? index + 1 : index + 3;
      return CustomPointer(
        originOffsets[index],
        originOffsets[endIndex % originOffsets.length],
        isRotated,
      );
    },
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(-(2 * shorterLength + baseLength) / 2,
        -(2 * shorterLength + baseLength) / 2);
    for (int i = 0; i < pointers.length; i++) {
      final CustomPointer pointer = pointers[i];
      canvas.drawLine(
        pointer.current(progress.value),
        pointers[(i + 1) % pointers.length].current(progress.value),
        linePaint,
      );
    }
    for (int i = 0; i < pointers.length; i++) {
      final CustomPointer pointer = pointers[i];
      canvas.drawCircle(
        pointer.current(progress.value),
        circleRadius,
        circlePaint,
      );
    }

    if (progress.value == 1) {
      for (CustomPointer pointer in pointers) {
        pointer.start = pointer.end;
        final int startIndex = originOffsets.indexOf(pointer.start);
        final int endIndex =
            pointer.isRotated ? startIndex + 1 : startIndex + 3;
        pointer.end = originOffsets[endIndex % originOffsets.length];
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CustomPointer {
  CustomPointer(
    this.start,
    this.end,
    this.isRotated,
  );

  Offset start;
  Offset end;
  // 是否是旋转的点（相对应的是直接跳跃的点）
  bool isRotated;

  Offset current(double progress) {
    return Offset.lerp(start, end, progress) ?? end;
  }
}
