import 'package:cri_v3/features/store/controllers/cart_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/nav_menu_controller.dart';
import 'package:cri_v3/features/personalization/controllers/notifications_controller.dart';
import 'package:cri_v3/features/personalization/screens/notifications/widgets/alerts_counter_widget.dart';
import 'package:cri_v3/features/store/models/notifications_model.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavMenu extends StatelessWidget {
  const NavMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CCartController());
    final isDark = CHelperFunctions.isDarkMode(context);
    final invController = Get.put(CInventoryController());

    final navController = Get.put(CNavMenuController());
    final notsController = Get.put(CNotificationsController());

    Future.delayed(Duration(milliseconds: 200), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.put(CInventoryController());
        Get.put(CCartController());
      });
    });

    // invController.onInit();
    // cartController.fetchCartItems();

    GlobalKey navBarGlobalKey = GlobalKey(debugLabel: 'bottomAppBar');

    return Obx(() {
      if (invController.inventoryItems.isEmpty &&
          !invController.isLoading.value) {
        invController.onInit();
      }

      Future.delayed(Duration.zero, () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cartController.fetchCartItems();
        });
      });

      Iterable<CNotificationsModel> notifiedAlerts = <CNotificationsModel>[];
      Future.delayed(Duration.zero, () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notsController.fetchUserNotifications();

          /// -- display count of only created notifications --
          // notifiedAlerts = notsController.allNotifications
          //     .where((notifiedAlert) => notifiedAlert.alertCreated == 1);
          notifiedAlerts = notsController.allNotifications;
        });
      });

      return Scaffold(
        bottomNavigationBar: NavigationBar(
          key: navBarGlobalKey,
          height: 80.0,
          elevation: 0,
          selectedIndex: navController.selectedIndex.value,
          onDestinationSelected: (index) {
            navController.selectedIndex.value = index;
          },
          backgroundColor: isDark
              ? CNetworkManager.instance.hasConnection.value
                    ? CColors.rBrown
                    : CColors.black
              : CNetworkManager.instance.hasConnection.value
              ? CColors.rBrown.withValues(alpha: 0.1)
              : CColors.black.withValues(alpha: 0.1),
          indicatorColor: isDark
              ? CColors.white.withValues(alpha: 0.3)
              : CNetworkManager.instance.hasConnection.value
              ? CColors.rBrown.withValues(alpha: 0.3)
              : CColors.black.withValues(alpha: 0.3),
          destinations: [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'home'),
            // NavigationDestination(
            //   icon: Icon(
            //     Iconsax.home,
            //   ),
            //   label: 'homeRaw',
            // ),
            NavigationDestination(icon: Icon(Iconsax.shop), label: 'store'),

            // NavigationDestination(
            //   icon: Icon(Iconsax.empty_wallet_time),
            //   label: 'sales_raw',
            // ),
            // NavigationDestination(
            //   icon: Icon(Iconsax.wallet_check),
            //   label: 'txns',
            // ),
            NavigationDestination(
              icon: Icon(Iconsax.setting),
              label: 'account',
            ),

            NavigationDestination(icon: Icon(Iconsax.user), label: 'profile'),
            SizedBox(
              child: Stack(
                children: [
                  NavigationDestination(
                    icon: Icon(Iconsax.notification),
                    label: 'alerts',
                  ),
                  if (notifiedAlerts.isNotEmpty)
                    CAlertsCounterWidget(
                      counterBgColor: Colors.red,
                      counterTxtColor: CColors.white,
                      rightPosition: 15.0,
                      topPosition: 10.0,
                    ),
                ],
              ),
            ),
          ],
        ),
        body: navController.screens[navController.selectedIndex.value],
      );
    });
  }
}
