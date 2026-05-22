import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'auth_service.dart';

enum OrderStatus { preparing, shipping, delivered }

class OrderItem {
  final String name;
  final int price;
  final int quantity;
  final String image;
  final String ingredients;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.ingredients,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'quantity': quantity,
        'image': image,
        'ingredients': ingredients,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        name: json['name'] ?? '',
        price: json['price'] ?? 0,
        quantity: json['quantity'] ?? 1,
        image: json['image'] ?? '',
        ingredients: json['ingredients'] ?? '',
      );
}

class Order {
  final String orderId;
  final List<OrderItem> items;
  final int totalPrice;
  final int deliveryFee;
  final String deliveryAddress;
  final String paymentMethod;
  OrderStatus status;
  final DateTime createdAt;
  final String driverName;
  final double driverRating;
  final int estimatedMinutes;

  Order({
    required this.orderId,
    required this.items,
    required this.totalPrice,
    required this.deliveryFee,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.driverName,
    required this.driverRating,
    required this.estimatedMinutes,
  });

  int get grandTotal => totalPrice + deliveryFee;

  String get statusLabel {
    switch (status) {
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.shipping:
        return 'Shipping';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  String get statusMessage {
    switch (status) {
      case OrderStatus.preparing:
        return 'Preparing your order';
      case OrderStatus.shipping:
        return 'Your order is on its way';
      case OrderStatus.delivered:
        return 'Order delivered!';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.preparing:
        return const Color(0xFFFF9500);
      case OrderStatus.shipping:
        return const Color(0xFF34C759);
      case OrderStatus.delivered:
        return const Color(0xFF007AFF);
    }
  }

  String get itemsSummary {
    if (items.length == 1) {
      return '${items[0].name} x${items[0].quantity}';
    }
    return '${items[0].name} x${items[0].quantity} +${items.length - 1} more';
  }

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'items': items.map((e) => e.toJson()).toList(),
        'totalPrice': totalPrice,
        'deliveryFee': deliveryFee,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
        'driverName': driverName,
        'driverRating': driverRating,
        'estimatedMinutes': estimatedMinutes,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json['orderId'] ?? '',
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => OrderItem.fromJson(e))
                .toList() ??
            [],
        totalPrice: json['totalPrice'] ?? 0,
        deliveryFee: json['deliveryFee'] ?? 0,
        deliveryAddress: json['deliveryAddress'] ?? '',
        paymentMethod: json['paymentMethod'] ?? '',
        status: OrderStatus.values[json['status'] ?? 0],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        driverName: json['driverName'] ?? 'Somchai Jaidee',
        driverRating: (json['driverRating'] ?? 4.0).toDouble(),
        estimatedMinutes: json['estimatedMinutes'] ?? 15,
      );
}

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final ValueNotifier<List<Order>> orders = ValueNotifier([]);
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _orderSubscription;

  static const List<String> _driverNames = [
    'Somchai Jaidee',
    'Nattapong Suk',
    'Kittisak Dee',
    'Pranee Siri',
    'Wanida Chai',
  ];

  String _getUsername() {
    final user = AuthService().currentUser.value;
    return user?.username.toLowerCase() ?? 'guest';
  }

  Future<void> init() async {
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    final username = _getUsername();
    _orderSubscription?.cancel();
    _orderSubscription = _firestore
        .collection('orders')
        .where('username', isEqualTo: username)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) => Order.fromJson(doc.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      orders.value = list;
    });
  }

  String _generateOrderId() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final id = List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
    return '#$id';
  }

  Future<Order> placeOrder({
    required List<OrderItem> items,
    required int totalPrice,
    required int deliveryFee,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    final random = Random();
    final driverName = _driverNames[random.nextInt(_driverNames.length)];
    final driverRating = 3.5 + random.nextDouble() * 1.5; // 3.5-5.0
    final estimatedMinutes = 10 + random.nextInt(21); // 10-30 min

    final order = Order(
      orderId: _generateOrderId(),
      items: items,
      totalPrice: totalPrice,
      deliveryFee: deliveryFee,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      status: OrderStatus.preparing,
      createdAt: DateTime.now(),
      driverName: driverName,
      driverRating: double.parse(driverRating.toStringAsFixed(1)),
      estimatedMinutes: estimatedMinutes,
    );

    final docData = order.toJson();
    docData['username'] = _getUsername();
    final docRef = _firestore.collection('orders').doc();
    final batch = _firestore.batch();
    batch.set(docRef, docData);
    await batch.commit();

    // Simulate status changes
    _simulateStatusChanges(order.orderId);

    return order;
  }

  void _simulateStatusChanges(String orderId) {
    // After 15 seconds, change to "shipping"
    Future.delayed(const Duration(seconds: 15), () async {
      final query = await _firestore.collection('orders').where('orderId', isEqualTo: orderId).get();
      if (query.docs.isNotEmpty) {
        final batch = _firestore.batch();
        batch.update(query.docs.first.reference, {'status': OrderStatus.shipping.index});
        await batch.commit();
      }
    });

    // After 60 seconds, change to "delivered"
    Future.delayed(const Duration(seconds: 60), () async {
      final query = await _firestore.collection('orders').where('orderId', isEqualTo: orderId).get();
      if (query.docs.isNotEmpty) {
        final batch = _firestore.batch();
        batch.update(query.docs.first.reference, {'status': OrderStatus.delivered.index});
        await batch.commit();
      }
    });
  }

  int get orderCount => orders.value.length;

  List<Order> getFilteredOrders(String filter) {
    if (filter == 'All') return orders.value;
    return orders.value.where((o) => o.statusLabel == filter).toList();
  }

  Future<void> clearForLogout() async {
    _orderSubscription?.cancel();
    orders.value = [];
  }

  Future<void> reloadForUser() async {
    await _loadOrders();
  }
}
