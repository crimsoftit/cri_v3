import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/dashboard_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeeklySalesBarGraphWidget extends StatelessWidget {
  const WeeklySalesBarGraphWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.put(CDashboardController());
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    final userController = Get.put(CUserController());
    final userCurrency = CHelperFunctions.formatCurrency(
      userController.user.value.currencyCode,
    );
    return Column(
      children: [
        CSectionHeading(
          showActionBtn: true,
          title: 'weekly sales...',
          // txtColor: CColors.white,
          txtColor: CColors.rBrown,
          btnTitle: '',
          btnTxtColor: CColors.grey,
          editFontSize: true,
          onPressed: () {},
        ),

        Obx(
          () {
            /// -- compare last week's total sales to this week's --

            dashboardController.weeklyPercentageChange.value =
                ((dashboardController.currentWeekSales.value -
                        dashboardController.lastWeekSales.value) /
                    dashboardController.lastWeekSales.value) *
                100;
            return CRoundedContainer(
              bgColor: CColors.white,
              borderRadius: CSizes.cardRadiusSm,
              padding: const EdgeInsets.only(
                top: 15.0,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: CHelperFunctions.screenWidth(),
                    height: 55.0,
                    child: Stack(
                      children: [
                        // dashboardController.currentWeekSales.value > 0 &&
                        //         dashboardController.lastWeekSales.value > 0
                        //     ? Column(
                        //         children: [
                        //           Positioned(
                        //             right: 0,
                        //             top: 10.0,
                        //             child:
                        //                 dashboardController
                        //                         .weeklyPercentageChange
                        //                         .value >=
                        //                     0.0
                        //                 ? Icon(
                        //                     Iconsax.trend_up,
                        //                     color: Colors.green,
                        //                     size: CSizes.iconMd,
                        //                   )
                        //                 : Icon(
                        //                     Iconsax.trend_down,
                        //                     color: Colors.red,
                        //                     size: CSizes.iconMd,
                        //                   ),
                        //           ),
                        //           Positioned(
                        //             top: 0,
                        //             right: 27.0,
                        //             child: Text(
                        //               'trend:${dashboardController.weeklyPercentageChange.value.toStringAsFixed(2)}%',
                        //               style: Theme.of(context)
                        //                   .textTheme
                        //                   .labelMedium!
                        //                   .apply(
                        //                     color:
                        //                         dashboardController
                        //                                 .weeklyPercentageChange
                        //                                 .value <
                        //                             0
                        //                         ? Colors.redAccent
                        //                         : dashboardController
                        //                                   .weeklyPercentageChange
                        //                                   .value ==
                        //                               0.0
                        //                         ? CColors.rBrown
                        //                         : Colors.green,
                        //                   ),
                        //             ),
                        //           ),
                        //           Positioned(
                        //             top: 15.0,
                        //             right: 27.0,
                        //             child: Text(
                        //               '$userCurrency.${dashboardController.lastWeekSales.value.toStringAsFixed(2)}(last week)',
                        //               style: Theme.of(context)
                        //                   .textTheme
                        //                   .labelSmall!
                        //                   .apply(
                        //                     color: CColors.rBrown,
                        //                     fontStyle: FontStyle.italic,
                        //                   ),
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        //     : SizedBox.shrink(),
                        Positioned(
                          top:
                              dashboardController.currentWeekSales.value > 0 &&
                                  dashboardController.lastWeekSales.value > 0
                              ? 30.0
                              : 0,
                          right:
                              dashboardController.currentWeekSales.value > 0 &&
                                  dashboardController.lastWeekSales.value > 0
                              ? 27.0
                              : 5.0,
                          child: Column(
                            children: [
                              Text(
                                '$userCurrency.${dashboardController.currentWeekSales.value.toStringAsFixed(2)}(this week)',
                                style: Theme.of(context).textTheme.labelSmall!
                                    .apply(
                                      color: CColors.rBrown,
                                      //color: CColors.black,
                                      fontSizeDelta:
                                          dashboardController
                                                      .currentWeekSales
                                                      .value >
                                                  0 &&
                                              dashboardController
                                                      .lastWeekSales
                                                      .value >
                                                  0
                                          ? 1.0
                                          : 2.0,
                                      fontWeightDelta:
                                          dashboardController
                                                      .currentWeekSales
                                                      .value >
                                                  0 &&
                                              dashboardController
                                                      .lastWeekSales
                                                      .value >
                                                  0
                                          ? 1
                                          : 2,
                                    ),
                              ),
                              Text(
                                '$userCurrency.${dashboardController.lastWeekSales.value.toStringAsFixed(2)}(last week)',
                                style: Theme.of(context).textTheme.labelSmall!
                                    .apply(
                                      color: CColors.rBrown,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200.0,
                    child: BarChart(
                      BarChartData(
                        titlesData: dashboardController.buildFlTitlesData(),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            top: BorderSide.none,
                            right: BorderSide.none,
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          drawVerticalLine: false,
                          horizontalInterval: 200,
                        ),
                        barGroups: dashboardController.weeklySales
                            .asMap()
                            .entries
                            .map(
                              (entry) => BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    width: 25.0,
                                    toY: entry.value,
                                    color: isConnectedToInternet
                                        ? CColors.rBrown
                                        : CColors.darkerGrey,
                                    borderRadius: BorderRadius.circular(
                                      CSizes.sm,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                        groupsSpace: CSizes.spaceBtnItems / 2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) {
                              return CColors.secondary;
                            },
                          ),
                          touchCallback:
                              (
                                barTouchEvent,
                                barTouchResponse,
                              ) {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
