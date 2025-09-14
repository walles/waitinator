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

  const EtaGraph(this._state, this._estimate, {super.key});

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
    // Pick a color between background and onSurface. "0.25" is from manual
    // testing, I found being that close to the background color looked good for
    // both light and dark UI themes.
    final colorScheme = Theme.of(context).colorScheme;
    final color = Color.lerp(colorScheme.surface, colorScheme.onSurface, 0.25);

    final paint = Paint()
      ..color = color!
      ..style = PaintingStyle.fill;

    // Source of inspiration:
    // https://stackoverflow.com/questions/61359457/how-to-draw-a-filled-polygon
    Path etaPolygon = Path();

    // Start at first observation
    etaPolygon.moveTo(timeToX(_state[0].timestamp, bounds),
        positionToY(_state[0].position, bounds));

    // Go to the other end of that observation
    etaPolygon.lineTo(timeToX(_state[0].timestamp, bounds),
        positionToY(_state[0].position + _state.direction, bounds));

    // Go to the earliest ETA
    etaPolygon.lineTo(timeToX(_estimate.earliest, bounds),
        positionToY(_state.target, bounds));

    // Then to the latest ETA
    etaPolygon.lineTo(
        timeToX(_estimate.latest, bounds), positionToY(_state.target, bounds));

    canvas.drawPath(etaPolygon, paint);
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
    final paint = Paint()
      ..strokeWidth = _lineWidth * 2
      ..color = Theme.of(context).colorScheme.onSurface
      ..style = PaintingStyle.stroke;

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
    final paint = Paint()
      ..strokeWidth = _lineWidth
      ..color = Theme.of(context).colorScheme.onSurface
      ..style = PaintingStyle.stroke;

    // X axis
    canvas.drawLine(Offset(bounds.left, bounds.bottom),
        Offset(bounds.right, bounds.bottom), paint);

    // Y axis
    canvas.drawLine(Offset(bounds.left, bounds.top),
        Offset(bounds.left, bounds.bottom), paint);
  }

  void _paintVerticalEtaLines(Canvas canvas, Rect bounds) {
    final paint = Paint()
      ..strokeWidth = _lineWidth / 3
      ..color = Theme.of(context).colorScheme.primary
      ..style = PaintingStyle.stroke;

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
      color: color ?? Theme.of(context).colorScheme.onSurface,
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
    final etaColor = colorScheme.primary;

    final lowestNumberPainter = _toPainter(lowestNumber.toString(), size);
    final highestNumberPainter = _toPainter(highestNumber.toString(), size);

    final numbersRightmostX =
        max(lowestNumberPainter.width, highestNumberPainter.width);
    final yAxisXCoordinate = numbersRightmostX + _numbersToAxesDistance;

    final firstTimestampPainter =
        _toPainter(Estimate.hhmm.format(_estimate.startedQueueing), size);
    final earliestEtaPainter =
        _toPainter(Estimate.hhmm.format(_estimate.earliest), size, etaColor);
    final latestEtaPainter =
        _toPainter(Estimate.hhmm.format(_estimate.latest), size, etaColor);

    final earliestDMilliseconds =
        _estimate.earliest.difference(_estimate.startedQueueing).inMilliseconds;
    final latestDMilliseconds =
        _estimate.latest.difference(_estimate.startedQueueing).inMilliseconds;
    final earliestEtaFraction = earliestDMilliseconds / latestDMilliseconds;
    final earliestEtaXCoordinate =
        (size.width - yAxisXCoordinate) * earliestEtaFraction;

    final firstTimestampX0 = yAxisXCoordinate;
    final firstTimestampX1 = firstTimestampX0 + firstTimestampPainter.width;
    var firstTimestampY0 = size.height - firstTimestampPainter.height;

    final earliestEtaX0 = earliestEtaXCoordinate - earliestEtaPainter.width / 2;
    final earliestEtaX1 = earliestEtaX0 + earliestEtaPainter.width;
    var earliestEtaY0 = size.height - earliestEtaPainter.height;

    final latestEtaX0 = size.width - latestEtaPainter.width;
    var latestEtaY0 = size.height - latestEtaPainter.height;

    var firstTimestampYAdjustment = 0.0;
    if (firstTimestampX1 >= earliestEtaX0) {
      firstTimestampYAdjustment = earliestEtaPainter.height;
    }

    var latestEtaYAdjustment = 0.0;
    if (earliestEtaX1 >= latestEtaX0) {
      latestEtaYAdjustment = earliestEtaPainter.height;
    }

    if (firstTimestampYAdjustment > 0 || latestEtaYAdjustment > 0) {
      // Make room for two different levels of Y coordinates
      firstTimestampY0 -= earliestEtaPainter.height;
      earliestEtaY0 -= earliestEtaPainter.height;
      latestEtaY0 -= earliestEtaPainter.height;

      // Move either of these that need it down
      firstTimestampY0 += firstTimestampYAdjustment;
      latestEtaY0 += latestEtaYAdjustment;
    }

    firstTimestampPainter.paint(
        canvas, Offset(firstTimestampX0, firstTimestampY0));
    earliestEtaPainter.paint(canvas, Offset(earliestEtaX0, earliestEtaY0));
    latestEtaPainter.paint(canvas, Offset(latestEtaX0, latestEtaY0));

    final timestampsTop =
        [firstTimestampY0, earliestEtaY0, latestEtaY0].reduce(min);

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
