import 'estimate.dart';
import 'observation.dart';

Estimate estimate(List<Observation> observations, int target) {
  // FIXME: Compute this estimate, don't just hardcode it a bit into the future
  return Estimate(
      observations[0].timestamp,
      DateTime.now().add(const Duration(minutes: 13)),
      DateTime.now().add(const Duration(minutes: 23)),
      target);
}
