class Observation {
  final DateTime timestamp;
  final int position;

  Observation(this.timestamp, this.position);

  @override
  String toString() {
    return "{ pos=$position time=$timestamp }";
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != Observation) {
      return false;
    }

    Observation otherObservation = other as Observation;
    if (otherObservation.position != position) {
      return false;
    }
    if (otherObservation.timestamp != timestamp) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode {
    return position.hashCode ^ timestamp.hashCode;
  }
}
