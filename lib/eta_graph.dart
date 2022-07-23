import 'package:flutter/material.dart';

import 'observation.dart';

class EtaGraph extends StatefulWidget {
  final List<Observation> _observations;

  const EtaGraph(this._observations, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EtaGraph();
  }
}

class _EtaGraph extends State<EtaGraph> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EtaGraphPainter(context, widget._observations),
    );
  }
}

class _EtaGraphPainter extends CustomPainter {
  final List<Observation> _observations;

  final BuildContext context;

  _EtaGraphPainter(this.context, List<Observation> observations)
      : _observations = observations;

  @override
  void paint(Canvas canvas, Size size) {
    assert(_observations.isNotEmpty);

    final paint = Paint();
    paint.strokeWidth = 10;
    paint.color = Theme.of(context).colorScheme.onBackground;
    paint.style = PaintingStyle.stroke;

    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // FIXME: How do we know?
    return false;
  }
}
