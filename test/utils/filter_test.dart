import 'package:flutter_test/flutter_test.dart';
import 'package:compudecsi/utils/filter.dart';

void main() {
  final events = [
    {'name': 'A', 'category': 'ai'},
    {'name': 'B', 'category': 'Inteligência Artificial'},
    {'name': 'C', 'categoria': 'robotics'},
    {'name': 'D', 'category': 'Robótica'},
  ];

  String labelFor(String v) {
    switch (v) {
      case 'ai':
        return 'Inteligência Artificial';
      case 'robotics':
        return 'Robótica';
      default:
        return v;
    }
  }

  test('returns all when no filter', () {
    final out = filterEventsByCategory(events, null, labelFor);
    expect(out.length, 4);
  });

  test('filters by canonical value or display name', () {
    final ai = filterEventsByCategory(events, 'ai', labelFor);
    expect(ai.map((e) => e['name']), containsAll(['A', 'B']));

    final rob = filterEventsByCategory(events, 'robotics', labelFor);
    expect(rob.map((e) => e['name']), containsAll(['C', 'D']));
  });
}
