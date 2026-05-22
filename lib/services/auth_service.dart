import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String name;
  final String surname;
  final String username;
  final String email;
  final String password;
  final String role;

  UserProfile({
    required this.name,
    required this.surname,
    required this.username,
    required this.email,
    required this.password,
    this.role = 'user',
  });

  String get fullName => '$name $surname';
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : 'U';
  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toJson() => {
        'name': name,
        'surname': surname,
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        surname: json['surname'] ?? '',
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        role: json['role'] ?? 'user',
      );
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ValueNotifier<UserProfile?> currentUser = ValueNotifier(null);

  static const String _currentUserKey = 'vela_current_user';
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load current logged-in user
    final currentUserString = prefs.getString(_currentUserKey);
    if (currentUserString != null) {
      currentUser.value = UserProfile.fromJson(jsonDecode(currentUserString));
    }
  }

  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentUser.value != null) {
      await prefs.setString(_currentUserKey, jsonEncode(currentUser.value!.toJson()));
    } else {
      await prefs.remove(_currentUserKey);
    }
  }

  /// Register a new user. Returns error message or null on success.
  Future<String?> register(String name, String surname, String username, String email, String password) async {
    try {
      final userDoc = await _firestore.collection('users').doc(username.toLowerCase()).get();
      if (userDoc.exists) return 'Username "$username" is already taken.';

      final emailQuery = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (emailQuery.docs.isNotEmpty) return 'This email is already registered.';

      final userProfile = UserProfile(
        name: name,
        surname: surname,
        username: username,
        email: email,
        password: password,
      );

      final batch = _firestore.batch();
      batch.set(_firestore.collection('users').doc(username.toLowerCase()), userProfile.toJson());
      await batch.commit();
      return null; // success
    } catch (e) {
      return 'Failed to register: $e';
    }
  }

  /// Login with username and password. Returns error message or null on success.
  Future<String?> login(String username, String password) async {
    try {
      final userDoc = await _firestore.collection('users').doc(username.toLowerCase()).get();
      if (!userDoc.exists) return 'Account not found. Please register first.';

      final user = UserProfile.fromJson(userDoc.data()!);
      if (user.password != password) return 'Incorrect password. Please try again.';

      currentUser.value = user;
      await _saveCurrentUser();
      return null; // success
    } catch (e) {
      return 'Failed to login: $e';
    }
  }

  /// Reset password for a user by username. Returns error message or null on success.
  Future<String?> resetPassword(String username, String newPassword) async {
    try {
      final userDoc = await _firestore.collection('users').doc(username.toLowerCase()).get();
      if (!userDoc.exists) return 'Account not found. Please check your username.';

      final oldUser = UserProfile.fromJson(userDoc.data()!);
      final updatedUser = UserProfile(
        name: oldUser.name,
        surname: oldUser.surname,
        username: oldUser.username,
        email: oldUser.email,
        password: newPassword,
      );
      
      final batch = _firestore.batch();
      batch.update(_firestore.collection('users').doc(username.toLowerCase()), {'password': newPassword});
      await batch.commit();

      // If this user is currently logged in, update currentUser too
      if (currentUser.value?.username.toLowerCase() == username.toLowerCase()) {
        currentUser.value = updatedUser;
        await _saveCurrentUser();
      }

      return null; // success
    } catch (e) {
      return 'Failed to reset password: $e';
    }
  }

  Future<void> logout() async {
    currentUser.value = null;
    await _saveCurrentUser();
  }

  bool get isLoggedIn => currentUser.value != null;
}
