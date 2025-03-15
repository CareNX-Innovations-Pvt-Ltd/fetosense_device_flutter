import 'package:flutter/material.dart';

class NSTGraphView extends StatefulWidget {
  const NSTGraphView({super.key});

  @override
  _NSTGraphViewState createState() => _NSTGraphViewState();
}

class _NSTGraphViewState extends State<NSTGraphView> {
  double touchStart = 0;
  int touchInitialStartIndex = 0;
  int offset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _touchStart(details.localPosition.dx),
      onPanUpdate: (details) => _touchMove(details.localPosition.dx),
      onPanEnd: (_) => _touchEnd(),
      child: CustomPaint(
        size: Size.infinite,
        painter: NSTGraphPainter(offset),
      ),
    );
  }

  void _touchStart(double x) {
    touchStart = x;
    touchInitialStartIndex = offset;
  }

  void _touchMove(double x) {
    setState(() {
      offset = (touchInitialStartIndex + (touchStart - x))
          .toInt()
          .clamp(0, double.maxFinite.toInt());
    });
  }

  void _touchEnd() {}
}

class NSTGraphPainter extends CustomPainter {
  final int offset;

  NSTGraphPainter(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    Paint axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    Paint gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    canvas.drawLine(Offset(50, size.height - 50),
        Offset(size.width - 50, size.height - 50), axisPaint);
    canvas.drawLine(
        const Offset(50, 50), Offset(50, size.height - 50), axisPaint);

    for (double i = 50; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 50), Offset(i, size.height - 50), gridPaint);
    }
    for (double i = 50; i < size.height; i += 50) {
      canvas.drawLine(Offset(50, i), Offset(size.width - 50, i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
