import 'dart:io';
import 'package:path_provider/path_provider.dart';

class OnboardingHelper {
  static Future<bool> isCompleted() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/onboarding_completed.json');
      if (await file.exists()) {
        return true;
      }
    } catch (e) {
      print('OnboardingHelper check failed: $e');
    }
    return false;
  }

  static Future<void> markCompleted() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/onboarding_completed.json');
      await file.writeAsString('{"completed": true}');
    } catch (e) {
      print('OnboardingHelper write failed: $e');
    }
  }

  static Future<void> reset() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/onboarding_completed.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('OnboardingHelper reset failed: $e');
    }
  }
}
