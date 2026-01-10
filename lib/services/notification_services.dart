import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cri_v3/features/personalization/controllers/notification_tings/awesome_notifications/notifications_controller.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/personalization/models/notification_model.dart';
import 'package:cri_v3/features/store/controllers/nav_menu_controller.dart';
import 'package:cri_v3/main.dart';
import 'package:cri_v3/nav_menu.dart';
import 'package:cri_v3/utils/db/sqflite/db_helper.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CAwesomeNotificationServices extends GetxController {
  static CAwesomeNotificationServices get instance =>
      Get.find<CAwesomeNotificationServices>();

  /// -- variables --

  @override
  void onInit() async {
    super.onInit();
    await initializeNotifications();
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

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
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

    final notificationsController = Get.put(CNotificationsController());
    final payload = receivedAction.payload ?? {};

    if (payload["notification_id"] != null) {
      notificationsController.fetchUserNotifications().then((_) {
        if (notificationsController.allNotifications.isNotEmpty) {
          final int notifId =
              int.tryParse(payload["notification_id"] ?? '') ?? 0;
          final notifIndex = notificationsController.allNotifications
              .indexWhere((notif) => notif.notificationId == notifId);
          if (notifIndex != -1) {
            notificationsController
                    .allNotifications[notifIndex]
                    .notificationIsRead =
                1;
            DbHelper.instance.updateNotificationItem(
              notificationsController.allNotifications[notifIndex],
            );
            notificationsController.fetchUserNotifications();
          }
        }
      });
    }
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
    required final int notificationId,
    final String? bigPicture,
    summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout alertLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final List<NotificationActionButton>? actionButtons,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

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
            title ?? 'no title',
            body,
            0,
            payload != null && payload.containsKey('product_id')
                ? int.tryParse(payload['product_id']!)
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

  /// -- schedule notifications for items nearing expiry date --
  Future<void> createScheduledNotification({
    required String body,
    required DateTime expiryDate,
    required int id,
    required int notificationTimeInDays,
    required String title,
    
  }) async {
    try {
      // compute notification time (e.g., 2 days before expiry)
      final notificationTime = expiryDate.subtract(Duration(days: notificationTimeInDays));

      // ensure notification time is in the future
      if (notificationTime.isAfter(DateTime.now())) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: 'basic_channel',
            title: title,
            body: body,
            notificationLayout: NotificationLayout.Inbox,
          ),
          // schedule: NotificationInterval(
          //   interval: Duration(seconds: interval),
          //   preciseAlarm: true,
          //   timeZone:
          //       await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          // ),
          schedule: NotificationCalendar(
            year: notificationTime.year,
            month: notificationTime.month,
            day: notificationTime.day,
            hour: notificationTime.hour,
            minute: notificationTime.minute,
            second: notificationTime.second,
            millisecond: 0,
            repeats: false,
            timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          ),
        );
      } else {
        debugPrint(
          'Notification time $notificationTime is not in the future. Skipping scheduling.',
        );
      }
    } catch (e) {
      debugPrint('Error scheduling expiry notifications: $e');
      if (kDebugMode) {
        print('Error scheduling expiry notifications: $e');
        CPopupSnackBar.errorSnackBar(
          title: 'Notification Error',
          message: 'Error scheduling expiry notifications: $e',
        );
      }
      CPopupSnackBar.errorSnackBar(
        title: 'notification error',
        message:
            'an unknown error occurred while scheduling expiry notifications',
      );
      rethrow;
    }
  }
}
