import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/onboarding_helper.dart';
import '../views/home_view.dart';

class OnboardingController extends GetxController {
  final RxBool isLocationGranted = false.obs;
  final RxBool isPhoneGranted = false.obs;
  final RxBool isNotificationGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermissionStatuses();
  }

  // Check current states of permissions
  Future<void> checkPermissionStatuses() async {
    isLocationGranted.value = await Permission.location.isGranted;
    isPhoneGranted.value = await Permission.phone.isGranted;
    isNotificationGranted.value = await Permission.notification.isGranted;
  }

  // Request Location Permission
  Future<void> requestLocation() async {
    final status = await Permission.location.request();
    isLocationGranted.value = status.isGranted;
  }

  // Request Phone State Permission
  Future<void> requestPhone() async {
    final status = await Permission.phone.request();
    isPhoneGranted.value = status.isGranted;
  }

  // Request Notification Permission
  Future<void> requestNotification() async {
    final status = await Permission.notification.request();
    isNotificationGranted.value = status.isGranted;
  }

  // Request all permissions sequentially
  Future<void> requestAllPermissions() async {
    await requestLocation();
    await requestPhone();
    await requestNotification();
  }

  // Verify if all permissions are granted
  bool get allGranted =>
      isLocationGranted.value &&
      isPhoneGranted.value &&
      isNotificationGranted.value;

  // Complete onboarding flow and open dashboard
  Future<void> completeOnboarding() async {
    await OnboardingHelper.markCompleted();
    Get.offAll(() => const HomeView());
  }
}
