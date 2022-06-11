import 'package:test/test.dart';
import 'estimate.dart';

void main() {
  test('Estimate.toString() nicely renders an upcoming ETA', () {
    final start = DateTime.parse("2020-02-02T12:34:56");
    final now = DateTime.parse("2020-02-02T12:35:56");
    final earliest = DateTime.parse("2020-02-02T12:39:56");
    final latest = DateTime.parse("2020-02-02T12:42:56");

    final estimate = Estimate(start, earliest, latest, 200, now: now);
    expect(
        estimate.toString(),
        equals('You will get to 200 in\n'
            'between 4min, 12:39\n'
            'and 7min, 12:42\n'
            'for a total queue time of 5min-8min'));
  });

  test("Estimate.toString() nicely renders when we're inside of the ETA zone",
      () {
    final start = DateTime.parse("2020-02-02T12:34:56");
    final earliest = DateTime.parse("2020-02-02T12:39:56");
    final now = DateTime.parse("2020-02-02T12:40:56");
    final latest = DateTime.parse("2020-02-02T12:42:56");

    final estimate = Estimate(start, earliest, latest, 200, now: now);
    expect(
        estimate.toString(),
        equals('You will get to 200 in\n'
            '2min, at 12:42\n'
            'for a total queue time of 8min'));
  });

  test("Estimate.toString() nicely renders when we're after the ETA", () {
    final start = DateTime.parse("2020-02-02T12:34:56");
    final earliest = DateTime.parse("2020-02-02T12:39:56");
    final latest = DateTime.parse("2020-02-02T12:42:56");
    final now = DateTime.parse("2020-02-02T12:44:56");

    final estimate = Estimate(start, earliest, latest, 200, now: now);
    expect(
        estimate.toString(),
        equals('You should have arrived at 200\n'
            '2min ago, at 12:42\n'
            'for a total queue time of 8min'));
  });
}
