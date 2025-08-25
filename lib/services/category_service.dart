import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all categories from Firestore
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'value': data['value'] ?? '',
          'icon': data['icon'] ?? '',
          'order': data['order'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Get category display names for UI
  static Future<List<String>> getCategoryNames() async {
    final categories = await getCategories();
    return categories.map((cat) => cat['name'] as String).toList();
  }

  // Get category values for database storage
  static Future<List<String>> getCategoryValues() async {
    final categories = await getCategories();
    return categories.map((cat) => cat['value'] as String).toList();
  }

  // Convert display name to value
  static Future<String> nameToValue(String displayName) async {
    final categories = await getCategories();
    final category = categories.firstWhere(
      (cat) => cat['name'] == displayName,
      orElse: () => {'value': ''},
    );
    return category['value'] as String;
  }

  // Convert value to display name
  static Future<String> valueToName(String value) async {
    final categories = await getCategories();
    final category = categories.firstWhere(
      (cat) => cat['value'] == value,
      orElse: () => {'name': ''},
    );
    return category['name'] as String;
  }

  // Get category by value
  static Future<Map<String, dynamic>?> getCategoryByValue(String value) async {
    final categories = await getCategories();
    try {
      return categories.firstWhere((cat) => cat['value'] == value);
    } catch (e) {
      return null;
    }
  }

  // Add a new category (admin only)
  static Future<bool> addCategory({
    required String name,
    required String value,
    required String icon,
    int order = 0,
  }) async {
    try {
      await _firestore.collection('categories').add({
        'name': name,
        'value': value,
        'icon': icon,
        'order': order,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  // Update a category (admin only)
  static Future<bool> updateCategory({
    required String id,
    String? name,
    String? value,
    String? icon,
    int? order,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (value != null) updates['value'] = value;
      if (icon != null) updates['icon'] = icon;
      if (order != null) updates['order'] = order;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('categories').doc(id).update(updates);
      return true;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  // Delete a category (admin only)
  static Future<bool> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }
}
