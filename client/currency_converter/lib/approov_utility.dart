import 'package:flutter/services.dart';

class ApproovUtility {
  static const platform =
      const MethodChannel('com.criticalblue.approovsdk/approov');

  static Future<void> initApproov() async {
    try {
      await platform.invokeMethod('initApproov');

      // Add a delay in order to demonstrate the UI impact in case initApproov call takes time
      return new Future.delayed(const Duration(seconds: 5));
    } on PlatformException catch (e) {
      print("Failed initApproov(): '${e.message}'.");
    }
  }

  static Future<String> fetchApproovToken() async {
    String token;
    try {
      token = await platform.invokeMethod('fetchApproovToken');
    } on PlatformException catch (e) {
      print("Failed fetchApproovToken(): '${e.message}'.");
    }

    return token;
  }
}
