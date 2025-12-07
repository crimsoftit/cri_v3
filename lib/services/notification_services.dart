import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cri_v3/features/personalization/controllers/notifications_controller.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/personalization/models/notification_model.dart';
import 'package:cri_v3/features/store/controllers/nav_menu_controller.dart';
import 'package:cri_v3/main.dart';
import 'package:cri_v3/nav_menu.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CNotificationServices extends GetxController {
  static CNotificationServices get instance =>
      Get.find<CNotificationServices>();

  /// -- variables --

  @override
  void onInit() {
    super.onInit();
    initializeNotifications();
  }

  /// -- initialize notifications --
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelDescription: 'notification channel for basic tests',
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'basic notifications',
          channelShowBadge: true,
          //criticalAlerts: true,
          defaultColor: Colors.brown,
          enableLights: true,
          enableVibration: true,
          //mportance: NotificationImportance.Max,
          ledColor: Colors.white,
          onlyAlertOnce: true,
          playSound: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'group 1',
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then((
      isAllowed,
    ) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // await AwesomeNotifications().setListeners(
    //   onActionReceivedMethod: onActionReceivedMethod,
    //   onNotificationCreatedMethod: onNotificationCreatedMethod,
    //   onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    //   onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    // );
  }

  /// -- method detects when a new notification or schedule is created --
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    try {
      debugPrint(
        'notification created payload: ${receivedNotification.payload}',
      );

      debugPrint('alert created!');
      if (receivedNotification.payload != null) {
        if (kDebugMode) {
          print('Notification payload: ${receivedNotification.payload}');
          CPopupSnackBar.customToast(
            message: receivedNotification.payload,
            forInternetConnectivityStatus: false,
          );
        }
      }
    } catch (e) {
      CPopupSnackBar.errorSnackBar(title: 'Notification Error', message: '$e');
      debugPrint('notification error: $e');
      rethrow;
    }
  }

  /// -- method detects when a new notification is displayed --
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification displayedNotification,
  ) async {
    debugPrint('alert displayed!');
  }

  /// -- method detects if the user dismissed a notification --
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('alert dismissed');
  }

  /// -- method detects when the user taps on a notification or action button --
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('alert received action');

    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == "true") {
      globalNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) {
            final navController = Get.put(CNavMenuController());
            navController.selectedIndex.value = 4;
            return const NavMenu();
          },
        ),
      );
    }
  }

  /// -- create a notification --
  static Future<void> notify({
    required final String body,
    title,
    final bool scheduled = false,
    final int? interval,
    final String? bigPicture,
    summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout alertLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final List<NotificationActionButton>? actionButtons,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    var notificationId = 1 + DateTime.now().millisecond;

    await AwesomeNotifications()
        .createNotification(
          actionButtons: actionButtons,
          content: NotificationContent(
            actionType: actionType,
            id: notificationId,
            body: body,
            bigPicture: bigPicture,
            category: category,
            channelKey: 'basic_channel',
            notificationLayout: alertLayout,
            payload: payload,
            summary: summary,
            title: title,
          ),
          schedule: scheduled
              ? NotificationInterval(
                  interval: Duration(seconds: interval ?? 60),
                  preciseAlarm: true,
                  timeZone: await AwesomeNotifications()
                      .getLocalTimeZoneIdentifier(),
                )
              : null,
        )
        .then((value) async {
          // -- save notification to sqflite db --
          var notificationItem = CNotificationsModel(
            1,
            title ?? '',
            body,
            0,
            payload != null && payload.containsKey('product_id')
                ? int.tryParse(payload['product_id']!) ?? null
                : null,
            CUserController.instance.user.value.email,
            DateTime.now().toIso8601String(),
          );
          await CNotificationsController.instance.addNotificationToDb(
            notificationItem,
          );
          await CNotificationsController.instance.fetchUserNotifications();
        });
  }
}
