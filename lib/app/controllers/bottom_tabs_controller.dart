import 'package:get/get.dart';

class BottomTabsController extends GetxController {
  final RxBool isPressed = false.obs;
  final RxInt selectedIndex = 0.obs;

  void setPressed(bool value) {
    isPressed.value = value;
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
