import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warga_kita_app/service/local_storage_service.dart';
import '../service/user_service.dart';
import '../service/user_record_service.dart';

class UserData {
  final String username;
  final String phoneNumber;
  final Map<String, int> counters;

  UserData({
    required this.username,
    required this.phoneNumber,
    required this.counters,
  }) : assert(username.isNotEmpty);

  static UserData get initial => UserData(
    username: 'Memuat...',
    phoneNumber: 'Memuat...',
    counters: {
      'created_activity': 0,
      'joined_activity': 0,
      'created_help': 0,
      'helped_help': 0,
    },
  );
}

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final UserActivityService _activityService = UserActivityService();
  final LocalStorageService _localStorageService = LocalStorageService();

  String _currentUid = '';
  UserData _userData = UserData.initial;
  bool _isLoading = false;

  UserData get userData => _userData;
  bool get isLoading => _isLoading;
  String get currentUid => _currentUid;

  UserProvider();

  Future<bool> checkAuthenticationStatus() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final localUid = await _localStorageService.getUid();

    if (firebaseUser != null && localUid != null && firebaseUser.uid == localUid) {
      _currentUid = firebaseUser.uid;
      await _loadUserData();
      return true;
    }

    _currentUid = '';
    _resetUserData();
    return false;
  }

  Future<void> setLoggedInUser(User user) async {
    _currentUid = user.uid;
    await _localStorageService.saveUid(user.uid);
    await _loadUserData();
  }

  Future<void> logout() async {
    await _localStorageService.deleteUid();
    _currentUid = '';
    _resetUserData();
  }

  void _resetUserData() {
    _userData = UserData.initial;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    if (_currentUid.isEmpty) {
      _resetUserData();
      return;
    }

    try {
      final data = await _userService.getUserData(_currentUid);
      final counterResults = await Future.wait([
        _activityService.getCreatedActivitiesCount(_currentUid),
        _activityService.getJoinedActivitiesCount(_currentUid),
        _activityService.getCreatedHelpRequestsCount(_currentUid),
        _activityService.getHelpedRequestsCount(_currentUid),
      ]);

      _userData = UserData(
        username: data['username'] ?? 'Pengguna Tidak Ditemukan',
        phoneNumber: data['phoneNumber'] ?? 'Nomor Tidak Tersedia',
        counters: {
          'created_activity': counterResults[0],
          'joined_activity': counterResults[1],
          'created_help': counterResults[2],
          'helped_help': counterResults[3],
        },
      );
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _userData = UserData.initial.copyWith(
        username: 'Error Memuat',
        phoneNumber: 'Error Memuat',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    await _loadUserData();
  }

}

extension on UserData {
  UserData copyWith({String? username, String? phoneNumber, Map<String, int>? counters}) {
    return UserData(
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      counters: counters ?? this.counters,
    );
  }
}