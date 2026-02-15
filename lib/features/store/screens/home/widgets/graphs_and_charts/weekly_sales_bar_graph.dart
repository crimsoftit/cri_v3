import 'package:cri_v3/common/widgets/buttons/custom_dropdown_btn.dart';
import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/txt_widgets/c_section_headings.dart';
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
    return Column(
      children: [
        CSectionHeading(
          actionWidget: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 8.0,
              ),
              child: CRoundedContainer(
                borderRadius: 10.0,
                height: 40.0,
                padding: const EdgeInsets.all(
                  5.0,
                ),
                showBorder: true,
                child: CCustomDropdownBtn(
                  dropdownItems: dashboardController.salesFilters,
                  selectedValue: dashboardController
                      .setDefaultSalesFilterPeriod(),
                  onValueChanged: (value) {},
                  underlineColor: CColors.rBrown,
                  underlineHeight: 0,
                ),
              ),
            ),
          ),
          showActionBtn: true,
          title: 'sales summary...',
          txtColor: CNetworkManager.instance.hasConnection.value
              ? CColors.rBrown
              : CColors.darkGrey,

          btnTitle: '',
          btnTxtColor: CColors.rBrown,
          editFontSize: true,
          fWeight: FontWeight.w400,
          onPressed: () {},
        ),
        const SizedBox(
          height: CSizes.defaultSpace / 2,
        ),

        Obx(
          () {
            /// -- compare last week's total sales to this week's --

            dashboardController.weeklyPercentageChange.value =
                ((dashboardController.currentWeekSalesAmount.value -
                        dashboardController.lastWeekSalesAmount.value) /
                    dashboardController.lastWeekSalesAmount.value) *
                100;
            return CRoundedContainer(
              bgColor: CColors.white,
              borderRadius: CSizes.cardRadiusSm / 2,
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              width: CHelperFunctions.screenWidth(),
              child: Column(
                children: [
                  // SizedBox(
                  //   width: CHelperFunctions.screenWidth(),
                  //   height: 55.0,
                  //   child: Stack(
                  //     children: [
                  //       Positioned(
                  //         top:
                  //             dashboardController.currentWeekSales.value > 0 &&
                  //                 dashboardController.lastWeekSales.value > 0
                  //             ? 30.0
                  //             : 0,
                  //         right:
                  //             dashboardController.currentWeekSales.value > 0 &&
                  //                 dashboardController.lastWeekSales.value > 0
                  //             ? 27.0
                  //             : 5.0,
                  //         child: Column(
                  //           children: [
                  //             Text(
                  //               '$userCurrency.${dashboardController.currentWeekSales.value.toStringAsFixed(2)}(this week)',
                  //               style: Theme.of(context).textTheme.labelSmall!
                  //                   .apply(
                  //                     color: CColors.rBrown,
                  //                     //color: CColors.black,
                  //                     fontSizeDelta:
                  //                         dashboardController
                  //                                     .currentWeekSales
                  //                                     .value >
                  //                                 0 &&
                  //                             dashboardController
                  //                                     .lastWeekSales
                  //                                     .value >
                  //                                 0
                  //                         ? 1.0
                  //                         : 2.0,
                  //                     fontWeightDelta:
                  //                         dashboardController
                  //                                     .currentWeekSales
                  //                                     .value >
                  //                                 0 &&
                  //                             dashboardController
                  //                                     .lastWeekSales
                  //                                     .value >
                  //                                 0
                  //                         ? 1
                  //                         : 2,
                  //                   ),
                  //             ),
                  //             Text(
                  //               '$userCurrency.${dashboardController.lastWeekSales.value.toStringAsFixed(2)}(last week)',
                  //               style: Theme.of(context).textTheme.labelSmall!
                  //                   .apply(
                  //                     color: CColors.rBrown,
                  //                   ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    //width: CHelperFunctions.screenWidth() * .5,
                    height: 150.0,
                    child: BarChart(
                      BarChartData(
                        titlesData: dashboardController
                            .buildFlBarChartTitlesData(),
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
                          drawVerticalLine: true,
                          horizontalInterval:
                              dashboardController
                                  .weeklySalesHighestAmount
                                  .value /
                              4,
                          verticalInterval:
                              dashboardController
                                  .weeklySalesHighestAmount
                                  .value /
                              4,
                        ),
                        barGroups: dashboardController.thisWeekSalesList
                            .asMap()
                            .entries
                            .map(
                              (entry) => BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    width: 17.0,
                                    toY: entry.value,
                                    color: isConnectedToInternet
                                        ? CColors.rBrown
                                        : CColors.darkerGrey,
                                    borderRadius: BorderRadius.circular(
                                      CSizes.sm / 4,
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
