import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/personalization/models/notification_model.dart';
import 'package:cri_v3/utils/db/sqflite/db_helper.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CNotificationsController extends GetxController {
  static CNotificationsController get instance => Get.find();

  /// -- variables --
  DbHelper dbHelper = DbHelper.instance;
  final isLoading = false.obs;
  final RxBool notificationsEnabled = false.obs;
  final RxList<CNotificationsModel> allNotifications =
      <CNotificationsModel>[].obs;
  final RxList<CNotificationsModel> pendingAlerts = <CNotificationsModel>[].obs;
  final RxList<CNotificationsModel> readNotifications =
      <CNotificationsModel>[].obs;
  final RxList<CNotificationsModel> unreadNotifications =
      <CNotificationsModel>[].obs;

  final userController = Get.put(CUserController());

  @override
  void onInit() async {
    if (userController.user.value.email != '') {
      fetchUserNotifications();
    }

    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      // Notifications permission is allowed
      notificationsEnabled.value = true;
    } else {
      // Permission is denied or permanently denied
      notificationsEnabled.value = false;
    }

    // Only after at least the action method is set, the notification events are delivered
    // AwesomeNotifications().setListeners(
    //   onActionReceivedMethod: CNotificationsController.onActionReceivedMethod,
    //   onNotificationCreatedMethod:
    //       CNotificationsController.onNotificationCreatedMethod,
    //   onNotificationDisplayedMethod:
    //       CNotificationsController.onNotificationDisplayedMethod,
    //   onDismissActionReceivedMethod:
    //       CNotificationsController.onDismissActionReceivedMethod,
    // );

    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     notificationsEnabled.value = false;
    //     // This is just a basic example. For real apps, you must show some
    //     // friendly dialog box before call the request method.
    //     // This is very important to not harm the user experience
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   } else if (isAllowed) {
    //     notificationsEnabled.value = true;
    //   }
    // });

    super.onInit();
  }

  /// Use this method to detect when a new notification or a schedule is created
  // @pragma("vm:entry-point")
  // static Future<void> onNotificationCreatedMethod(
  //   ReceivedNotification receivedNotification,
  // ) async {
  //   // Your code goes here
  // }

  // /// Use this method to detect every time that a new notification is displayed
  // @pragma("vm:entry-point")
  // static Future<void> onNotificationDisplayedMethod(
  //   ReceivedNotification receivedNotification,
  // ) async {
  //   // Your code goes here
  // }

  // /// Use this method to detect if the user dismissed a notification
  // @pragma("vm:entry-point")
  // static Future<void> onDismissActionReceivedMethod(
  //   ReceivedAction receivedAction,
  // ) async {
  //   // Your code goes here
  // }

  // /// Use this method to detect when the user taps on a notification or action button
  // @pragma("vm:entry-point")
  // static Future<void> onActionReceivedMethod(
  //   ReceivedAction receivedAction,
  // ) async {
  //   // Your code goes here

  //   // Navigate into pages, avoiding to open the notification details page over another details page already opened

  //   final navController = Get.put(CNavMenuController());

  //   globalNavigatorKey.currentState?.pushNamedAndRemoveUntil(
  //     '/landing_screen',
  //     (route) => (route.settings.name != '/landing_screen') || route.isFirst,
  //     arguments: receivedAction,
  //   );
  //   navController.selectedIndex.value = 4;
  //   Get.to(() => NavMenu());
  // }

  void notif(
    int notificationId,
    String notificationTitle,
    String notificationBody,
  ) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        //actionType: ActionType.Default,
        actionType: ActionType.Default,
        body: notificationBody,
        channelKey: 'basic_channel',
        displayOnBackground: true,
        displayOnForeground: true,
        fullScreenIntent: true,
        id: notificationId,
        title: notificationTitle,
        wakeUpScreen: true,
      ),
    );
  }

  /// -- save notification details to sqflite db --
  Future<void> addNotificationToDb(CNotificationsModel notificationItem) async {
    try {
      // -- start loader
      isLoading.value = true;

      // -- insert notification item into sqflite db --
      await dbHelper.addNotificationItem(notificationItem);

      // -- refresh list --
      fetchUserNotifications();

      // -- stop loader
      isLoading.value = false;
    } catch (e) {
      // -- stop loader
      isLoading.value = false;

      if (kDebugMode) {
        print(e);
        CPopupSnackBar.errorSnackBar(
          title: 'error saving notification',
          message: e.toString(),
        );
      }
    }
  }

  // Future saveAndOrTriggerNotification(
  //   CNotificationsModel notificationItem,
  //   int notId,
  //   String notTitle,
  //   String notBody,
  //   bool triggerAlert,
  // ) async {
  //   try {
  //     // -- start loader
  //     isLoading.value = true;

  //     // -- insert notification item into sqflite db --
  //     if (await dbHelper.addNotificationItem(notificationItem)) {
  //       if (triggerAlert) {
  //         notify(notId, notTitle, notBody);
  //       }
  //     }

  //     // -- refresh list --
  //     fetchUserNotifications();

  //     // -- stop loader
  //     isLoading.value = false;
  //   } catch (e) {
  //     // -- stop loader
  //     isLoading.value = false;

  //     if (kDebugMode) {
  //       print(e);
  //       CPopupSnackBar.errorSnackBar(
  //         title: 'error saving notification',
  //         message: e.toString(),
  //       );
  //     }
  //   }
  // }

  /// -- fetch user notifications from local db --
  Future<List<CNotificationsModel>> fetchUserNotifications() async {
    try {
      // -- start loader --
      isLoading.value = true;

      // -- query local db for notifications --
      var fetchedNotifications = await dbHelper.fetchUserNotifications(
        userController.user.value.email,
      );

      // -- assign fetchedNotifications to allNotifications list --
      allNotifications.assignAll(fetchedNotifications);

      // -- assign read notifications to readNotifications list
      var readNots = allNotifications
          .where((readNotification) => readNotification.notificationIsRead == 1)
          .toList();

      readNotifications.assignAll(readNots);

      // -- assign read notifications to readNotifications list
      var unreadNots = allNotifications
          .where(
            (unreadNotification) => unreadNotification.notificationIsRead == 0,
          )
          .toList();

      unreadNotifications.assignAll(unreadNots);

      // -- assign pending notifications --
      var pendingNots = allNotifications
          .where((pendingNot) => pendingNot.alertCreated == 0)
          .toList();
      pendingAlerts.assignAll(pendingNots);

      // -- stop loader --
      isLoading.value = false;

      return allNotifications;
    } catch (e) {
      // -- stop loader --
      isLoading.value = false;

      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      }

      rethrow;
    }
  }

  /// -- request notification permissions --
  Future<void> requestNotificationPermissions(bool value) async {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (value) {
        if (!isAllowed) {
          notificationsEnabled.value = false;
          // This is just a basic example. For real apps, you must show some
          // friendly dialog box before call the request method.
          // This is very important to not harm the user experience
          AwesomeNotifications().requestPermissionToSendNotifications();
        } else {
          notificationsEnabled.value = true;
          return;
        }
      } else {
        notificationsEnabled.value = false;
        //AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  /// -- generate notification id --
  Future<int> generateNotificationId() async {
    var previousAlertId = allNotifications.isNotEmpty
        ? allNotifications.fold(allNotifications.first.notificationId!, (
            max,
            element,
          ) {
            return element.notificationId! > max
                ? element.notificationId!
                : max;
          })
        : 0;
    var thisAlertId = previousAlertId + 1;
    return thisAlertId;
  }
}
