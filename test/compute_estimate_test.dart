import 'package:test/test.dart';
import 'package:waitinator/compute_estimate.dart';
import 'package:waitinator/eta_state.dart';
import 'package:waitinator/observation.dart';

void main() {
  test('_getLastObservation() happy case', () {
    final state = EtaState(55);
    state.add(Observation(DateTime.now(), 1));
    state.add(Observation(DateTime.now(), 2));

    expect(getLastObservation(state)!.position, equals(2));
  });

  test('_getLastObservation() on an empty list returns null', () {
    expect(getLastObservation(EtaState(55)), isNull);
  });

  test('_getLastObservation() on single entry list returns null', () {
    final state = EtaState(55);
    state.add(Observation(DateTime.now(), 1));

    expect(getLastObservation(state), isNull);
  });

  test(
      '_getLastObservation() with multiple same-numbered final entries returns the earliest one of those',
      () {
    var correctMarker = DateTime.fromMillisecondsSinceEpoch(1234);
    final state = EtaState(55);
    state.add(Observation(DateTime.now(), 1));
    state.add(Observation(correctMarker, 2));
    state.add(Observation(DateTime.now(), 2));

    expect(getLastObservation(state)!.timestamp, equals(correctMarker));
  });

  test(
      '_getLastObservation() with all entries containing the same number returns null',
      () {
    final state = EtaState(55);
    state.add(Observation(DateTime.now(), 1));
    state.add(Observation(DateTime.now(), 1));

    expect(getLastObservation(state), isNull);
  });
}
