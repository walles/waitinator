import 'package:meta/meta.dart';
import 'package:waitinator/observation.dart';

/// Persistent list of `Observation`s and a target
class EtaState {
  final int _target;
  final List<Observation> _observations = [];

  @visibleForTesting
  EtaState(int target) : _target = target;

  int get target {
    return _target;
  }

  void add(Observation observation) {
    _observations.add(observation);
  }

  String serialize() {
    String serialized = "$_target ";

    for (final observation in _observations) {
      serialized += observation.position.toString();
      serialized += " ";
      serialized += observation.timestamp.millisecondsSinceEpoch.toString();
    }

    return serialized;
  }

  /// This function will return null on any parse errors.
  static EtaState? deserialize(String serialized) {
    final strings = serialized.split(" ");
    if (strings.length % 2 != 1) {
      // First entry is the target, followed by observation / timestamp pairs.
      return null;
    }

    List<int> numbers = [];
    for (final string in strings) {
      final number = int.tryParse(string);
      if (number == null || number.isNaN) {
        return null;
      }

      numbers.add(number);
    }

    final returnMe = EtaState(numbers[0]);
    for (int i = 1; i < numbers.length; i += 2) {
      final position = numbers[i];
      final timestamp = DateTime.fromMillisecondsSinceEpoch(numbers[i + 1]);
      returnMe._observations.add(Observation(timestamp, position));
    }

    return returnMe;
  }
}
