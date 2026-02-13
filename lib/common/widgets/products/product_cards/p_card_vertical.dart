import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/buttons/icon_buttons/circular_icon_btn.dart';
import 'package:cri_v3/common/widgets/products/cart/add_to_cart_btn.dart';
import 'package:cri_v3/common/widgets/products/circle_avatar.dart';
import 'package:cri_v3/common/widgets/shimmers/shimmer_effects.dart';
import 'package:cri_v3/common/widgets/txt_widgets/product_price_txt.dart';
import 'package:cri_v3/common/widgets/txt_widgets/product_title_txt.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/formatter.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CProductCardVertical extends StatelessWidget {
  const CProductCardVertical({
    super.key,
    required this.itemName,
    required this.pCode,
    required this.pId,
    this.bp,
    this.lastModified,
    this.expiryDate,
    this.deleteAction,
    this.favIconColor,
    this.favIconData,
    this.isSynced,
    this.expiryColor,
    this.itemAvatar,
    this.lowStockNotifierLimit,
    this.onAvatarIconTap,
    this.onDoubleTapAction,
    this.onFavoriteIconTap,
    this.onTapAction,
    this.itemMetrics,
    this.qtyAvailable,
    this.qtyRefunded,
    this.qtySold,
    this.syncAction,
    this.usp,
    required this.containerHeight,
  });

  final double containerHeight;
  final Color? expiryColor, favIconColor;
  final double? lowStockNotifierLimit;
  final int pId;
  final IconData? favIconData;
  final String? bp,
      expiryDate,
      lastModified,
      isSynced,
      itemAvatar,
      itemMetrics,
      qtyAvailable,
      qtyRefunded,
      qtySold,
      syncAction,
      usp;
  final String itemName, pCode;

  final VoidCallback? deleteAction,
      onAvatarIconTap,
      onDoubleTapAction,
      onFavoriteIconTap,
      onTapAction;

  @override
  Widget build(BuildContext context) {
    final invController = Get.put(CInventoryController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    //final syncController = Get.put(CSyncController());
    final txnsController = Get.put(CTxnsController());

    return GestureDetector(
      onDoubleTap: onDoubleTapAction,
      onTap: onTapAction,
      child: CRoundedContainer(
        bgColor: isDarkTheme
            ? CColors.rBrown.withValues(alpha: 0.3)
            : CColors.lightGrey,
        width: 170,
        height: double.infinity,
        padding: EdgeInsets.all(1.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: CSizes.spaceBtnInputFields / 5),

            /// -- avatar, favorite item, and delete btns --
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                invController.isLoading.value &&
                        invController.inventoryItems.isNotEmpty
                    ? CShimmerEffect(
                        width: 30,
                        height: 30.0,
                        radius: 30.0,
                      )
                    : CCircularIconBtn(
                        bgColor: isDarkTheme
                            ? CColors.transparent
                            : CColors.rBrown.withValues(alpha: 0.2),
                        iconColor:
                            favIconColor ??
                            (isDarkTheme ? CColors.white : CColors.rBrown),
                        icon: favIconData ?? Iconsax.heart5,
                        iconSize: CSizes.md,
                        height: 33.0,
                        onPressed: onFavoriteIconTap,
                        width: 33.0,
                      ),
                invController.isLoading.value &&
                        invController.inventoryItems.isNotEmpty
                    ? CShimmerEffect(
                        width: 40,
                        height: 40.0,
                        radius: 40.0,
                      )
                    : CCircleAvatar(
                        avatarInitial: itemAvatar!,
                        // bgColor: int.parse(qtyAvailable!) <
                        //         lowStockNotifierLimit!
                        //     ? Colors.red
                        //     : CColors.rBrown,
                        bgColor: CColors.transparent,
                        editIconColor:
                            double.parse(qtyAvailable!) < lowStockNotifierLimit!
                            ? Colors.red
                            : isDarkTheme
                            ? CColors.white
                            : CColors.rBrown,
                        includeEditBtn: true,
                        onEdit: onAvatarIconTap,
                        txtColor:
                            double.parse(qtyAvailable!) < lowStockNotifierLimit!
                            ? Colors.red
                            : isDarkTheme
                            ? CColors.white
                            : CColors.rBrown,
                      ),

                invController.isLoading.value &&
                        invController.inventoryItems.isNotEmpty
                    ? CShimmerEffect(
                        width: 30,
                        height: 30.0,
                        radius: 30.0,
                      )
                    : CCircularIconBtn(
                        iconColor: isDarkTheme ? CColors.white : Colors.red,
                        icon: Icons.delete,
                        iconSize: CSizes.md,
                        height: 33.0,
                        width: 33.0,
                        // bgColor: isDarkTheme
                        //     ? CColors.transparent
                        //     : CColors.white,
                        bgColor: isDarkTheme
                            ? CColors.transparent
                            : CColors.rBrown.withValues(alpha: 0.2),
                        //  CColors.transparent,
                        onPressed: deleteAction,
                      ),
              ],
            ),
            const SizedBox(
              height: CSizes.spaceBtnInputFields / 4.0,
            ),

            /// -- date/last modified --
            invController.isLoading.value &&
                    invController.inventoryItems.isNotEmpty
                ? Center(
                    child: CShimmerEffect(
                      width: 150,
                      height: 10.0,
                      radius: 10.0,
                    ),
                  )
                : Center(
                    child: Text(
                      CFormatter.formatTimeRangeFromNow(
                            lastModified!.replaceAll(
                              '@ ',
                              '',
                            ),
                          ).contains('just now')
                          ? 'modified: ${CFormatter.formatTimeRangeFromNow(lastModified!.replaceAll('@ ', ''))}'
                          : CFormatter.formatTimeRangeFromNow(
                              lastModified!.replaceAll(
                                '@ ',
                                '',
                              ),
                            ),
                      //lastModified!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall!.apply(
                        color: isDarkTheme ? CColors.grey : CColors.darkGrey,
                        fontSizeFactor: 0.9,
                      ),
                    ),
                  ),

            CProductTitleText(
              //smallSize: true,
              title:
                  CHelperFunctions.txtExceedsTwoLines(
                    "${itemName.toUpperCase()} (${CFormatter.formatItemMetrics(itemMetrics!)}(s)} stocked, $qtySold sold)",
                    Theme.of(context).textTheme.labelSmall!,
                  )
                  ? "${itemName.toUpperCase()} ($qtyAvailable ${CFormatter.formatItemMetrics(itemMetrics!)}(s)} stocked; $qtySold sold)"
                  : "${itemName.toUpperCase()} ($qtyAvailable ${CFormatter.formatItemMetrics(itemMetrics!)}(s) stocked; $qtySold ${CFormatter.formatItemMetrics(itemMetrics!)}(s) sold)",
              // title: CHelperFunctions.txtExceedsTwoLines(
              //   "${itemName.toUpperCase()} ($qtyAvailable ${itemMetrics == 'units' ? itemMetrics : '${CFormatter.formatItemMetrics(itemMetrics!)}(s)'} stocked, $qtySold sold)",
              //   Theme.of(context).textTheme.labelSmall!,
              // )
              // ? "${itemName.toUpperCase()} ($qtyAvailable ${itemMetrics == 'units' ? itemMetrics : '${CFormatter.formatItemMetrics(itemMetrics!)}(s)'} stocked, $qtySold sold)"
              // : "${itemName.toUpperCase()} ($qtyAvailable ${itemMetrics == 'units' ? itemMetrics : '${CFormatter.formatItemMetrics(itemMetrics!)}(s)'} stocked, $qtySold ${itemMetrics == 'units' ? itemMetrics : '${CFormatter.formatItemMetrics(itemMetrics!)}(s)'} sold)",
              txtColor: double.parse(qtyAvailable!) < lowStockNotifierLimit!
                  ? Colors.red
                  : isDarkTheme
                  ? CColors.white
                  : CColors.rBrown,
              maxLines: 2,
            ),

            // Text(
            //   '($qtyRefunded ${itemCalibration == 'units' ? itemCalibration : '${itemCalibration}s'} refunded)',
            //   style: Theme.of(context).textTheme.labelSmall!.apply(
            //     color: isDarkTheme ? CColors.white : CColors.darkGrey,
            //   ),
            // ),
            Text(
              '($qtyRefunded ${CFormatter.formatItemMetrics(itemMetrics!)}(s) refunded)',
              style: Theme.of(context).textTheme.labelSmall!.apply(
                color: isDarkTheme ? CColors.white : CColors.darkGrey,
              ),
            ),
            Text(
              'sku: $pCode lsn: ${CFormatter.formatItemQtyDisplays(lowStockNotifierLimit!, itemMetrics!)}',
              style: Theme.of(context).textTheme.labelSmall!.apply(
                color: isDarkTheme ? CColors.white : CColors.darkGrey,
              ),
            ),
            Visibility(
              visible: false,
              child: Text(
                'isSynced: $isSynced, syncAction: $syncAction',
                style: Theme.of(context).textTheme.labelSmall!.apply(
                  color: isDarkTheme ? CColors.white : CColors.darkGrey,
                ),
              ),
            ),
            Text(
              'expiry date: $expiryDate',
              style: Theme.of(context).textTheme.labelSmall!.apply(
                color:
                    expiryColor ??
                    (isDarkTheme ? CColors.white : CColors.rBrown),
              ),
            ),
            CProductPriceTxt(
              priceCategory: 'bp: ',
              price: bp!,
              maxLines: 1,
              isLarge: true,
              txtColor: isDarkTheme ? CColors.white : CColors.darkGrey,
              fSizeFactor: 0.7,
            ),

            /// -- base buttons --
            SizedBox(
              /// -- TODO:
              // chora cart item usp * qtyInCart
              // also catch socketexception when syncing data
              width: CHelperFunctions.screenWidth(),
              height: 43.0,
              child: Obx(() {
                return Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      child: CProductPriceTxt(
                        // priceCategory: 'price: ',
                        priceCategory: '@',
                        price: usp!,
                        maxLines: 1,
                        isLarge: true,
                        txtColor: isDarkTheme ? CColors.white : CColors.rBrown,
                        fSizeFactor: 0.9,
                      ),
                    ),

                    /// -- add item to cart button --
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child:
                          (invController.isLoading.value ||
                                  txnsController.isLoading.value) &&
                              invController.inventoryItems.isNotEmpty
                          ? CShimmerEffect(
                              width: 32.0,
                              height: 32.0,
                              radius: 8.0,
                            )
                          : CAddToCartBtn(pId: pId),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
