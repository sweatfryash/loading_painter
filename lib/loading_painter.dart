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

  /// 所有的点位
  /// [originOffsets]相当于地图，内容是不变的
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

  /// 初始化每个pointer的起点终点
  /// 设定：index为偶数的每次移动index+1,index为奇数的每次移动index+3
  /// 使用[%]模运算达到循环链表的效果，改变pointer对象对应的值，一直循环下去
  /// 初始    0   1      一次后    5   0
  /// 初始  7       2    一次后  6       7
  /// 初始  6       3    一次后  3       2
  /// 初始    5   4      一次后    4   1
  /// 以此类推
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

  /// 根据[progress]得到实时的位置。[progress]的值不断变化，就形成动画了
  Offset realtimeOffsetOfPointer(CustomPointer customPointer) =>
      Offset.lerp(customPointer.start, customPointer.end, progress.value) ??
      customPointer.end;

  @override
  void paint(Canvas canvas, Size size) {
    // 往左上方移动，让整体显示效果居中
    canvas.translate(-(2 * shorterLength + baseLength) / 2,
        -(2 * shorterLength + baseLength) / 2);
    // 先画线
    for (int i = 0; i < pointers.length; i++) {
      final CustomPointer pointer = pointers[i];
      canvas.drawLine(
        realtimeOffsetOfPointer(pointer),
        realtimeOffsetOfPointer(pointers[(i + 1) % pointers.length]),
        linePaint,
      );
    }
    for (final CustomPointer pointer in pointers) {
      canvas.drawCircle(
        realtimeOffsetOfPointer(pointer),
        circleRadius,
        circlePaint,
      );
    }
    // 重新设定每个pointer的起点终点
    // 使用[%]模运算达到循环链表的效果，改变pointer对象对应的属性的值，一直循环下去
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
}
