import 'package:test/test.dart';
import 'package:waitinator/estimate_renderer.dart';

void main() {
  test('Estimate.toString() nicely renders an upcoming ETA', () {
    final start = DateTime.parse("2020-02-02T12:34:56");
    final now = DateTime.parse("2020-02-02T12:35:56");
    final earliest = DateTime.parse("2020-02-02T12:39:56");
    final latest = DateTime.parse("2020-02-02T12:42:56");

    final estimate = EstimateRenderer(start, earliest, latest, 200,
        Duration(seconds: 33), Duration(seconds: 44),
        now: now);
    expect(
        estimate.toString(),
        equals('You will get to 200 in\n'
            'between 4min, at 12:39\n'
            'and 7min, at 12:42\n'
            'for a total queue time of 5min-8min.\n'
            'Iteration time is 33s-44s.'));
  });

  test("Estimate.toString() nicely renders when we're inside of the ETA zone",
      () {
    final start = DateTime.parse("2020-02-02T12:34:56");
    final earliest = DateTime.parse("2020-02-02T12:39:56");
    final now = DateTime.parse("2020-02-02T12:40:56");
    final latest = DateTime.parse("2020-02-02T12:42:56");

    final estimate = EstimateRenderer(start, earliest, latest, 200,
        Duration(seconds: 33), Duration(seconds: 44),
        now: now);
    expect(
        estimate.toString(),
        equals('You will get to 200 in\n'
            '2min, at 12:42\n'
            'for a total queue time of 8min.\n'
            'Iteration time is 33s-44s.'));
  });

  test("Estimate.toString() nicely renders when we're after the ETA", () {
    final start = DateTime.parse("2020-02-02T12:34:56");
    final earliest = DateTime.parse("2020-02-02T12:39:56");
    final latest = DateTime.parse("2020-02-02T12:42:56");
    final now = DateTime.parse("2020-02-02T12:44:56");

    final estimate = EstimateRenderer(start, earliest, latest, 200,
        Duration(seconds: 33), Duration(seconds: 44),
        now: now);
    expect(
        estimate.toString(),
        equals('You should have arrived at 200\n'
            '2min ago, at 12:42\n'
            'for a total queue time of 8min.\n'
            'Iteration time was 33s-44s.'));
  });

  test("Render some durations", () {
    expect(EstimateRenderer.renderDuration(Duration(minutes: 61)),
        equals("1h1min"));
    expect(
        EstimateRenderer.renderDuration(Duration(seconds: 60)), equals("1min"));
    expect(
        EstimateRenderer.renderDuration(Duration(seconds: 59)), equals("59s"));
  });
}
