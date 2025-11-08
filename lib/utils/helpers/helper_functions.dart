import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CHelperFunctions {
  /// -- get first day of current week --
  static DateTime getStartOfCurrentWeek(DateTime date) {
    final int daysUntilMonday = date.weekday - 1;
    final DateTime startOfWeek = date.subtract(Duration(days: daysUntilMonday));

    var weekStart = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
      startOfWeek.weekday,
      startOfWeek.hour,
      startOfWeek.minute,
      0,
      0,
    );

    if (kDebugMode) {
      // print('----------\n');
      // print('weekStart: $weekStart \n');
      // print('----------\n');
      // print('----------\n');
      // print('week day: ${startOfWeek.weekday} \n');
      // print('----------\n');

      // CPopupSnackBar.customToast(
      //   message: 'weekday: ${startOfWeek.weekday}',
      //   forInternetConnectivityStatus: false,
      // );
    }
    return weekStart;
  }

  static void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showAlert(String title, String message, VoidCallback okAction) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              //onPressed: () => Navigator.of(context).pop(),
              onPressed: okAction,
              child: const Text('confirm'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('cancel'),
            ),
          ],
        );
      },
    );
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static String formatCurrency(String s) {
    return s[0].toUpperCase() +
        s[1].toUpperCase() +
        s.substring(2).toLowerCase();
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  static String getFormattedDate(DateTime date,
      {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrappedList = <Widget>[];
    for (var i = 0; i < widgets.length; i += rowSize) {
      final rowChildren = widgets.sublist(
          i, i + rowSize > widgets.length ? widgets.length : i + rowSize);
      wrappedList.add(Row(
        children: rowChildren,
      ));
    }
    return wrappedList;
  }

  static int generateRandom3DigitNumber() {
    Random random = Random();
    int min = 100;
    int max = 999;
    return random.nextInt(max - min) + min;
  }

  static int generateRandom4DigitNumber() {
    Random random = Random();
    int floor = 1000;
    int ceil = 9999;

    return random.nextInt(ceil - floor) + floor;
  }

  static int generateInvId() {
    final now = DateTime.now();
    return now.millisecondsSinceEpoch + generateRandom3DigitNumber();
  }

  static int generateTxnId() {
    final now = DateTime.now();
    return now.millisecondsSinceEpoch + generateRandom4DigitNumber();
  }

  static int generateAlertId() {
    //final now = DateTime.now();
    return generateRandom4DigitNumber();
  }

  static String generateProductCode() {
    final now = DateTime.now();

    var codeString = now.microsecondsSinceEpoch.toString();
    var pCode = codeString.substring(codeString.length - 7);
    var productCode = 'rI-$pCode';
    return productCode;
  }
}
