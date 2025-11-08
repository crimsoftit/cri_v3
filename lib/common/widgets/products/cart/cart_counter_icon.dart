import 'package:cri_v3/common/widgets/products/cart/positioned_cart_counter_widget.dart';
import 'package:cri_v3/features/store/controllers/checkout_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CCartCounterIcon extends StatelessWidget {
  const CCartCounterIcon({
    super.key,
    this.iconColor,
    this.counterBgColor,
    this.counterTxtColor,
  });

  final Color? iconColor, counterBgColor, counterTxtColor;

  @override
  Widget build(BuildContext context) {
    //cartController.fetchCartItems();
    final checkoutController = Get.put(CCheckoutController());

    return Stack(
      children: [
        IconButton(
          onPressed: () async {
            checkoutController.handleNavToCheckout();
          },
          icon: Icon(Iconsax.shopping_bag, color: iconColor),
        ),
        CPositionedCartCounterWidget(
          counterBgColor: CColors.white,
          counterTxtColor: CColors.rBrown,
        ),
      ],
    );
  }
}
