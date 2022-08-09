import 'package:meta/meta.dart';
import 'package:waitinator/observation.dart';

@visibleForTesting
String serializeObservations(List<Observation> observations) {
  String serialized = "";

  for (final observation in observations) {
    if (serialized.isNotEmpty) {
      serialized += " ";
    }

    serialized += observation.position.toString();
    serialized += " ";
    serialized += observation.timestamp.millisecondsSinceEpoch.toString();
  }

  return serialized;
}

/// This function will return an empty list on any parse errors.
@visibleForTesting
List<Observation> deserializeObservations(String serialized) {
  final strings = serialized.split(" ");
  if (strings.length % 2 != 0) {
    // We need an even number of strings, since each entry consists of two
    // strings.
    return [];
  }

  List<int> numbers = [];
  for (final string in strings) {
    final number = int.parse(string);
    if (number.isNaN) {
      return [];
    }

    numbers.add(number);
  }

  List<Observation> result = [];
  for (int i = 0; i < numbers.length; i += 2) {
    final position = numbers[i];
    final timestamp = DateTime.fromMillisecondsSinceEpoch(numbers[i + 1]);
    result.add(Observation(timestamp, position));
  }

  return result;
}
