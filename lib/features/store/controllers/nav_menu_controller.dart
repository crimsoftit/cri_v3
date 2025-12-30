import 'package:cri_v3/features/personalization/screens/profile/profile.dart';
import 'package:cri_v3/features/personalization/screens/settings/user_settings_screen.dart';
import 'package:cri_v3/features/store/screens/home/home.dart';
import 'package:cri_v3/features/personalization/screens/notifications/notifications_screen.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/store_screen.dart';
import 'package:get/get.dart';

class CNavMenuController extends GetxController {
  static CNavMenuController get instance => Get.find();

  //
  final Rx<int> selectedIndex = 0.obs;


  final screens = [
    const HomeScreen(),
    //const HomeScreenRaw(),
    const CStoreScreen(),

    //const CTxnsScreen(),
    //const CCheckoutScreenRaw(),
    const CUserSettingsScreen(),

    //const SettingsScreenRaw(),
    const CProfileScreen(),
    const CNotificationsScreen(),
  ];
}
