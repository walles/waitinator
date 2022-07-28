import 'dart:math';

import 'package:flutter/material.dart';

import 'estimate.dart';
import 'observation.dart';

const _numbersToAxesDistance = 5.0;
const _lineWidth = 2.0;

class EtaGraph extends StatefulWidget {
  final List<Observation> _observations;
  final Estimate _estimate;

  const EtaGraph(this._observations, this._estimate, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EtaGraph();
  }
}

class _EtaGraph extends State<EtaGraph> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
          _EtaGraphPainter(context, widget._observations, widget._estimate),
    );
  }
}

class _EtaGraphPainter extends CustomPainter {
  final List<Observation> _observations;
  final Estimate _estimate;

  final BuildContext context;

  _EtaGraphPainter(
      this.context, List<Observation> observations, Estimate estimate)
      : _observations = observations,
        _estimate = estimate;

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

    final bounds = _paintLabels(canvas, size);

    _paintAxes(canvas, bounds);

    // FIXME: Paint all samples. If the sample is "23", it should be painted as
    // a line from 23 to 24 at the right timestamp, to illustrate that we don't
    // know where in that interval the actual value is.

    // FIXME: Paint a vertical line at "now"? This would require us to regularly
    // update our drawing.
  }

  void _paintAxes(Canvas canvas, Rect bounds) {
    final paint = Paint();
    paint.strokeWidth = _lineWidth;
    paint.color = Theme.of(context).colorScheme.onBackground;
    paint.style = PaintingStyle.stroke;

    // X axis
    canvas.drawLine(Offset(bounds.left, bounds.bottom),
        Offset(bounds.right, bounds.bottom), paint);

    // Y axis
    canvas.drawLine(Offset(bounds.left, bounds.top),
        Offset(bounds.left, bounds.bottom), paint);
  }

  TextPainter _toPainter(String text, Size size, [Color? color]) {
    final style = TextStyle(
      color: color ??  Theme.of(context).colorScheme.onBackground,
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

  /// Returns the graph bounds after making room for the labels
  Rect _paintLabels(Canvas canvas, Size size) {
    final colorScheme = Theme.of(context).colorScheme;
    final forecastColor = colorScheme.primary;

    final firstTimestampPainter =
        _toPainter(Estimate.hhmm.format(_estimate.startedQueueing), size);
    final earliestEtaTimestampPainter =
        _toPainter(Estimate.hhmm.format(_estimate.earliest), size, forecastColor);
    final latestEtaTimestampPainter =
        _toPainter(Estimate.hhmm.format(_estimate.latest), size, forecastColor);

    final firstNumberPainter =
        _toPainter(_observations.first.position.toString(), size);
    final lastNumberPainter =
        _toPainter(_observations.last.position.toString(), size);

    final numbersRightmostX =
        max(firstNumberPainter.width, lastNumberPainter.width);
    final yAxisXCoordinate = numbersRightmostX + _numbersToAxesDistance;

    firstTimestampPainter.paint(canvas,
        Offset(yAxisXCoordinate, size.height - firstTimestampPainter.height));

    latestEtaTimestampPainter.paint(
        canvas,
        Offset(size.width - latestEtaTimestampPainter.width,
            size.height - latestEtaTimestampPainter.height));

    final earliestDMilliseconds =
        _estimate.earliest.difference(_estimate.startedQueueing).inMilliseconds;
    final latestDMilliseconds =
        _estimate.latest.difference(_estimate.startedQueueing).inMilliseconds;
    final earliestEtaFraction = earliestDMilliseconds / latestDMilliseconds;
    final earliestEtaXCoordinate =
        (size.width - yAxisXCoordinate) * earliestEtaFraction;

    // FIXME: Should we right align this label? Center it? Something else?
    // FIXME: Draw this below the latest timestamp if needed to prevent them
    //        from overlapping
    earliestEtaTimestampPainter.paint(
        canvas,
        Offset(earliestEtaXCoordinate,
            size.height - earliestEtaTimestampPainter.height));

    // FIXME: If we draw the two ETAs at different Y coordinates this
    // calculation will have to be updated
    final timestampsTop = size.height -
        max(firstTimestampPainter.height, latestEtaTimestampPainter.height);

    final xAxisYCoordinate = timestampsTop - _numbersToAxesDistance;

    firstNumberPainter.paint(
        canvas, Offset(numbersRightmostX - firstNumberPainter.width, 0));
    lastNumberPainter.paint(
        canvas,
        Offset(numbersRightmostX - lastNumberPainter.width,
            xAxisYCoordinate - lastNumberPainter.height));

    return Rect.fromLTRB(yAxisXCoordinate, 0, size.width, xAxisYCoordinate);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // FIXME: How do we know?
    return false;
  }
}
