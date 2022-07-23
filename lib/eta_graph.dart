import 'package:flutter/material.dart';

class EtaGraph extends StatefulWidget {
  const EtaGraph({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EtaGraph();
  }
}

class _EtaGraph extends State<EtaGraph> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EtaGraphPainter(context),
    );
  }
}

class _EtaGraphPainter extends CustomPainter {
  final BuildContext context;

  _EtaGraphPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.strokeWidth = 10;
    paint.color = Theme.of(context).primaryColorLight;
    paint.style = PaintingStyle.stroke;

    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // FIXME: How do we know?
    return false;
  }
}
