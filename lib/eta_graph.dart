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

    _paintQueueNumbers(canvas, size);

    final paint = Paint();
    paint.strokeWidth = 10;
    paint.color = Theme.of(context).colorScheme.onBackground;
    paint.style = PaintingStyle.stroke;
  }

  TextPainter _toPainter(String text, Size size) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onBackground,
      fontSize: 15, // FIXME: What is a good number?
    );

    final textSpan = TextSpan(
      text: text,
      style: style,
    );
    final painter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    painter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    return painter;
  }

  void _paintQueueNumbers(Canvas canvas, Size size) {
    // FIXME: Paint the first number
    final firstNumber = _observations.first.position;
    final painter = _toPainter(firstNumber.toString(), size);
    painter.paint(canvas, Offset(0, size.height - painter.height));

    // FIXME: Paint the last number
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // FIXME: How do we know?
    return false;
  }
}
