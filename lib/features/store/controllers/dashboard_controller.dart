import 'dart:math';

import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/helpers/formatter.dart';
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

  final RxDouble salesBtnMidnightTo3 = 0.0.obs;
  final RxDouble salesBtn3to6 = 0.0.obs;
  final RxDouble salesBtn6to9 = 0.0.obs;
  final RxDouble salesBtn9to12 = 0.0.obs;
  final RxDouble salesBtn12to15 = 0.0.obs;
  final RxDouble salesBtn15to18 = 0.0.obs;
  final RxDouble salesBtn18to21 = 0.0.obs;
  final RxDouble salesBtn21toMidnight = 0.0.obs;

  final RxDouble peakSalesAmount = 0.0.obs;

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
          filterHourlySales();
          //computeHourlySales();
        });
      });
    });

    Future.delayed(
      Duration.zero,
      () {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            await txnsController.fetchTopSellersFromSales();
          },
        );
      },
    );

    super.onInit();
  }

  /// -- calculate this week's sales --
  void calculateCurrentWeekSales() async {
    // reset weeklySales values to zero
    weeklySales.value = List<double>.filled(7, 0.0);
    currentWeekSales.value = 0.0;

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

  FlTitlesData buildFlBarChartTitlesData() {
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;

    // final userController = Get.put(CUserController());
    // final userCurrency = CHelperFunctions.formatCurrency(
    //   userController.user.value.currencyCode,
    // );
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
              fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
              meta: meta,
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
          interval: weeklySalesHighestAmount.value / 2,
          reservedSize: 40.0,
          getTitlesWidget: (value, TitleMeta meta) {
            return SideTitleWidget(
              meta: meta,
              space: 0,
              fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
              child: Text(
                CFormatter.kSuffixFormatter(value),
                style: TextStyle(
                  color: isConnectedToInternet
                      ? CColors.rBrown
                      : CColors.darkGrey,
                  fontSize: 10.0,
                ),
              ),

              // Text(
              //   '$userCurrency.${CFormatter.kSuffixFormatter(value)}',
              //   style: TextStyle(
              //     color: isConnectedToInternet
              //         ? CColors.rBrown
              //         : CColors.darkGrey,
              //     fontSize: 10.0,
              //   ),
              // ),
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

  @override
  void dispose() {
    txnsController.dateRangeFieldController
        .dispose(); // Dispose of the controller
    showSummaryFilterField.value = false;

    super.dispose();
  }

  filterHourlySales() {
    final timeAt3Hrs = 3 * 60;
    final timeAt6Hrs = 6 * 60;
    final timeAt9Hrs = 9 * 60;
    final timeAt12Hrs = 12 * 60;
    final timeAt15Hrs = 15 * 60;
    final timeAt18Hrs = 18 * 60;
    final timeAt21Hrs = 21 * 60;
    final timeAtMidnight = 24 * 60;

    /// -- sales btn midnight and 3:00hrs --
    var salesBtn0and3 = txnsController.sales.where(
      (sale) {
        var formattedDate = DateTime.parse(
          sale.lastModified.replaceAll(' @', ''),
        );
        final timeInMunites = formattedDate.hour * 60 + formattedDate.minute;
        return timeInMunites >= timeAtMidnight && timeInMunites < timeAt3Hrs;
      },
    ).toList();
    salesBtnMidnightTo3.value = salesBtn0and3.fold(
      0.0,
      (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
    );

    /// -- sales btn 3:00hrs and 6:00hrs --
    var salesBtn3and6 = txnsController.sales.where(
      (sale) {
        var formattedDate = DateTime.parse(
          sale.lastModified.replaceAll(' @', ''),
        );
        final timeInMunites = formattedDate.hour * 60 + formattedDate.minute;
        return timeInMunites >= timeAt3Hrs && timeInMunites < timeAt6Hrs;
      },
    ).toList();

    salesBtn3to6.value = salesBtn3and6.fold(
      0.0,
      (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
    );

    /// -- sales btn 6:00hrs and 9:00hrs --
    var salesBtn6and9 = txnsController.sales.where(
      (sale) {
        var formattedDate = DateTime.parse(
          sale.lastModified.replaceAll(' @', ''),
        );
        final timeInMunites = formattedDate.hour * 60 + formattedDate.minute;
        return timeInMunites >= timeAt6Hrs && timeInMunites < timeAt9Hrs;
      },
    ).toList();

    salesBtn6to9.value = salesBtn6and9.fold(
      0.0,
      (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
    );

    /// -- sales btn 9:00hrs and 12:00hrs --
    var salesBtn9and12 = txnsController.sales.where(
      (sale) {
        var formattedDate = DateTime.parse(
          sale.lastModified.replaceAll(' @', ''),
        );
        final timeInMunites = formattedDate.hour * 60 + formattedDate.minute;
        return timeInMunites >= timeAt9Hrs && timeInMunites < timeAt12Hrs;
      },
    ).toList();
    salesBtn9to12.value = salesBtn9and12.fold(
      0.0,
      (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
    );

    /// -- sales btn 12:00hrs and 15:00hrs --
    var salesBtn12and15 = txnsController.sales.where(
      (sale) {
        var formattedDate = DateTime.parse(
          sale.lastModified.replaceAll(' @', ''),
        );
        final timeInMunites = formattedDate.hour * 60 + formattedDate.minute;
        return timeInMunites >= timeAt12Hrs && timeInMunites < timeAt15Hrs;
      },
    ).toList();

    salesBtn12to15.value = salesBtn12and15.fold(
      0.0,
      (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
    );

    /// -- sales btn 15:00hrs and 18:00hrs --
    var salesBtn15and18 = txnsController.sales.where(
      (sale) {
        var formattedDate = DateTime.parse(
          sale.lastModified.replaceAll(" @", ''),
        );
        final timeInMunites = formattedDate.hour * 60 + formattedDate.minute;
        return timeInMunites >= timeAt15Hrs && timeInMunites < timeAt18Hrs;
      },
    ).toList();

    salesBtn15to18.value = salesBtn15and18.fold(
      0.0,
      (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
    );

    /// -- sales btn 18:00hrs and 21:00hrs --
    var salesBtn18and21 = txnsController.sales.where(
      (sale) {
        var formattedDate = DateTime.parse(
          sale.lastModified.replaceAll(' @', ''),
        );

        final timeInMunites = formattedDate.hour * 60 + formattedDate.minute;

        return timeInMunites >= timeAt18Hrs && timeInMunites < timeAt21Hrs;
      },
    ).toList();

    salesBtn18to21.value = salesBtn18and21.fold(
      0.0,
      (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
    );

    /// -- sales btn 21:00hrs and midnight --
    var salesBtn21andMidght = txnsController.sales.where(
      (sale) {
        var formattedDate = DateTime.parse(
          sale.lastModified.replaceAll(' @', ''),
        );

        final timeInMunites = formattedDate.hour * 60 + formattedDate.minute;
        return timeInMunites >= timeAt21Hrs && timeInMunites < timeAtMidnight;
      },
    ).toList();

    salesBtn21toMidnight.value = salesBtn21andMidght.fold(
      0.0,
      (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
    );

    /// -- peak sales amount --
    peakSalesAmount.value = txnsController.sales.fold(
      0.0,
      (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
    );
  }
}
