import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category.dart';

/// Category model with Firestore serialization
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.isActive,
    required super.createdAt,
  });

  /// Create CategoryModel from Firestore document
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      slug: data['slug'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create CategoryModel from Map (for manual creation)
  factory CategoryModel.fromMap(String id, Map<String, dynamic> data) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      slug: data['slug'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Create CategoryModel from Category entity
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      isActive: category.isActive,
      createdAt: category.createdAt,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'slug': slug,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
