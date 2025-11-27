import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/dividers/custom_divider.dart';
import 'package:cri_v3/common/widgets/products/cart/cart_counter_icon.dart';
import 'package:cri_v3/common/widgets/shimmers/horizontal_items_shimmer.dart';
import 'package:cri_v3/common/widgets/sliders/carousel_slider.dart';
import 'package:cri_v3/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/dashboard_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/nav_menu_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/features/store/screens/home/widgets/dashboard_header.dart';
import 'package:cri_v3/features/store/screens/home/widgets/fresh_dashboard_screen_view.dart';
import 'package:cri_v3/features/store/screens/home/widgets/top_sellers.dart';
import 'package:cri_v3/nav_menu.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/constants/txt_strings.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// -- TODO: set widget for a freshly registered account -with no sales --

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final cartController = Get.put(CCartController());
    final dashboardController = Get.put(CDashboardController());

    final invController = Get.put(CInventoryController());
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    final navController = Get.put(CNavMenuController());
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());
    final userCurrency = CHelperFunctions.formatCurrency(
      userController.user.value.currencyCode,
    );

    Get.put(CDashboardController());

    return Container(
      color: isDarkTheme ? CColors.transparent : CColors.white,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 0.5, right: 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Iconsax.menu, size: 25.0, color: CColors.rBrown),
                CCartCounterIcon(iconColor: CColors.rBrown),
              ],
            ),
          ),
        ),
        backgroundColor: CColors.rBrown.withValues(alpha: 0.2),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: CSizes.defaultSpace / 4.0),

              /// -- dashboard header widget --
              DashboardHeaderWidget(
                actionsSection: SizedBox.shrink(),
                appBarTitle: CTexts.homeAppbarTitle,
                isHomeScreen: true,
                screenTitle: '',
                showAppBarTitle: false,
              ),

              /// -- custom divider --
              CCustomDivider(),

              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 0),
                child: Obx(() {
                  if (invController.inventoryItems.isEmpty &&
                      !invController.isLoading.value) {
                    invController.fetchUserInventoryItems();
                  }
                  if (invController.isLoading.value &&
                      invController.inventoryItems.isNotEmpty) {
                    return CHorizontalProductShimmer();
                  }

                  /// -- top sellers --
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (invController.topSellers.isNotEmpty)
                        CSectionHeading(
                          showActionBtn: true,
                          title: 'top sellers...',
                          // txtColor: CColors.white,
                          txtColor: CColors.rBrown,
                          btnTitle: 'view all',
                          btnTxtColor: CColors.grey,
                          editFontSize: true,
                          onPressed: () {
                            navController.selectedIndex.value = 1;
                            Get.to(() => const NavMenu());
                          },
                        ),
                      invController.topSellers.isEmpty ||
                              invController.inventoryItems.isEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: CSizes.defaultSpace),

                                  CCarouselSlider(),
                                  const SizedBox(height: CSizes.defaultSpace),
                                  Text(
                                    'welcome aboard!!'.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .apply(
                                          color: isDarkTheme
                                              ? CColors.darkGrey
                                              : CColors.rBrown,
                                          fontSizeFactor: 1.3,
                                          fontWeightDelta: -2,
                                        ),
                                  ),
                                  const SizedBox(
                                    height: CSizes.defaultSpace / 2,
                                  ),
                                  Text(
                                    'your perfect dashboard is just a few sales away!'
                                        .toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .apply(
                                          color: isDarkTheme
                                              ? CColors.darkGrey
                                              : CColors.rBrown,
                                        ),
                                  ),

                                  // Text(
                                  //   'your perfect dashboard is just a few sales away.\n \nstart adding products/items to your inventory and make your first sale today!'
                                  //       .toUpperCase(),
                                  //   style: Theme.of(
                                  //     context,
                                  //   ).textTheme.labelMedium!.apply(),
                                  // ),
                                ],
                              ),
                            )
                          : CTopSellers(),

                      if (invController.topSellers.isNotEmpty)
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

                      /// -- weekly sales bar graph --
                      Obx(() {
                        /// -- compare last week's total sales to this week's --

                        dashboardController.weeklyPercentageChange.value =
                            ((dashboardController.currentWeekSales.value -
                                    dashboardController.lastWeekSales.value) /
                                dashboardController.lastWeekSales.value) *
                            100;
                        if (invController.inventoryItems.isEmpty &&
                            txnsController.sales.isEmpty) {
                          return Column(
                            children: [
                              SizedBox(height: CSizes.defaultSpace),
                              Center(child: CFreshDashboardScreenView()),
                            ],
                          );
                        }
                        return CRoundedContainer(
                          // bgColor:
                          //     isDarkTheme ? CColors.darkGrey : CColors.grey,
                          bgColor: CColors.grey,
                          borderRadius: CSizes.cardRadiusSm,
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: CHelperFunctions.screenWidth(),
                                height: 45.0,
                                child: Stack(
                                  children: [
                                    // CircularPercentIndicator(
                                    //   radius: 100.0,
                                    //   lineWidth: 10.0,
                                    //   percent:
                                    //       0.7, // Represents 70% sales progress
                                    //   center: Text(
                                    //     "70%",
                                    //     style: TextStyle(
                                    //         fontWeight: FontWeight.bold,
                                    //         fontSize: 20.0),
                                    //   ),
                                    //   footer: Text(
                                    //     "Sales this week",
                                    //     style: TextStyle(
                                    //         fontWeight: FontWeight.bold,
                                    //         fontSize: 17.0),
                                    //   ),
                                    //   progressColor: Colors.green,
                                    // ),
                                    dashboardController.currentWeekSales.value >
                                                0 &&
                                            dashboardController
                                                    .lastWeekSales
                                                    .value >
                                                0
                                        ? Stack(
                                            children: [
                                              Positioned(
                                                right: 0,
                                                top: 10.0,
                                                child:
                                                    dashboardController
                                                            .weeklyPercentageChange
                                                            .value >=
                                                        0.0
                                                    ? Icon(
                                                        Iconsax.trend_up,
                                                        color: Colors.green,
                                                        size: CSizes.iconMd,
                                                      )
                                                    : Icon(
                                                        Iconsax.trend_down,
                                                        color: Colors.red,
                                                        size: CSizes.iconMd,
                                                      ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 27.0,
                                                child: Text(
                                                  dashboardController
                                                              .weeklyPercentageChange
                                                              .value >
                                                          0
                                                      ? 'trend: +${dashboardController.weeklyPercentageChange.value.toStringAsFixed(2)}%'
                                                      : 'trend: ${dashboardController.weeklyPercentageChange.value.toStringAsFixed(2)}%',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .apply(
                                                        color:
                                                            dashboardController
                                                                    .weeklyPercentageChange
                                                                    .value <
                                                                0
                                                            ? Colors.redAccent
                                                            : dashboardController
                                                                      .weeklyPercentageChange
                                                                      .value ==
                                                                  0.0
                                                            ? CColors.rBrown
                                                            : Colors.green,
                                                      ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 15.0,
                                                right: 27.0,
                                                child: Text(
                                                  '$userCurrency.${dashboardController.lastWeekSales.value.toStringAsFixed(2)}(last week)',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall!
                                                      .apply(
                                                        color: CColors.rBrown,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : SizedBox.shrink(),

                                    Positioned(
                                      top:
                                          dashboardController
                                                      .currentWeekSales
                                                      .value >
                                                  0 &&
                                              dashboardController
                                                      .lastWeekSales
                                                      .value >
                                                  0
                                          ? 30.0
                                          : 0,
                                      right:
                                          dashboardController
                                                      .currentWeekSales
                                                      .value >
                                                  0 &&
                                              dashboardController
                                                      .lastWeekSales
                                                      .value >
                                                  0
                                          ? 27.0
                                          : 5.0,
                                      child: Text(
                                        '$userCurrency.${dashboardController.currentWeekSales.value.toStringAsFixed(2)}(this week)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
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
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 200.0,
                                child: BarChart(
                                  BarChartData(
                                    titlesData: dashboardController
                                        .buildFlTitlesData(),
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
                                                borderRadius:
                                                    BorderRadius.circular(
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
                                          (barTouchEvent, barTouchResponse) {},
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


