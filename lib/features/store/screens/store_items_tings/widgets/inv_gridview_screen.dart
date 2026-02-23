import 'package:cri_v3/common/widgets/loaders/animated_loader.dart';
import 'package:cri_v3/common/widgets/products/product_cards/p_card_vertical.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/search_bar_controller.dart';
import 'package:cri_v3/features/store/controllers/sync_controller.dart';
import 'package:cri_v3/features/store/models/inv_model.dart';
import 'package:cri_v3/features/store/screens/search/widgets/no_results_screen.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:cri_v3/utils/computations/date_time_computations.dart'
    show CDateTimeComputations;
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/img_strings.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/formatter.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CInvGridviewScreen extends StatelessWidget {
  const CInvGridviewScreen({
    super.key,
    this.mainAxisExtent = 176.0,
    //this.mainAxisExtent = double.infinity,
  });

  final double? mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    final invController = Get.put(CInventoryController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final searchController = Get.put(CSearchBarController());
    final syncController = Get.put(CSyncController());
    final userController = Get.put(CUserController());

    AddUpdateItemDialog dialog = AddUpdateItemDialog();

    return Obx(
      () {
        //invController.onInit();

        /// -- empty data widget --
        final noDataWidget = SizedBox(
          height: 200.0,
          child: CAnimatedLoaderWidget(
            actionBtnWidth: 180.0,
            actionBtnText: 'let\'s fill it!',
            animation: CImages.noDataLottie,
            lottieAssetWidth: CHelperFunctions.screenWidth() * 0.42,
            onActionBtnPressed: () {
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (BuildContext context) => dialog.buildDialog(
                  context,
                  CInventoryModel(
                    '',
                    '',
                    '',
                    '',
                    '',
                    0,
                    '',
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
                  false,
                ),
              );
            },
            showActionBtn: true,
            text: 'whoops! store is EMPTY!',
          ),
        );

        if (invController.inventoryItems.isEmpty &&
            !invController.isLoading.value) {
          return noDataWidget;
        }

        if (invController.foundInventoryItems.isEmpty &&
            searchController.showSearchField.value &&
            searchController.txtSearchField.text != '' &&
            !invController.isLoading.value) {
          return const NoSearchResultsScreen();
        }

        return ListView(
          padding: const EdgeInsets.only(
            left: 5.0,
            right: 5.0,
            top: 10.0,
          ),
          shrinkWrap: true,
          children: [
            GridView.builder(
              itemCount: searchController.showSearchField.value
                  ? invController.foundInventoryItems.length
                  : invController.inventoryItems.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: CSizes.gridViewSpacing / 2,
                crossAxisSpacing: CSizes.gridViewSpacing / 2,
                mainAxisExtent: mainAxisExtent,
              ),
              itemBuilder: (context, index) {
                var avatarTxt =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].name[0]
                          .toUpperCase()
                    : invController.inventoryItems[index].name[0].toUpperCase();

                var bp =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].buyingPrice
                    : invController.inventoryItems[index].buyingPrice;

                var dateAdded =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].dateAdded
                    : invController.inventoryItems[index].dateAdded;

                var expiryDate =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].expiryDate
                    : invController.inventoryItems[index].expiryDate;

                var isFavorite =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].markedAsFavorite
                    : invController.inventoryItems[index].markedAsFavorite;

                var isSynced =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].isSynced
                    : invController.inventoryItems[index].isSynced;

                var lastModified =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].lastModified
                    : invController.inventoryItems[index].lastModified;

                var lowStockNotifierLimit =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController
                          .foundInventoryItems[index]
                          .lowStockNotifierLimit
                    : invController.inventoryItems[index].lowStockNotifierLimit;

                var productId =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].productId
                    : invController.inventoryItems[index].productId;

                var pName =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].name
                    : invController.inventoryItems[index].name;

                var itemCalibration =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].calibration
                    : invController.inventoryItems[index].calibration;

                var qtyAvailable =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].quantity
                    : invController.inventoryItems[index].quantity;

                var qtyRefunded =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].qtyRefunded
                    : invController.inventoryItems[index].qtyRefunded;

                var qtySold =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].qtySold
                    : invController.inventoryItems[index].qtySold;

                var sku =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].pCode
                    : invController.inventoryItems[index].pCode;

                var supplierContacts =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].supplierContacts
                    : invController.inventoryItems[index].supplierContacts;

                var supplierName =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].supplierName
                    : invController.inventoryItems[index].supplierName;

                var syncAction =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].syncAction
                    : invController.inventoryItems[index].syncAction;

                var unitBp =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].unitBp
                    : invController.inventoryItems[index].unitBp;

                var usp =
                    searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].unitSellingPrice
                    : invController.inventoryItems[index].unitSellingPrice;

                return CProductCardVertical(
                  bp: bp.toString(),
                  containerHeight: 195.0,
                  //containerHeight: double.infinity,
                  deleteAction: syncController.processingSync.value
                      ? null
                      : () {
                          CInventoryModel itemId;
                          if (invController.foundInventoryItems.isNotEmpty &&
                              searchController.showSearchField.value) {
                            itemId = invController.foundInventoryItems[index];
                          } else {
                            itemId = invController.inventoryItems[index];
                          }
                          invController.deleteInventoryWarningPopup(itemId);
                        },
                  expiryDate: expiryDate != ''
                      ? CFormatter.formatTimeRangeFromNow(
                          expiryDate.replaceAll('@ ', ''),
                        )
                      : 'N/A',

                  expiryColor: expiryDate != ''
                      ? CDateTimeComputations.timeRangeFromNow(
                                  expiryDate.replaceAll('@ ', ''),
                                ) <=
                                0
                            ? CColors.error
                            : CDateTimeComputations.timeRangeFromNow(
                                    expiryDate.replaceAll('@ ', ''),
                                  ) <=
                                  3
                            ? CColors.warning
                            : CColors.darkGrey
                      : CColors.darkGrey,
                  favIconColor: isFavorite == 1 ? CColors.error : CColors.white,

                  isSynced: isSynced.toString(),
                  itemAvatar: avatarTxt,
                  itemMetrics: itemCalibration,
                  itemName: pName,
                  lastModified: lastModified,
                  lowStockNotifierLimit: lowStockNotifierLimit,
                  onAvatarIconTap: syncController.processingSync.value
                      ? null
                      : () {
                          invController.itemExists.value = true;
                          invController.txtSupplierName.text = supplierName;
                          invController.txtSupplierContacts.text =
                              supplierContacts;

                          invController.includeSupplierDetails.value =
                              supplierName != '' || supplierContacts != '';
                          invController.includeExpiryDate.value =
                              expiryDate != '';
                          showDialog(
                            context: context,
                            useRootNavigator: true,
                            builder: (BuildContext context) {
                              invController.currentItemId.value = productId!;

                              return dialog.buildDialog(
                                context,
                                CInventoryModel.withID(
                                  invController.currentItemId.value,
                                  userController.user.value.id,
                                  userController.user.value.email,
                                  userController.user.value.fullName,
                                  sku,
                                  pName,
                                  isFavorite,
                                  itemCalibration,
                                  qtyAvailable,
                                  qtySold,
                                  qtyRefunded,
                                  bp,
                                  unitBp,
                                  usp,
                                  lowStockNotifierLimit,
                                  supplierName,
                                  supplierContacts,
                                  dateAdded,
                                  lastModified,
                                  expiryDate,
                                  isSynced,
                                  syncAction,
                                ),
                                false,
                                false,
                              );
                            },
                          );
                        },
                  onDoubleTapAction: () {
                    Get.toNamed(
                      '/inventory/item_details/',
                      arguments: invController.inventoryItems[index].productId,
                    );
                  },
                  onFavoriteIconTap: () {
                    invController.toggleFavoriteStatus(
                      searchController.showSearchField.value &&
                              invController.foundInventoryItems.isNotEmpty
                          ? invController.foundInventoryItems[index]
                          : invController.inventoryItems[index],
                    );
                  },
                  onTapAction: () {
                    CPopupSnackBar.customToast(
                      message: 'double tap on item to see details!!',
                      forInternetConnectivityStatus: false,
                    );
                  },
                  pCode: sku,
                  pId: productId!,
                  qtyAvailable: itemCalibration == 'units'
                      ? qtyAvailable.toStringAsFixed(0)
                      : qtyAvailable.toString(),
                  qtyRefunded: itemCalibration == 'units'
                      ? qtyRefunded.toStringAsFixed(0)
                      : qtyRefunded.toString(),
                  qtySold: itemCalibration == 'units'
                      ? qtySold.toStringAsFixed(0)
                      : qtySold.toString(),
                  syncAction: syncAction,
                  titleColor: expiryDate != ''
                      ? CDateTimeComputations.timeRangeFromNow(
                                  expiryDate.replaceAll('@ ', ''),
                                ) <=
                                0
                            ? CColors.error
                            : CDateTimeComputations.timeRangeFromNow(
                                    expiryDate.replaceAll('@ ', ''),
                                  ) <=
                                  3
                            ? CColors.warning
                            : CColors.rBrown
                      : isDarkTheme
                      ? CColors.white
                      : CColors.rBrown,
                  usp: usp.toString(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
