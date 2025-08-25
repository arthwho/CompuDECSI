import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:compudecsi/services/category_service.dart';

void main() {
  test('CategoryService maps between name and value', () async {
    final fake = FakeFirebaseFirestore();
    CategoryService.firestore = fake;

    await fake.collection('categories').add({
      'name': 'Inteligência Artificial',
      'value': 'ai',
      'icon': 'psychology',
      'order': 1,
    });
    await fake.collection('categories').add({
      'name': 'Robótica',
      'value': 'robotics',
      'icon': 'smart_toy',
      'order': 2,
    });

    final names = await CategoryService.getCategoryNames();
    expect(names, containsAll(['Inteligência Artificial', 'Robótica']));

    final values = await CategoryService.getCategoryValues();
    expect(values, containsAll(['ai', 'robotics']));

    expect(await CategoryService.nameToValue('Inteligência Artificial'), 'ai');
    expect(await CategoryService.valueToName('robotics'), 'Robótica');
  });
}
