import 'package:flutter/foundation.dart';
import 'package:waitinator/observation.dart';

/// Persistent list of `Observation`s and a target
class EtaState {
  final int target;
  final List<Observation> _observations = [];

  EtaState(this.target);

  Iterable<Observation> get reversed {
    return _observations.reversed;
  }

  Observation get last {
    return _observations.last;
  }

  void add(Observation observation) {
    _observations.add(observation);
  }

  int get length {
    return _observations.length;
  }

  Observation operator [](int index) {
    return _observations[index];
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != EtaState) {
      return false;
    }

    final otherEtaState = other as EtaState;
    if (otherEtaState.target != target) {
      return false;
    }
    if (!listEquals(otherEtaState._observations, _observations)) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode {
    int returnMe = target.hashCode;
    for (final observation in _observations) {
      returnMe ^= observation.hashCode;
    }
    return returnMe;
  }

  @override
  String toString() {
    return "{ target=$target observations={ ${_observations.join(", ")} } }";
  }

  String serialize() {
    String serialized = "$target";

    for (final observation in _observations) {
      serialized += " ";
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
