import 'dart:math';

import 'package:flutter/material.dart';
import 'package:waitinator/eta_state.dart';

import 'estimate.dart';
import 'observation.dart';

const _numbersToAxesDistance = 5.0;
const _lineWidth = 2.0;

class EtaGraph extends StatefulWidget {
  final EtaState _state;
  final Estimate _estimate;

  const EtaGraph(this._state, this._estimate, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EtaGraph();
  }
}

class _EtaGraph extends State<EtaGraph> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EtaGraphPainter(context, widget._state, widget._estimate),
    );
  }
}

class _EtaGraphPainter extends CustomPainter {
  final EtaState _state;
  final Estimate _estimate;

  final BuildContext context;

  _EtaGraphPainter(this.context, EtaState state, Estimate estimate)
      : _state = state,
        _estimate = estimate;

  @override
  void paint(Canvas canvas, Size size) {
    // FIXME: Paint the ETA polygon with corners at:
    // * X=[Earliest ETA], Y=[Target number]
    // * X=[Latest ETA], Y=[Target number]
    // * X=[Earliest timestamp], Y=[Top of the first sample]
    // * X=[Earliest timestamp], Y=[Bottom of the first sample]

    // FIXME: Draw a vertical line in the graph at the earliest ETA
    // FIXME: Draw a vertical line in the graph at the latest ETA

    final bounds = _paintLabels(canvas, size);

    _paintAxes(canvas, bounds);
    _paintVerticalEtaLines(canvas, bounds);

    // FIXME: Paint all samples. If the sample is "23", it should be painted as
    // a line from 23 to 24 at the right timestamp, to illustrate that we don't
    // know where in that interval the actual value is.
    _paintSamples(canvas, bounds);

    // FIXME: Paint a vertical line at "now"? This would require us to regularly
    // update our drawing.
  }

  void _paintSamples(Canvas canvas, Rect bounds) {
    // FIXME: This method is mostly broken. Test it both counting up and down.

    final paint = Paint();
    paint.strokeWidth = _lineWidth;
    paint.color = Theme.of(context).colorScheme.onBackground;
    paint.style = PaintingStyle.stroke;

    final latestDMilliseconds =
        _estimate.latest.difference(_estimate.startedQueueing).inMilliseconds;

    for (Observation observation in _state.observations) {
      final dMilliseconds = observation.timestamp
          .difference(_estimate.startedQueueing)
          .inMilliseconds;
      final xFraction = dMilliseconds / latestDMilliseconds;
      final xCoordinate = bounds.left + bounds.width * xFraction;

      final yHeight = _state[0].position - _state.target;
      final yFraction0 = observation.position / yHeight;
      final y0 = bounds.height * yFraction0;

      // Compute y1 as well, which is y0 plus one step towards the goal. To
      // illustrate we can't know whether we just switched into this
      // observation, or whether we are just about to switch to the next.
      final yFraction1 = (observation.position + _state.direction) / yHeight;
      final y1 = bounds.height * yFraction1;

      canvas.drawLine(Offset(xCoordinate, y0), Offset(xCoordinate, y1), paint);
    }
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

  void _paintVerticalEtaLines(Canvas canvas, Rect bounds) {
    // FIXME: Make these lines dashed? https://stackoverflow.com/a/71099304
    final paint = Paint();
    paint.strokeWidth = _lineWidth / 3;
    paint.color = Theme.of(context).colorScheme.primary;
    paint.style = PaintingStyle.stroke;

    final top = bounds.top;
    final bottom = bounds.bottom + _numbersToAxesDistance;

    // FIXME: Computing the earliest X coordinate is also done in
    // _paintLabels(), extract into a function?
    final earliestDMilliseconds =
        _estimate.earliest.difference(_estimate.startedQueueing).inMilliseconds;
    final latestDMilliseconds =
        _estimate.latest.difference(_estimate.startedQueueing).inMilliseconds;
    final earliestEtaFraction = earliestDMilliseconds / latestDMilliseconds;
    final earliestEtaXCoordinate = bounds.width * earliestEtaFraction;

    canvas.drawLine(Offset(earliestEtaXCoordinate, top),
        Offset(earliestEtaXCoordinate, bottom), paint);

    canvas.drawLine(
        Offset(bounds.right, top), Offset(bounds.right, bottom), paint);
  }

  TextPainter _toPainter(String text, Size size, [Color? color]) {
    final style = TextStyle(
      color: color ?? Theme.of(context).colorScheme.onBackground,
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
    final earliestEtaTimestampPainter = _toPainter(
        Estimate.hhmm.format(_estimate.earliest), size, forecastColor);
    final latestEtaTimestampPainter =
        _toPainter(Estimate.hhmm.format(_estimate.latest), size, forecastColor);

    final firstNumberPainter = _toPainter(_state[0].position.toString(), size);
    final lastNumberPainter = _toPainter(_state.target.toString(), size);

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
        Offset(earliestEtaXCoordinate - earliestEtaTimestampPainter.width / 2,
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
