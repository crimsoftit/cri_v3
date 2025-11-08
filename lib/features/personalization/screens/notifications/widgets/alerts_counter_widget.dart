import 'package:cri_v3/features/personalization/controllers/notifications_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CAlertsCounterWidget extends StatelessWidget {
  const CAlertsCounterWidget({
    super.key,
    this.counterBgColor,
    this.counterTxtColor,
    this.rightPosition,
    this.topPosition,
  });

  final Color? counterBgColor;
  final Color? counterTxtColor;

  final double? rightPosition, topPosition;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final notsController = Get.put(CNotificationsController());

    return Positioned(
      right: rightPosition,
      top: topPosition,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: counterBgColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Obx(() {
            notsController.fetchUserNotifications();

            /// -- display count of only created notifications --
            var notifiedAlerts = notsController.allNotifications.where(
              (notifiedAlert) => notifiedAlert.alertCreated == 1,
            );
            return Text(
              notifiedAlerts.length.toString(),
              style: Theme.of(context).textTheme.labelSmall!.apply(
                color:
                    counterTxtColor ??
                    (isDarkTheme ? CColors.rBrown : CColors.white),
                fontSizeFactor: 1.0,
              ),
            );
          }),
        ),
      ),
    );
  }
}
