import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class CartItem {
  final Map<String, dynamic> product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  Map<String, dynamic> toJson() => {
        'product': product,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Map<String, dynamic>.from(json['product'] ?? {}),
        quantity: json['quantity'] ?? 1,
      );
}

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final ValueNotifier<List<CartItem>> cartItems = ValueNotifier([]);
  /// Structured address: {name, address1, address2, phone}
  final ValueNotifier<Map<String, String>> deliveryAddress = ValueNotifier({});

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String _getUsername() {
    final user = AuthService().currentUser.value;
    return user?.username.toLowerCase() ?? 'guest';
  }

  Future<void> init() async {
    await _loadCart();
    await _loadAddress();
  }

  Future<void> _loadCart() async {
    final username = _getUsername();
    try {
      final doc = await _firestore.collection('carts').doc(username).get();
      if (doc.exists && doc.data()!.containsKey('items')) {
        final List<dynamic> cartJson = doc.data()!['items'];
        cartItems.value = cartJson.map((e) => CartItem.fromJson(e)).toList();
      } else {
        cartItems.value = [];
      }
    } catch (e) {
      debugPrint('Failed to load cart: $e');
      cartItems.value = [];
    }
  }

  Future<void> _saveCart() async {
    final username = _getUsername();
    final cartJson = cartItems.value.map((e) => e.toJson()).toList();
    try {
      final batch = _firestore.batch();
      batch.set(_firestore.collection('carts').doc(username), {
        'items': cartJson,
      }, SetOptions(merge: true));
      await batch.commit();
    } catch (e) {
      debugPrint('Failed to save cart: $e');
    }
  }

  Future<void> _loadAddress() async {
    final username = _getUsername();
    try {
      final doc = await _firestore.collection('addresses').doc(username).get();
      if (doc.exists) {
        deliveryAddress.value = Map<String, String>.from(doc.data()!);
      } else {
        deliveryAddress.value = {};
      }
    } catch (e) {
      debugPrint('Failed to load address: $e');
      deliveryAddress.value = {};
    }
  }

  Future<void> _saveAddress() async {
    final username = _getUsername();
    try {
      final batch = _firestore.batch();
      batch.set(_firestore.collection('addresses').doc(username), deliveryAddress.value);
      await batch.commit();
    } catch (e) {
      debugPrint('Failed to save address: $e');
    }
  }

  /// Whether an address has been set
  bool get hasAddress {
    final addr = deliveryAddress.value;
    return addr['name']?.trim().isNotEmpty == true &&
        addr['address1']?.trim().isNotEmpty == true &&
        addr['phone']?.trim().isNotEmpty == true;
  }

  /// Formatted address string for display
  String get formattedAddress {
    final addr = deliveryAddress.value;
    if (!hasAddress) return '';
    final parts = <String>[];
    if (addr['name']?.isNotEmpty == true) parts.add(addr['name']!);
    if (addr['address1']?.isNotEmpty == true) parts.add(addr['address1']!);
    if (addr['address2']?.isNotEmpty == true) parts.add(addr['address2']!);
    if (addr['phone']?.isNotEmpty == true) parts.add(addr['phone']!);
    return parts.join('\n');
  }

  void setDeliveryAddress(Map<String, String> address) {
    deliveryAddress.value = Map<String, String>.from(address);
    _saveAddress();
  }

  void addToCart(Map<String, dynamic> product, int quantity) {
    final currentList = List<CartItem>.from(cartItems.value);
    
    // Check if exists
    final index = currentList.indexWhere((item) => item.product['name'] == product['name']);
    if (index >= 0) {
      currentList[index].quantity += quantity;
    } else {
      currentList.add(CartItem(product: product, quantity: quantity));
    }
    
    cartItems.value = currentList;
    _saveCart();
  }

  void updateQuantity(int index, int change) {
    final currentList = List<CartItem>.from(cartItems.value);
    currentList[index].quantity += change;
    if (currentList[index].quantity <= 0) {
      currentList.removeAt(index);
    }
    cartItems.value = currentList;
    _saveCart();
  }

  void removeItem(int index) {
    final currentList = List<CartItem>.from(cartItems.value);
    currentList.removeAt(index);
    cartItems.value = currentList;
    _saveCart();
  }

  int get totalPrice {
    int total = 0;
    for (var item in cartItems.value) {
      total += (item.product['price'] as int) * item.quantity;
    }
    return total;
  }

  void clearCart() {
    cartItems.value = [];
    _saveCart();
  }

  Future<void> clearForLogout() async {
    cartItems.value = [];
    deliveryAddress.value = {};
  }

  Future<void> reloadForUser() async {
    await _loadCart();
    await _loadAddress();
  }
}
