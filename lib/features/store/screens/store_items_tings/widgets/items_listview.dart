import 'package:cri_v3/common/widgets/layouts/c_expansion_tile.dart';
import 'package:cri_v3/common/widgets/shimmers/vert_items_shimmer.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/personalization/screens/no_data/no_data_screen.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/features/store/controllers/search_bar_controller.dart';
import 'package:cri_v3/features/store/screens/search/widgets/no_results_screen.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/img_strings.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CItemsListView extends StatelessWidget {
  const CItemsListView({super.key, required this.space});

  final String space;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final invController = Get.put(CInventoryController());
    final salesController = Get.put(CTxnsController());
    final searchController = Get.put(CSearchBarController());
    final userController = Get.put(CUserController());

    final userCurrencyCode = CHelperFunctions.formatCurrency(
      userController.user.value.currencyCode,
    );

    return Obx(() {
      if (searchController.txtSearchField.text.isNotEmpty &&
          salesController.foundSales.isEmpty &&
          space == 'sales' &&
          !salesController.isLoading.value) {
        return const NoSearchResultsScreen();
      }

      if (searchController.txtSearchField.text.isNotEmpty &&
          salesController.foundRefunds.isEmpty &&
          space == 'refunds') {
        return const NoSearchResultsScreen();
      }

      if (!searchController.showSearchField.value &&
          salesController.sales.isEmpty &&
          space == 'sales') {
        return const Center(
          child: NoDataScreen(
            lottieImage: CImages.noDataLottie,
            txt: 'No data found!',
          ),
        );
      }

      if (!searchController.showSearchField.value &&
          salesController.refunds.isEmpty &&
          space == 'refunds') {
        return const Center(
          child: NoDataScreen(
            lottieImage: CImages.noDataLottie,
            txt: 'No data found!',
          ),
        );
      }

      /// -- compute ListView.builder's itemCount --
      var itemsCount = 0;
      switch (space) {
        case "sales":
          itemsCount = salesController.foundSales.isNotEmpty
              ? salesController.foundSales.length
              : salesController.sales.length;
          break;
        case "refunds":
          itemsCount = salesController.foundRefunds.isNotEmpty
              ? salesController.foundRefunds.length
              : salesController.refunds.length;
        default:
          itemsCount = 0;
          CPopupSnackBar.errorSnackBar(title: 'invalid tab space');
      }

      // -- run loader --
      if (salesController.txnsSyncIsLoading.value ||
          invController.syncIsLoading.value) {
        return const CVerticalProductShimmer(itemCount: 5);
      }

      return ListView(
        shrinkWrap: true,
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(2.0),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: itemsCount,
            itemBuilder: (context, index) {
              var txnId = 0;

              var avatarTxt = '';
              var itemIsSynced = 0;
              var itemName = '';
              var itemProductId = 0;

              var qtyRefunded = 0;
              var qtySold = 0;
              var syncAction = '';
              var txnAmount = 0.0;
              var txnModifiedDate = '';
              var txnStatus = '';
              var unitSellingPrice = 0.0;

              switch (space) {
                case "refunds":
                  txnId = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].txnId
                      : salesController.refunds[index].txnId;

                  avatarTxt = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].productName[0]
                            .toUpperCase()
                      : salesController.refunds[index].productName[0]
                            .toUpperCase();

                  itemIsSynced = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].isSynced
                      : salesController.refunds[index].isSynced;

                  itemProductId = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].productId
                      : salesController.refunds[index].productId;

                  itemName = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].productName
                      : salesController.refunds[index].productName;

                  qtyRefunded = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].qtyRefunded
                      : salesController.refunds[index].qtyRefunded;

                  qtySold = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].quantity
                      : salesController.refunds[index].quantity;

                  syncAction = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].syncAction
                      : salesController.refunds[index].syncAction;

                  txnAmount = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].totalAmount
                      : salesController.refunds[index].totalAmount;

                  txnModifiedDate = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].lastModified
                      : salesController.refunds[index].lastModified;

                  txnStatus = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].txnStatus
                      : salesController.refunds[index].txnStatus;

                  unitSellingPrice = salesController.foundRefunds.isNotEmpty
                      ? salesController.foundRefunds[index].unitSellingPrice
                      : salesController.refunds[index].unitSellingPrice;
                  break;
                case "sales":
                  txnId = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].txnId
                      : salesController.sales[index].txnId;

                  avatarTxt = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].productName[0]
                            .toUpperCase()
                      : salesController.sales[index].productName[0]
                            .toUpperCase();

                  itemIsSynced = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].isSynced
                      : salesController.sales[index].isSynced;

                  itemProductId = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].productId
                      : salesController.sales[index].productId;

                  itemName = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].productName
                      : salesController.sales[index].productName;

                  qtyRefunded = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].qtyRefunded
                      : salesController.sales[index].qtyRefunded;

                  qtySold = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].quantity
                      : salesController.sales[index].quantity;

                  syncAction = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].syncAction
                      : salesController.sales[index].syncAction;

                  txnAmount = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].totalAmount
                      : salesController.sales[index].totalAmount;

                  txnModifiedDate = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].lastModified
                      : salesController.sales[index].lastModified;

                  txnStatus = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].txnStatus
                      : salesController.sales[index].txnStatus;

                  unitSellingPrice = salesController.foundSales.isNotEmpty
                      ? salesController.foundSales[index].unitSellingPrice
                      : salesController.sales[index].unitSellingPrice;
                default:
                  txnId = 0;
                  avatarTxt = '';
                  itemIsSynced = 0;
                  itemsCount = 0;
                  itemName = '';
                  qtyRefunded = 0;
                  qtySold = 0;
                  syncAction = '';
                  txnAmount = 0.0;
                  txnModifiedDate = '';
                  txnStatus = '';
                  unitSellingPrice = 0.0;
                  CPopupSnackBar.errorSnackBar(title: 'invalid tab space');
              }

              return Column(
                children: [
                  Card(
                    color: isDarkTheme
                        ? CColors.rBrown.withValues(alpha: 0.3)
                        : CColors.lightGrey,
                    elevation: 0.3,
                    child: CExpansionTile(
                      avatarTxt: avatarTxt,
                      includeRefundBtn: space == 'sales' ? true : false,
                      isSynced: 'isSynced: $itemIsSynced',
                      subTitleTxt1Item1:
                          't.Amount: $userCurrencyCode.$txnAmount ',
                      subTitleTxt1Item2:
                          '($qtySold sold, $qtyRefunded refunded)',
                      subTitleTxt2Item1: '@$userCurrencyCode.$unitSellingPrice',
                      subTitleTxt2Item2: 'txn #$txnId',
                      subTitleTxt3Item1: txnModifiedDate,
                      subTitleTxt3Item2: 'product id: $itemProductId',
                      syncAction: 'syncAction: $syncAction',
                      txnStatus: 'txnStatus: $txnStatus',
                      titleTxt: itemName.toUpperCase(),
                      btn1Txt: 'info',
                      btn2Txt: space == 'inventory' ? 'sell' : 'update',
                      btn2Icon: space == 'inventory'
                          ? const Icon(
                              Iconsax.card_pos,
                              color: CColors.rBrown,
                              size: CSizes.iconSm,
                            )
                          : const Icon(
                              Iconsax.edit,
                              color: CColors.rBrown,
                              size: CSizes.iconSm,
                            ),
                      btn1NavAction: () {
                        if (space == 'inventory') {
                          Get.toNamed(
                            '/inventory/item_details/',
                            arguments:
                                invController.foundInventoryItems.isNotEmpty
                                ? invController
                                      .foundInventoryItems[index]
                                      .productId
                                : invController.inventoryItems[index].productId,
                          );
                        }
                        if (space == 'sales') {
                          Get.toNamed(
                            '/sales/txn_details',
                            arguments: salesController.foundSales.isNotEmpty
                                ? salesController.foundSales[index].soldItemId
                                : salesController.sales[index].soldItemId,
                          );
                        }
                      },
                      btn2NavAction: space == 'inventory'
                          ? () {
                              salesController.onSellItemBtnAction(
                                invController.foundInventoryItems[index],
                              );
                            }
                          : null,
                      refundBtnAction: () {
                        salesController.refundItemActionModal(
                          context,
                          salesController.foundSales.isNotEmpty
                              ? salesController.foundSales[index]
                              : salesController.sales[index],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      );
    });
  }
}
