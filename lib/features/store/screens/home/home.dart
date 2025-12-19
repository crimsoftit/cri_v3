import 'package:cri_v3/common/styles/shadows.dart';
import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/dates/date_picker_widget.dart';
import 'package:cri_v3/common/widgets/dividers/custom_divider.dart';
import 'package:cri_v3/common/widgets/products/cart/cart_counter_icon.dart';
import 'package:cri_v3/common/widgets/search_bar/animated_search_bar.dart';
import 'package:cri_v3/common/widgets/shimmers/horizontal_items_shimmer.dart';
import 'package:cri_v3/common/widgets/sliders/auto_img_slider.dart';
import 'package:cri_v3/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/dashboard_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/nav_menu_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/features/store/models/inv_model.dart';
import 'package:cri_v3/features/store/screens/home/widgets/dashboard_header.dart';
import 'package:cri_v3/features/store/screens/home/widgets/fresh_dashboard_screen_view.dart';
import 'package:cri_v3/features/store/screens/home/widgets/store_summary_card.dart';
import 'package:cri_v3/features/store/screens/home/widgets/top_sellers.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:cri_v3/nav_menu.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/constants/txt_strings.dart';
import 'package:cri_v3/utils/helpers/formatter.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// -- TODO: do peak transaction hours & days --

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final cartController = Get.put(CCartController());
    AddUpdateItemDialog dialog = AddUpdateItemDialog();
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
    //Get.put(CTxnsController());
    txnsController.fetchTopSellersFromSales();

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
                padding: const EdgeInsets.only(
                  left: 18.0,
                  right: 18.0,
                  top: 10.0,
                ),
                child: Obx(() {
                  if (invController.inventoryItems.isEmpty &&
                      !invController.isLoading.value) {
                    invController.fetchUserInventoryItems();
                    txnsController.fetchTopSellersFromSales();
                  }
                  if (invController.isLoading.value &&
                      invController.inventoryItems.isNotEmpty) {
                    return CHorizontalProductShimmer();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (txnsController.bestSellers.isNotEmpty)
                        /// -- store summary --
                        CRoundedContainer(
                          bgColor: CColors.transparent,
                          borderColor: CColors.grey,
                          borderRadius: CSizes.cardRadiusSm / 2.5,
                          boxShadow: [CShadowStyle.verticalProductShadow],
                          padding: const EdgeInsets.all(3.0),
                          showBorder: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: CAnimatedSearchBar(
                                  controller: dashboardController
                                      .dateRangeFieldController,
                                  customTxtField: CDateRangePickerWidget(),
                                  useCustomTxtField: true,
                                  hintTxt: '',
                                ),
                              ),
                              //CDateRangePickerWidget(),
                              const SizedBox(height: CSizes.defaultSpace / 4),
                              Obx(() {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CStoreSummaryCard(
                                      iconData: Iconsax.tag,
                                      subTitleTxt: 'g.revenue',
                                      titleTxt:
                                          '$userCurrency.${CFormatter.kSuffixFormatter(txnsController.totalRevenue.value..toStringAsFixed(1))}',
                                    ),
                                    CStoreSummaryCard(
                                      iconData: Iconsax.money_send,
                                      subTitleTxt: 'cost of sales',
                                      titleTxt:
                                          '$userCurrency.${CFormatter.kSuffixFormatter(txnsController.costOfSales.value..toStringAsFixed(1))}',
                                    ),
                                    CStoreSummaryCard(
                                      iconData: Iconsax.money_tick,
                                      subTitleTxt: 'g. profit($userCurrency)',
                                      titleTxt: txnsController.totalProfit.value
                                          .toStringAsFixed(1),
                                    ),
                                  ],
                                );
                              }),
                              const SizedBox(height: CSizes.defaultSpace / 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CStoreSummaryCard(
                                    iconData: Iconsax.tag,
                                    subTitleTxt: 'complete txns',
                                    titleTxt: CFormatter.kSuffixFormatter(1000),
                                  ),
                                  CStoreSummaryCard(
                                    iconData: Iconsax.money_send,
                                    subTitleTxt: 'pending txns',
                                    titleTxt: CFormatter.kSuffixFormatter(1500),
                                  ),
                                  CStoreSummaryCard(
                                    iconData: Iconsax.money_tick,
                                    subTitleTxt: 'expired items',
                                    titleTxt: CFormatter.kSuffixFormatter(200),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // txnsController.bestSellers.isEmpty ||
                      //         invController.inventoryItems.isEmpty
                      txnsController.bestSellers.isEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: CSizes.defaultSpace),

                                  //CCarouselSlider(),
                                  CAutoImgSlider(),
                                  const SizedBox(
                                    height: CSizes.defaultSpace / 1.5,
                                  ),
                                  Text(
                                    'welcome aboard!!'.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .apply(
                                          // color: isDarkTheme
                                          //     ? CColors.darkGrey
                                          //     : CColors.rBrown,
                                          color: CColors.rBrown,
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
                          : Column(
                              children: [
                                /// -- top sellers --
                                CSectionHeading(
                                  showActionBtn: true,
                                  title: 'top sellers...',
                                  // txtColor: CColors.white,
                                  txtColor: isDarkTheme
                                      ? CColors.darkGrey
                                      : CColors.rBrown,
                                  btnTitle: 'view all',
                                  btnTxtColor: CColors.grey,
                                  editFontSize: true,
                                  fWeight: FontWeight.w400,
                                  onPressed: () {
                                    navController.selectedIndex.value = 1;
                                    Get.to(() => const NavMenu());
                                  },
                                ),
                                CTopSellers(),
                              ],
                            ),

                      //if (txnsController.bestSellers.isNotEmpty)

                      /// -- weekly sales bar graph --
                      Obx(() {
                        /// -- compare last week's total sales to this week's --

                        dashboardController.weeklyPercentageChange.value =
                            ((dashboardController.currentWeekSales.value -
                                    dashboardController.lastWeekSales.value) /
                                dashboardController.lastWeekSales.value) *
                            100;

                        if (txnsController.sales.isEmpty) {
                          return Column(
                            children: [
                              SizedBox(height: CSizes.defaultSpace),
                              Center(
                                child: invController.inventoryItems.isEmpty
                                    ? CFreshDashboardScreenView(
                                        iconData: Icons.add,
                                        label:
                                            'add your first inventory item to get started!',
                                        onTap: () {
                                          invController.resetInvFields();
                                          showDialog(
                                            context: context,
                                            useRootNavigator: false,
                                            builder: (BuildContext context) =>
                                                dialog.buildDialog(
                                                  context,
                                                  CInventoryModel(
                                                    '',
                                                    '',
                                                    '',
                                                    '',
                                                    '',
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0.0,
                                                    0.0,
                                                    0.0,
                                                    0,
                                                    '',
                                                    '',
                                                    '',
                                                    '',
                                                    '',
                                                    0,
                                                    '',
                                                  ),
                                                  true,
                                                  true,
                                                ),
                                          );
                                        },
                                      )
                                    : CFreshDashboardScreenView(
                                        iconData: Iconsax.tag,
                                        label:
                                            'your perfect brand awaits! make your first sale...',
                                        onTap: () {
                                          navController.selectedIndex.value = 1;
                                        },
                                      ),
                              ),
                            ],
                          );
                        }
                        return dashboardController.currentWeekSales.value > 0
                            ? CRoundedContainer(
                                bgColor: isDarkTheme
                                    ? CColors.darkGrey
                                    : CColors.white,
                                //bgColor: CColors.grey,
                                borderRadius: CSizes.cardRadiusSm / 2.5,
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
                                          dashboardController
                                                          .currentWeekSales
                                                          .value >
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
                                                              color:
                                                                  Colors.green,
                                                              size:
                                                                  CSizes.iconMd,
                                                            )
                                                          : Icon(
                                                              Iconsax
                                                                  .trend_down,
                                                              color: Colors.red,
                                                              size:
                                                                  CSizes.iconMd,
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
                                                                  ? Colors
                                                                        .redAccent
                                                                  : dashboardController
                                                                            .weeklyPercentageChange
                                                                            .value ==
                                                                        0.0
                                                                  ? CColors
                                                                        .rBrown
                                                                  : Colors
                                                                        .green,
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
                                                              color: CColors
                                                                  .rBrown,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
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
                                            child: CRoundedContainer(
                                              bgColor: CColors.transparent,
                                              width:
                                                  CHelperFunctions.screenWidth() *
                                                  .85,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'weekly sales...',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .apply(
                                                          color: CColors.rBrown,
                                                        ),
                                                  ),
                                                  Text(
                                                    '$userCurrency.${dashboardController.currentWeekSales.value.toStringAsFixed(2)}(this week)',
                                                    style: Theme.of(context).textTheme.labelSmall!.apply(
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
                                                ],
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
                                          barGroups: dashboardController
                                              .weeklySales
                                              .asMap()
                                              .entries
                                              .map(
                                                (entry) => BarChartGroupData(
                                                  x: entry.key,
                                                  barRods: [
                                                    BarChartRodData(
                                                      width: 25.0,
                                                      toY: entry.value,
                                                      color:
                                                          isConnectedToInternet
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
                                            touchTooltipData:
                                                BarTouchTooltipData(
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
                              )
                            : CFreshDashboardScreenView(
                                iconData: Icons.add,
                                label:
                                    'add your first inventory item to get started!',
                                onTap: () {
                                  invController.resetInvFields();
                                  showDialog(
                                    context: context,
                                    useRootNavigator: false,
                                    builder: (BuildContext context) =>
                                        dialog.buildDialog(
                                          context,
                                          CInventoryModel(
                                            '',
                                            '',
                                            '',
                                            '',
                                            '',
                                            0,
                                            0,
                                            0,
                                            0,
                                            0.0,
                                            0.0,
                                            0.0,
                                            0,
                                            '',
                                            '',
                                            '',
                                            '',
                                            '',
                                            0,
                                            '',
                                          ),
                                          true,
                                          true,
                                        ),
                                  );
                                },
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
