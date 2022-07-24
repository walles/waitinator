import 'dart:math';

import 'package:flutter/material.dart';

import 'observation.dart';

const _numbersToAxesDistance = 5.0;

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

    // FIXME: Paint the ETA polygon with corners at:
    // * X=[Earliest ETA], Y=[Target number]
    // * X=[Latest ETA], Y=[Target number]
    // * X=[Earliest timestamp], Y=[Top of the first sample]
    // * X=[Earliest timestamp], Y=[Bottom of the first sample]

    // FIXME: Draw a vertical line in the graph at the earliest ETA
    // FIXME: Draw a vertical line in the graph at the latest ETA

    _paintLabels(canvas, size);

    // FIXME: Paint the axes

    // FIXME: Paint all samples. If the sample is "23", it should be painted as
    // a line from 23 to 24 at the right timestamp, to illustrate that we don't
    // know where in that interval the actual value is.

    // FIXME: Paint a vertical line at "now"? This would require us to regularly
    // update our drawing.
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

  void _paintLabels(Canvas canvas, Size size) {
    final firstTimestampPainter = _toPainter('FIXME1'.toString(), size);
    final earliestEtaTimestampPainter = _toPainter('FIXME2'.toString(), size);
    final latestEtaTimestampPainter = _toPainter('FIXME3'.toString(), size);

    final firstNumberPainter =
        _toPainter(_observations.first.position.toString(), size);
    final lastNumberPainter =
        _toPainter(_observations.last.position.toString(), size);

    final numbersRightmostX =
        max(firstNumberPainter.width, lastNumberPainter.width);
    final xAxisXCoordinate = numbersRightmostX + _numbersToAxesDistance;

    firstTimestampPainter.paint(canvas,
        Offset(xAxisXCoordinate, size.height - firstTimestampPainter.height));

    // FIXME: earliestEtaTimestampPainter.paint(canvas, the right place)

    latestEtaTimestampPainter.paint(
        canvas,
        Offset(size.width - latestEtaTimestampPainter.width,
            size.height - latestEtaTimestampPainter.height));

    // FIXME: If we draw the two ETAs at different Y coordinates this
    // calculation will have to be updated
    final timestampsTop = size.height -
        max(firstTimestampPainter.height, latestEtaTimestampPainter.height);

    final yAxisYCoordinate = timestampsTop - _numbersToAxesDistance;

    firstNumberPainter.paint(
        canvas,
        Offset(numbersRightmostX - firstNumberPainter.width,
            firstNumberPainter.height));
    lastNumberPainter.paint(
        canvas,
        Offset(numbersRightmostX - lastNumberPainter.width,
            yAxisYCoordinate - lastNumberPainter.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // FIXME: How do we know?
    return false;
  }
}
