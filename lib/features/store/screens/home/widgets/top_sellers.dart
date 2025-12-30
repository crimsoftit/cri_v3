import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/products/circle_avatar.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CTopSellers extends StatelessWidget {
  const CTopSellers({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final invController = Get.put(CInventoryController());
    final txnsController = Get.put(CTxnsController());

    return Obx(() {
      

      return SizedBox(
        height: 40.0,
        child: ListView.separated(
          itemCount: txnsController.bestSellers.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (_, __) {
            return SizedBox(width: CSizes.spaceBtnItems / 2);
          },
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                var itemIndex = invController.inventoryItems.indexWhere(
                  (item) =>
                      item.productId ==
                      txnsController.bestSellers[index].productId,
                );

                if (itemIndex >= 0) {
                  Get.toNamed(
                    '/inventory/item_details/',
                    arguments: txnsController.bestSellers[index].productId,
                  );
                } else {
                  CPopupSnackBar.warningSnackBar(
                    message: 'this item is nolonger listed in your inventory',
                    title: 'item not found/deleted',
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CCircleAvatar(
                    avatarInitial: txnsController
                        .bestSellers[index]
                        .productName[0]
                        .toUpperCase(),
                    bgColor: CColors.white,
                    radius: 20.0,
                    txtColor: CColors.rBrown,
                  ),
                  const SizedBox(width: CSizes.spaceBtnItems / 5),
                  CRoundedContainer(
                    bgColor: CColors.transparent,
                    showBorder: false,
                    width: 90.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          txnsController.bestSellers[index].productName
                              .toUpperCase(),
                          style: Theme.of(context).textTheme.labelMedium!.apply(
                            fontWeightDelta: 1,
                            color: isDarkTheme ? CColors.white : CColors.rBrown,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '${txnsController.bestSellers[index].totalSales} sold',
                          style: Theme.of(context).textTheme.labelMedium!.apply(
                            color: CColors.darkGrey,
                          ),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
