import 'dart:math';

import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:clock/clock.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_date_utils/in_date_utils.dart';

class CDashboardController extends GetxController {
  static CDashboardController get instance => Get.find();

  /// -- variables --
  final carouselSliderIndex = 0.obs;

  final invController = Get.put(CInventoryController());

  final RxBool isLoading = false.obs;

  final RxBool showSummaryFilterField = false.obs;
  final RxDouble currentWeekSales = 0.0.obs;
  final RxDouble lastWeekSales = 0.0.obs;

  final RxDouble weeklyPercentageChange = 0.0.obs;
  final RxDouble weeklySalesHighestAmount = 0.0.obs;
  final RxList<double> weeklySales = <double>[].obs;

  final txnsController = Get.put(CTxnsController());

  @override
  void onInit() async {
    showSummaryFilterField.value = false;
    weeklySalesHighestAmount.value = 1000.0;
    Future.delayed(Duration.zero, () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await txnsController.fetchSoldItems().then((result) async {
          calculateCurrentWeekSales();
          calculateLastWeekSales();
        });
      });
    });

    super.onInit();
  }

  /// -- calculate this week's sales --
  void calculateCurrentWeekSales() async {
    // reset weeklySales values to zero
    weeklySales.value = List<double>.filled(7, 0.0);
    //currentWeekSales.value = 0.0;

    txnsController.fetchSoldItems().then((result) {
      if (result.isNotEmpty) {
        var demLegitSales = txnsController.sales
            .where((soldItem) => soldItem.quantity >= 1)
            .toList();
        for (var sale in demLegitSales) {
          final String rawSaleDate = sale.lastModified.trim();
          var formattedDate = rawSaleDate.replaceAll(' @', '');
          final DateTime currentWeekSalesStart =
              CHelperFunctions.getStartOfCurrentWeek(
                DateTime.parse(formattedDate),
              );

          // check if sale date is within the current week
          if (currentWeekSalesStart.isBefore(clock.now()) &&
              currentWeekSalesStart
                  .add(const Duration(days: 7))
                  .isAfter(clock.now())) {
            int index = (DateTime.parse(formattedDate).weekday - 1) % 7;

            // ensure the index is non-negative
            index = index < 0 ? index + 7 : index;
            weeklySales[index] += (sale.unitSellingPrice * sale.quantity);
            currentWeekSales.value += (sale.unitSellingPrice * sale.quantity);

            if (kDebugMode) {
              print(
                'date: $formattedDate, current week day: $currentWeekSalesStart, index: $index',
              );
            }
          }
        }
      }

      weeklySalesHighestAmount.value = weeklySales.reduce(max) > 1
          ? weeklySales.reduce(max)
          : 1000;

      if (kDebugMode) {
        print('weekly sales: $weeklySales');
      }
    });
  }

  /// -- calculate last week's sales --
  void calculateLastWeekSales() {
    // reset lastWeekSales value to zero
    lastWeekSales.value = 0.0;
    weeklyPercentageChange.value = 0.0;

    final now = DateTime.now();
    final lastWeekStart = now.subtract(
      Duration(days: now.weekday + 6),
    ); // Monday of last week
    final lastWeekEnd = lastWeekStart.add(
      Duration(days: 6),
    ); // Sunday of last week

    if (kDebugMode) {
      print('last week start date: $lastWeekStart \n');
      print('last week end date: $lastWeekEnd \n');
    }

    // Filter sales data for the last week
    Future.delayed(Duration.zero, () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        txnsController.fetchSoldItems().then((result) {
          if (result.isNotEmpty) {
            var demLegitSales = txnsController.sales
                .where((soldItem) => soldItem.quantity >= 1)
                .toList();
            // Filter sales data for last week
            lastWeekSales.value = demLegitSales
                .where((sale) {
                  final String rawSaleDate = sale.lastModified.trim();
                  var formattedDate = rawSaleDate.replaceAll(' @', '');

                  return DateTime.parse(formattedDate).isAfter(lastWeekStart) &&
                      DateTime.parse(formattedDate).isBefore(lastWeekEnd);
                })
                .fold(
                  0.0,
                  (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
                );

            if (kDebugMode) {
              print('total sales for last week: $lastWeekSales.');
            }
          }
        });
      });
    });
  }

  FlTitlesData buildFlTitlesData() {
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            // map index to the desired day of the week
            final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

            // calculate the index and ensure it wraps around the corresponding day of the week
            final index = value.toInt() % days.length;

            // get the day corresponding to the calculated index
            final day = days[index];

            return SideTitleWidget(
              space: 0,
              axisSide: AxisSide.bottom,
              child: Text(
                day,
                style: TextStyle(
                  color: isConnectedToInternet
                      ? CColors.rBrown
                      : CColors.darkGrey,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: weeklySalesHighestAmount.value,
          reservedSize: 70.0,
          getTitlesWidget: (value, meta) {
            final userController = Get.put(CUserController());
            return SideTitleWidget(
              space: 0,
              axisSide: AxisSide.bottom,
              child: Text(
                '${userController.user.value.currencyCode}.$value',
                style: TextStyle(
                  color: isConnectedToInternet
                      ? CColors.rBrown
                      : CColors.darkGrey,
                  fontSize: 10.0,
                ),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// -- update carousel slider index --
  void updateCarouselSliderIndex(int index) {
    carouselSliderIndex.value = index;
  }

  toggleDateFieldVisibility() {
    showSummaryFilterField.value = !showSummaryFilterField.value;
    if (!showSummaryFilterField.value) {
      txnsController.dateRangeFieldController.text = '';
      txnsController.initializeSalesSummaryValues();
    }
  }
}
