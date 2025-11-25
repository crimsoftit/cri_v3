import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/models/inv_model.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:cri_v3/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AddUpdateInventoryForm extends StatelessWidget {
  const AddUpdateInventoryForm({
    super.key,
    required this.invController,
    required this.textStyle,
    required this.inventoryItem,
  });

  final CInventoryController invController;
  final TextStyle? textStyle;
  final CInventoryModel inventoryItem;

  @override
  Widget build(BuildContext context) {
    //AddUpdateItemDialog dialog = AddUpdateItemDialog();
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return Column(
      children: <Widget>[
        const SizedBox(height: CSizes.spaceBtnInputFields / 2),
        // form to handle input data
        Form(
          key: invController.addInvItemFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                maintainState: true,
                visible: false,
                child: Column(
                  children: [
                    TextFormField(
                      controller: invController.txtId,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'product id',
                        labelStyle: textStyle,
                      ),
                    ),
                    TextFormField(
                      controller: invController.txtSyncAction,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'sync action',
                        labelStyle: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: invController.txtCode,
                //readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDarkTheme
                      ? CColors.transparent
                      : CColors.lightGrey,
                  labelText: 'barcode/sku',
                  labelStyle: textStyle,
                  prefixIcon: invController.txtCode.text.isNotEmpty
                      ? Icon(
                          Iconsax.barcode,
                          color: CColors.darkGrey,
                          size: CSizes.iconXs,
                        )
                      : TextButton.icon(
                          onPressed: () {
                            invController.txtCode.text =
                                invController.txtCode.text.isNotEmpty
                                ? invController.txtCode.text = ''
                                : CHelperFunctions.generateProductCode()
                                      .toString();
                          },
                          icon: Icon(
                            Iconsax.flash,
                            size: CSizes.iconXs,
                            color: CColors.rBrown,
                          ),
                          label: Text(
                            invController.txtCode.text.isEmpty
                                ? 'auto'
                                : 'clear',
                            style: Theme.of(context).textTheme.labelSmall!
                                .apply(
                                  color: CColors.rBrown,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                  suffixIcon: IconButton(
                    icon: const Icon(Iconsax.scan, size: CSizes.iconSm),
                    color: CColors.rBrown,
                    onPressed: () {
                      invController.scanBarcodeNormal();
                    },
                  ),
                ),
                onChanged: (barcodeValue) {
                  invController.fetchItemByCodeAndEmail(barcodeValue);
                },
                style: const TextStyle(fontWeight: FontWeight.normal),
                validator: (value) {
                  return CValidator.validateBarcode('barcode value', value);
                },
              ),
              const SizedBox(height: CSizes.spaceBtnInputFields / 1.5),

              // -- product name field --
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: invController.txtNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDarkTheme
                      ? CColors.transparent
                      : CColors.lightGrey,
                  labelText: 'product name',
                  labelStyle: textStyle,
                  prefixIcon: Icon(
                    Iconsax.tag,
                    color: CColors.darkGrey,
                    size: CSizes.iconXs,
                  ),
                ),
                style: const TextStyle(fontWeight: FontWeight.normal),
                validator: (value) {
                  return CValidator.validateEmptyText('product name', value);
                },
              ),
              const SizedBox(height: CSizes.spaceBtnInputFields / 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // -- stock qty field --
                  SizedBox(
                    width: CHelperFunctions.screenWidth() * .38,
                    height: 60.0,
                    child: TextFormField(
                      controller: invController.txtQty,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                        signed: false,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(fontWeight: FontWeight.normal),
                      decoration: InputDecoration(
                        constraints: BoxConstraints(minHeight: 60.0),
                        contentPadding: const EdgeInsets.only(left: 2.0),
                        filled: true,
                        fillColor: isDarkTheme
                            ? CColors.transparent
                            : CColors.lightGrey,
                        labelStyle: textStyle,
                        labelText: 'qty/no. of units',
                        maintainHintSize: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Icon(
                            Iconsax.quote_up,
                            color: CColors.darkGrey,
                            size: CSizes.iconXs,
                          ),
                        ),
                      ),
                      validator: (value) {
                        return CValidator.validateNumber('qty', value);
                      },
                      onChanged: (value) {
                        if (invController.txtBP.text.isNotEmpty &&
                            value.isNotEmpty) {
                          invController.computeUnitBP(
                            double.parse(invController.txtBP.text.trim()),
                            int.parse(value.trim()),
                          );
                        }

                        if (value.isNotEmpty) {
                          invController.computeLowStockThreshold(
                            int.parse(value.trim()),
                          );
                        }
                      },
                    ),
                  ),

                  // -- unit selling price field --
                  SizedBox(
                    width: CHelperFunctions.screenWidth() * .45,
                    height: 60.0,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: invController.txtUnitSP,
                      decoration: InputDecoration(
                        constraints: BoxConstraints(minHeight: 60.0),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                        ),
                        filled: true,
                        fillColor: isDarkTheme
                            ? CColors.transparent
                            : CColors.lightGrey,
                        labelStyle: textStyle,
                        labelText: 'unit selling price',
                        maintainHintSize: true,
                        prefixIcon: Icon(
                          Iconsax.bitcoin_card,
                          color: CColors.darkGrey,
                          size: CSizes.iconXs,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+(\.\d*)?'),
                        ),
                      ],
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        height: 1.5,
                      ),
                      validator: (value) {
                        return CValidator.validateNumber('usp', value);
                      },
                    ),
                  ),
                ],
              ),
              // const SizedBox(
              //   height: CSizes.spaceBtnInputFields / 1.5,
              // ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // -- textfield for low stock threshold limit
                      SizedBox(
                        width: CHelperFunctions.screenWidth() * .38,
                        height: 60.0,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: invController.txtStockNotifierLimit,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                            signed: false,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            constraints: BoxConstraints(minHeight: 60.0),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0.0,
                            ),
                            filled: true,
                            fillColor: isDarkTheme
                                ? CColors.transparent
                                : CColors.lightGrey,
                            // label: Container(
                            //   transform: Matrix4.translationValues(
                            //     10.0,
                            //     0.0,
                            //     0.0,
                            //   ),
                            //   child: Text(
                            //     'threshold',
                            //   ),
                            // ),
                            // labelStyle: textStyle,
                            labelText: 'alert threshold',
                            prefixIcon: Icon(
                              // Iconsax.card_pos,
                              Iconsax.quote_down,
                              color: CColors.darkGrey,
                              size: CSizes.iconXs,
                            ),
                          ),
                          onChanged: (value) {},
                          style: const TextStyle(fontWeight: FontWeight.normal),
                          validator: (value) {
                            return CValidator.validateNumber(
                              'alert threshold',
                              value,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8.5),

                      // -- buying price textfield --
                      SizedBox(
                        width: CHelperFunctions.screenWidth() * .45,
                        height: 60.0,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: invController.txtBP,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+(\.\d*)?'),
                            ),
                          ],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 1.0,
                            ),
                            constraints: BoxConstraints(minHeight: 60.0),
                            filled: true,
                            fillColor: isDarkTheme
                                ? CColors.transparent
                                : CColors.lightGrey,
                            labelStyle: textStyle,
                            labelText: 'buying price',
                            prefixIcon: Icon(
                              // Iconsax.card_pos,
                              Iconsax.bitcoin_card,
                              color: CColors.darkGrey,
                              size: CSizes.iconXs,
                            ),
                          ),
                          onChanged: (value) {
                            if (invController.txtQty.text.isNotEmpty &&
                                value.isNotEmpty) {
                              invController.computeUnitBP(
                                double.parse(value),
                                int.parse(invController.txtQty.text),
                              );
                            }
                          },
                          style: const TextStyle(fontWeight: FontWeight.normal),
                          validator: (value) {
                            return CValidator.validateNumber(
                              'buying price',
                              value,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    final userController = Get.put(CUserController());
                    final currency = CHelperFunctions.formatCurrency(
                      userController.user.value.currencyCode,
                    );

                    // -- display unit buying price
                    return Visibility(
                      visible:
                          invController.txtBP.text.isEmpty &&
                              invController.txtQty.text.isEmpty
                          ? false
                          : true,
                      replacement: SizedBox.shrink(),
                      child: Container(
                        padding: const EdgeInsets.all(0.0),
                        width: CHelperFunctions.screenWidth() * .95,
                        height:
                            invController.txtBP.text.isEmpty &&
                                invController.txtQty.text.isEmpty
                            ? 0
                            : 10.0,
                        alignment: Alignment.topRight,
                        child: Text(
                          'unit BP: ~$currency.${invController.unitBP.value.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.labelSmall!.apply(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    );
                  }),
                  //const SizedBox(height: CSizes.spaceBtnInputFields / 1.5),

                  // -- expiry date field --
                  TextFormField(
                    //autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: invController.txtExpiryDatePicker,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkTheme
                          ? CColors.transparent
                          : CColors.lightGrey,
                      labelText: 'pick expiry date',
                      labelStyle: textStyle,
                      prefixIcon: Icon(
                        Iconsax.calendar,
                        color: CColors.darkGrey,
                        size: CSizes.iconXs,
                      ),
                    ),
                    onTap: () async {
                      invController.pickExpiryDate();
                    },
                    style: const TextStyle(fontWeight: FontWeight.normal),
                    // validator: (value) {
                    //   return CValidator.validateEmptyText('expiry date', value);
                    // },
                  ),
                ],
              ),

              Obx(() {
                return Visibility(
                  visible: invController.includeSupplierDetails.value,
                  child: Column(
                    children: [
                      const SizedBox(height: CSizes.spaceBtnInputFields),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: invController.txtSupplierName,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkTheme
                              ? CColors.transparent
                              : CColors.lightGrey,
                          labelText: 'supplier name (optional)',
                          labelStyle: textStyle,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(height: CSizes.spaceBtnInputFields / 2),
                      TextFormField(
                        controller: invController.txtSupplierContacts,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkTheme
                              ? CColors.transparent
                              : CColors.lightGrey,
                          labelText: 'supplier contacts (optional)',
                          labelStyle: textStyle,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: CSizes.spaceBtnInputFields),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Obx(() {
                      return TextButton.icon(
                        icon: const Icon(
                          Iconsax.save_add,
                          size: CSizes.iconSm,
                          color: CColors.white,
                        ),
                        label: Text(
                          invController.itemExists.value ? 'update' : 'add',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium!.apply(color: CColors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              CColors.white, // foreground (text) color
                          backgroundColor: CColors.rBrown, // background color
                        ),
                        onPressed: () async {
                          // -- form validation
                          if (!invController.addInvItemFormKey.currentState!
                              .validate()) {
                            return;
                          }
                          if (invController.txtUnitSP.text.isNotEmpty &&
                              invController.unitBP.value > 0) {
                            if (invController.unitBP.value >
                                double.parse(invController.txtUnitSP.text)) {
                              invController.confirmUspUbpModal(context);
                              // CPopupSnackBar.warningSnackBar(
                              //   title:
                              //       'is this the right unit selling price?',
                              // );
                            }
                          }

                          // invController
                          //     .addOrUpdateInventoryItem(inventoryItem);

                          if (await invController.addOrUpdateInventoryItem(
                            inventoryItem,
                          )) {
                            Navigator.pop(Get.overlayContext!, true);
                          } else {
                            CPopupSnackBar.errorSnackBar(
                              title: 'error adding/updating inventory item ',
                            );
                            return;
                          }
                        },
                      );
                    }),
                  ),
                  const SizedBox(width: CSizes.spaceBtnSections / 4),
                  Expanded(
                    flex: 4,
                    child: TextButton.icon(
                      icon: const Icon(
                        Iconsax.undo,
                        size: CSizes.iconSm,
                        color: CColors.rBrown,
                      ),
                      label: Text(
                        'back',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium!.apply(color: Colors.red),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.red, // foreground (text) color
                        backgroundColor: CColors.white, // background color
                      ),
                      onPressed: () {
                        invController.fetchUserInventoryItems();

                        Navigator.pop(context, true);
                        invController.resetInvFields();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
