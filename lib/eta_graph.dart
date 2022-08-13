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

  int get lowestNumber {
    return min(_state[0].position, _state.target);
  }

  int get highestNumber {
    return max(_state[0].position, _state.target);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = _paintLabels(canvas, size);

    _paintEtaPolygon(canvas, bounds);

    _paintAxes(canvas, bounds);
    _paintVerticalEtaLines(canvas, bounds);
    _paintSamples(canvas, bounds);

    // FIXME: Paint a vertical line at "now"? This would require us to regularly
    // update our drawing.
  }

  void _paintEtaPolygon(Canvas canvas, Rect bounds) {
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.onBackground
      ..style = PaintingStyle.fill;

    // Source of inspiration:
    // https://stackoverflow.com/questions/61359457/how-to-draw-a-filled-polygon
    Path etaPolygon = Path();

    // FIXME: Add code here
  }

  double timeToX(DateTime timestamp, Rect bounds) {
    final widthMilliseconds =
        _estimate.latest.difference(_estimate.startedQueueing).inMilliseconds;

    final xMilliseconds =
        timestamp.difference(_estimate.startedQueueing).inMilliseconds;
    final xFraction = xMilliseconds / widthMilliseconds;
    final xCoordinate = bounds.left + bounds.width * xFraction;

    return xCoordinate;
  }

  double positionToY(int position, Rect bounds) {
    final heightPositions = highestNumber - lowestNumber;

    final yFraction = (position - lowestNumber) / heightPositions;
    final yCoordinate = bounds.bottom - bounds.height * yFraction;

    return yCoordinate;
  }

  void _paintSamples(Canvas canvas, Rect bounds) {
    final paint = Paint();
    paint.strokeWidth = _lineWidth * 2;
    paint.color = Theme.of(context).colorScheme.onBackground;
    paint.style = PaintingStyle.stroke;

    for (Observation observation in _state.observations) {
      final xCoordinate = timeToX(observation.timestamp, bounds);
      final y0 = positionToY(observation.position, bounds);

      // Compute y1 as well, which is y0 plus one step towards the goal. To
      // illustrate we can't know whether we just switched into this
      // observation, or whether we are just about to switch to the next.
      final y1 = positionToY(observation.position + _state.direction, bounds);

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

    final earliestEtaXCoordinate = timeToX(_estimate.earliest, bounds);
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

    final lowestNumberPainter = _toPainter(lowestNumber.toString(), size);
    final highestNumberPainter = _toPainter(highestNumber.toString(), size);

    final numbersRightmostX =
        max(lowestNumberPainter.width, highestNumberPainter.width);
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

    lowestNumberPainter.paint(
        canvas,
        Offset(numbersRightmostX - lowestNumberPainter.width,
            xAxisYCoordinate - lowestNumberPainter.height));
    highestNumberPainter.paint(
        canvas, Offset(numbersRightmostX - highestNumberPainter.width, 0));

    return Rect.fromLTRB(yAxisXCoordinate, 0, size.width, xAxisYCoordinate);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // FIXME: How do we know?
    return false;
  }
}
