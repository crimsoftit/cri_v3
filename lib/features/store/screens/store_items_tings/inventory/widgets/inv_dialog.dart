import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/models/inv_model.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/inventory/widgets/inv_dialog_form.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddUpdateItemDialog {
  Widget buildDialog(
    BuildContext context,
    CInventoryModel invModel,
    bool isNew,
  ) {
    var textStyle = Theme.of(context).textTheme.bodySmall;

    final invController = Get.put(CInventoryController());

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
    }

    return PopScope(
      canPop: false,
      child: AlertDialog(
        //backgroundColor: isDarkTheme ? CColors.rBrown.withValues(alpha: 0.4),
        insetPadding: const EdgeInsets.all(2.0),
        title: Obx(
          () => Row(
            children: [
              Expanded(
                child: Text(
                  (invController.itemExists.value)
                      ? 'update ${invController.txtNameController.text.trim()}'
                      : 'add inventory...',
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // const SizedBox(
              //   width: CSizes.spaceBtnInputFields / 2,
              // ),
              Visibility(
                visible: invController.supplierDetailsExist.value
                    ? false
                    : true,
                child: Expanded(
                  child: TextButton(
                    onPressed: () {
                      invController.toggleSupplierDetsFieldsVisibility();
                    },
                    child: Text(
                      invController.includeSupplierDetails.value
                          ? 'exclude supplier details?'
                          : 'include supplier details?',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium!.apply(color: CColors.rBrown),
                    ),
                  ),
                ),
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
            textStyle: textStyle,
            inventoryItem: invModel,
          ),
        ),
      ),
    );
  }
}
