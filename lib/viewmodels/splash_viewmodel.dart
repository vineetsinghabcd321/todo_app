import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isReady = false;
  bool _isAnimating = false;

  bool get isReady => _isReady;
  bool get isAnimating => _isAnimating;

  Future<void> start() async {
    if (_isAnimating) {
      return;
    }

    _isAnimating = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(seconds: 3));

    _isReady = true;
    notifyListeners();
  }
}
