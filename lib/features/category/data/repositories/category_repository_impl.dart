import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../vehicle_auction/data/models/category_model.dart';
import '../../../vehicle_auction/domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

/// Implementation of CategoryRepository using Firebase
class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore _firestore;

  static const String _collection = 'categories';

  CategoryRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _categoriesRef => _firestore.collection(_collection);

  @override
  Future<List<Category>> getCategories() async {
    final snapshot = await _categoriesRef.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  }

  @override
  Future<Category> getCategoryById(String id) async {
    final doc = await _categoriesRef.doc(id).get();

    if (!doc.exists) {
      throw Exception('Category not found');
    }

    return CategoryModel.fromFirestore(doc);
  }

  @override
  Future<Category> createCategory({
    required String name,
    required String slug,
  }) async {
    final now = DateTime.now();

    final categoryData = {
      'name': name,
      'slug': slug,
      'isActive': true,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    final docRef = await _categoriesRef.add(categoryData);
    final doc = await docRef.get();

    return CategoryModel.fromFirestore(doc);
  }

  @override
  Future<void> updateCategory(String id, Map<String, dynamic> updates) async {
    updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _categoriesRef.doc(id).update(updates);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _categoriesRef.doc(id).delete();
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _categoriesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList());
  }
}
