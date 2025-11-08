import 'package:cri_v3/features/store/controllers/cart_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CAddToCartBtn extends StatelessWidget {
  const CAddToCartBtn({super.key, required this.pId});

  final int pId;

  @override
  Widget build(BuildContext context) {
    final invController = Get.put(CInventoryController());

    return Obx(() {
      final cartController = CCartController.instance;
      final pQtyInCart = cartController.getItemQtyInCart(pId);
      var invItem = invController.inventoryItems.firstWhere(
        (item) => item.productId.toString() == pId.toString().toLowerCase(),
      );
      return InkWell(
        onTap: () {
          cartController.fetchCartItems();

          final cartItem = cartController.convertInvToCartItem(invItem, 1);
          cartController.addSingleItemToCart(cartItem, false, null);
        },
        child: Container(
          decoration: BoxDecoration(
            color: pQtyInCart > 0
                ? Colors.orange
                : invItem.quantity <= invItem.lowStockNotifierLimit
                ? Colors.red
                : CNetworkManager.instance.hasConnection.value
                ? CColors.rBrown
                : CColors.darkerGrey,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(CSizes.cardRadiusMd - 4),
              bottomRight: Radius.circular(CSizes.pImgRadius - 4),
            ),
          ),
          child: SizedBox(
            width: CSizes.iconLg,
            height: CSizes.iconLg,
            child: Center(
              child: pQtyInCart > 0
                  ? Text(
                      pQtyInCart.toString(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.apply(color: CColors.white),
                    )
                  : const Icon(Iconsax.add, color: CColors.white),
            ),
          ),
        ),
      );
    });
  }
}
