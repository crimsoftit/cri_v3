import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/switches/custom_switch.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/models/inv_model.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/inventory/widgets/inv_dialog_form.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddUpdateItemDialog {
  Widget buildDialog(
    BuildContext context,
    CInventoryModel invModel,
    bool isNew,
    bool fromHomeScreen,
  ) {
    final invController = Get.put(CInventoryController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    var textStyle = Theme.of(context).textTheme.bodySmall;

    if (!isNew) {
      invController.txtId.text = invModel.productId.toString();
      invController.txtNameController.text =
          invController.txtNameController.text.isEmpty
          ? invModel.name
          : invController.txtNameController.text.trim();
      invController.txtCode.text = invController.txtCode.text.isEmpty
          ? invModel.pCode.toString()
          : invController.txtCode.text.trim();
      invController.txtQty.text = invController.txtQty.text.isEmpty
          ? invModel.quantity.toString()
          : invController.txtQty.text.trim();
      invController.txtBP.text = invController.txtBP.text.isEmpty
          ? invModel.buyingPrice.toString()
          : invController.txtBP.text.trim();
      invController.unitBP.value = invModel.unitBp;
      invController.txtUnitSP.text = invController.txtUnitSP.text.isEmpty
          ? invModel.unitSellingPrice.toString()
          : invController.txtUnitSP.text.trim();
      invController.txtStockNotifierLimit.text =
          invController.txtStockNotifierLimit.text.isEmpty
          ? invModel.lowStockNotifierLimit.toString()
          : invController.txtStockNotifierLimit.text.trim();
      invController.txtExpiryDatePicker.text =
          invController.txtExpiryDatePicker.text.trim().isEmpty
          ? invModel.expiryDate
          : invController.txtExpiryDatePicker.text.trim();
    }

    return PopScope(
      canPop: false,
      child: CRoundedContainer(
        bgColor: isDarkTheme
            ? CColors.transparent
            : CColors.white.withValues(alpha: 0.6),
        child: AlertDialog(
          backgroundColor: isDarkTheme
              ? CColors.rBrown
              : CColors.darkGrey.withValues(alpha: 0.3),
          insetPadding: const EdgeInsets.all(2.0),
          title: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  (invController.itemExists.value)
                      ? Icons.update
                      : Icons.add_circle,
                  color: isDarkTheme ? CColors.white : CColors.rBrown,
                  size: CSizes.iconLg * 1.5,
                ),
                Obx(
                  () {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // -- toggle entry for supplier details --
                        CCustomSwitch(
                          label: 'supplier details',
                          labelColor: isDarkTheme
                              ? CColors.darkGrey
                              : CColors.rBrown,
                          onValueChanged: (value) {
                            invController.toggleSupplierDetsFieldsVisibility(
                              value,
                            );
                          },
                          switchValue:
                              invController.includeSupplierDetails.value,
                        ),

                        // -- toggle entry for expiry date --
                        CCustomSwitch(
                          label: 'expiry date',
                          labelColor: isDarkTheme
                              ? CColors.darkGrey
                              : CColors.rBrown,
                          onValueChanged: (value) {
                            invController.toggleExpiryDateFieldVisibility(
                              value,
                            );
                          },
                          switchValue: invController.includeExpiryDate.value,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: SingleChildScrollView(
            child: AddUpdateInventoryForm(
              invController: invController,
              inventoryItem: invModel,
              fromHomeScreen: fromHomeScreen,
              textStyle: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
