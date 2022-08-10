import 'package:test/test.dart';
import 'package:waitinator/observation.dart';
import 'package:waitinator/eta_state.dart';

void main() {
  test('Serialize empty state', () {
    final EtaState original = EtaState(9);
    final serialized = original.serialize();
    final deserialized = EtaState.deserialize(serialized);

    expect(deserialized, equals(original));
  });

  test('Serialize non-empty observations list', () {
    final original = EtaState(10);
    original.add(Observation(DateTime(2001, 2, 3, 4, 5, 6, 7), 8));
    original.add(Observation(DateTime(2002, 3, 4, 5, 6, 7, 8), 9));

    final serialized = original.serialize();
    final deserialized = EtaState.deserialize(serialized);

    expect(deserialized, equals(original));
  });

  test('Deserialize invalid input', () {
    expect(EtaState.deserialize("invalid"), isNull);
  });
}
