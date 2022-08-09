import 'package:test/test.dart';
import 'package:waitinator/observation.dart';
import 'package:waitinator/observations_serializer.dart';

void main() {
  test('Serialize empty observations list', () {
    final List<Observation> original = [];
    final serialized = serializeObservations(original);
    final deserialized = deserializeObservations(serialized);

    expect(deserialized, equals(original));
  });

  test('Serialize non-empty observations list', () {
    final original = [
      Observation(DateTime(2001, 2, 3, 4, 5, 6, 7), 8),
      Observation(DateTime(2002, 3, 4, 5, 6, 7, 8), 9),
    ];
    final serialized = serializeObservations(original);
    final deserialized = deserializeObservations(serialized);

    expect(deserialized, equals(original));
  });

  test('Deserialize invalid input', () {
    expect(deserializeObservations("invalid"), equals([]));
  });
}
