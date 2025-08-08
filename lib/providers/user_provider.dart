import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserRole _selectedRole = UserRole.user;
  bool _hasCompletedOnboarding = false;

  UserRole get selectedRole => _selectedRole;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  void setUserRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  void resetOnboarding() {
    _hasCompletedOnboarding = false;
    notifyListeners();
  }
}
