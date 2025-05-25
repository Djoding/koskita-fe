import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class DialogUtils {
  static const List<Color> _kDefaultRainbowColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  static void showLoadingDialog(BuildContext context, bool showPathBackground) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {},
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: 60,
                width: 60,
                child: LoadingIndicator(
                  indicatorType: Indicator.pacman,
                  colors: _kDefaultRainbowColors,
                  strokeWidth: 3.0,
                  pathBackgroundColor:
                      showPathBackground ? Colors.black45 : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    // Make sure the context is still valid before popping
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
