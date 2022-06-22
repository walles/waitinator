import 'package:test/test.dart';
import 'package:waitinator/compute_estimate.dart';
import 'package:waitinator/observation.dart';

void main() {
  test('_getLastObservation() happy case', () {
    expect(
        getLastObservation([
          Observation(DateTime.now(), 1),
          Observation(DateTime.now(), 2)
        ])!
            .position,
        equals(2));
  });

  test('_getLastObservation() on an empty list returns null', () {
    expect(getLastObservation([]), isNull);
  });

  test('_getLastObservation() on single entry list returns null', () {
    expect(getLastObservation([Observation(DateTime.now(), 1)]), isNull);
  });

  test(
      '_getLastObservation() with multiple same-numbered final entries returns the first one of those',
      () {
    var correctMarker = DateTime.fromMillisecondsSinceEpoch(1234);
    expect(
        getLastObservation([
          Observation(DateTime.now(), 1),
          Observation(correctMarker, 2),
          Observation(DateTime.now(), 2),
        ])!
            .timestamp,
        equals(correctMarker));
  });

  test(
      '_getLastObservation() with all entries containing the same number returns null',
      () {
    expect(
        getLastObservation([
          Observation(DateTime.now(), 1),
          Observation(DateTime.now(), 1),
        ]),
        isNull);
  });
}
