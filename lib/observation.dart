class Observation {
  final DateTime timestamp;
  final int position;

  Observation(this.timestamp, this.position);

  @override
  String toString() {
    return "{ pos=$position time=$timestamp }";
  }
}
