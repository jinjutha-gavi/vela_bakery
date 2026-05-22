import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MenuService {
  static final MenuService _instance = MenuService._internal();
  factory MenuService() => _instance;
  MenuService._internal();

  // Use getter to always get fresh Firestore instance
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final ValueNotifier<List<Map<String, dynamic>>> menuItems = ValueNotifier([]);
  final ValueNotifier<List<String>> categoryList = ValueNotifier([]);

  /// Check if an image path is a network URL (uploaded) vs local asset
  static bool isNetworkImage(String? path) {
    return path != null && (path.startsWith('http://') || path.startsWith('https://'));
  }

  /// Pick image from gallery
  Future<File?> pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) return File(picked.path);
    return null;
  }

  /// Upload image to Firebase Storage and return download URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('menu_images/$fileName');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Failed to upload image: $e');
      return null;
    }
  }

  /// Available asset images for menu items
  static const List<String> availableImages = [
    'assets/images/cakechocolate.png',
    'assets/images/chocolatecheesecake.png',
    'assets/images/cheesecake.png',
    'assets/images/redvelvetcake.png',
    'assets/images/whippedchocolatecake.png',
    'assets/images/cupcake.png',
    'assets/images/raspberrycroissant.png',
  ];

  /// Get categories for filter display (with "All" prepended)
  List<String> get categories => ['All', ...categoryList.value];

  // ─── SAFE WRITE using WriteBatch (uses different Pigeon channel) ────
  // This works around the broken documentReferenceSet channel

  Future<void> _batchSet(DocumentReference docRef, Map<String, dynamic> data) async {
    final batch = _firestore.batch();
    batch.set(docRef, data);
    await batch.commit();
  }

  Future<void> _batchUpdate(DocumentReference docRef, Map<String, dynamic> data) async {
    final batch = _firestore.batch();
    batch.update(docRef, data);
    await batch.commit();
  }

  Future<void> _batchDelete(DocumentReference docRef) async {
    final batch = _firestore.batch();
    batch.delete(docRef);
    await batch.commit();
  }

  // ─── INIT ──────────────────────────────────────────

  Future<void> init() async {
    await _loadCategories();
    await _loadMenu();
  }

  // ─── CATEGORIES ────────────────────────────────────

  Future<void> _loadCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();
      categoryList.value = snapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
    } catch (e) {
      debugPrint('Failed to load categories with orderBy: $e');
      // Fallback: load without ordering (in case index is missing)
      try {
        final snapshot = await _firestore.collection('categories').get();
        final cats = snapshot.docs
            .map((doc) => doc.data()['name'] as String)
            .toList();
        cats.sort();
        categoryList.value = cats;
      } catch (e2) {
        debugPrint('Failed to load categories fallback: $e2');
        categoryList.value = [];
      }
    }
  }

  /// Add a new category. Returns null on success, or error message on failure.
  Future<String?> addCategory(String name) async {
    try {
      // Check for duplicate (case-insensitive)
      final exists = categoryList.value.any(
        (cat) => cat.toLowerCase() == name.toLowerCase(),
      );
      if (exists) return 'Category "$name" already exists';

      final docRef = _firestore.collection('categories').doc();
      await _batchSet(docRef, {'name': name});
      await _loadCategories();
      return null; // success
    } catch (e) {
      debugPrint('Failed to add category: $e');
      return 'Failed to add category: $e';
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String name) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: name)
          .get();
      for (final doc in snapshot.docs) {
        await _batchDelete(doc.reference);
      }
      await _loadCategories();
    } catch (e) {
      debugPrint('Failed to delete category: $e');
    }
  }

  // ─── MENU ITEMS (saved to Firestore 'items' collection) ────

  Future<void> _loadMenu() async {
    try {
      final snapshot = await _firestore
          .collection('items')
          .orderBy('name')
          .get();
      menuItems.value = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['docId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Failed to load menu with orderBy: $e');
      // Fallback: load without ordering
      try {
        final snapshot = await _firestore.collection('items').get();
        final items = snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['docId'] = doc.id;
          return data;
        }).toList();
        items.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        menuItems.value = items;
      } catch (e2) {
        debugPrint('Failed to load menu fallback: $e2');
        menuItems.value = [];
      }
    }
  }

  /// Add a menu item. Returns null on success, or error message on failure.
  Future<String?> addMenuItem({
    required String name,
    required int price,
    required String image,
    required String ingredients,
    required String category,
  }) async {
    try {
      final docRef = _firestore.collection('items').doc();
      await _batchSet(docRef, {
        'name': name,
        'price': price,
        'image': image,
        'ingredients': ingredients,
        'category': category,
      });
      await _loadMenu();
      return null; // success
    } catch (e) {
      debugPrint('Failed to add menu item: $e');
      return 'Failed to add menu item: $e';
    }
  }

  /// Update a menu item. Returns null on success, or error message on failure.
  Future<String?> updateMenuItem(String docId, {
    required String name,
    required int price,
    required String image,
    required String ingredients,
    required String category,
  }) async {
    try {
      final docRef = _firestore.collection('items').doc(docId);
      await _batchUpdate(docRef, {
        'name': name,
        'price': price,
        'image': image,
        'ingredients': ingredients,
        'category': category,
      });
      await _loadMenu();
      return null; // success
    } catch (e) {
      debugPrint('Failed to update menu item: $e');
      return 'Failed to update menu item: $e';
    }
  }

  Future<void> deleteMenuItem(String docId) async {
    try {
      final docRef = _firestore.collection('items').doc(docId);
      await _batchDelete(docRef);
      await _loadMenu();
    } catch (e) {
      debugPrint('Failed to delete menu item: $e');
    }
  }

  Future<void> refreshMenu() async {
    await _loadCategories();
    await _loadMenu();
  }
}
