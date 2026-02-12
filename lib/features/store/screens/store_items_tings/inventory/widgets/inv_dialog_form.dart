import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/date_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/nav_menu_controller.dart';
import 'package:cri_v3/features/store/models/inv_model.dart';
import 'package:cri_v3/nav_menu.dart' show NavMenu;
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/formatter.dart';
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
    required this.fromHomeScreen,
  });

  final bool fromHomeScreen;
  final CInventoryModel inventoryItem;
  final CInventoryController invController;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final navController = Get.put(CNavMenuController());
    //final notsController = Get.put(CLocalNotificationsController());

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
                            color: isDarkTheme
                                ? CColors.darkGrey
                                : CColors.rBrown,
                          ),
                          label: Text(
                            invController.txtCode.text.isEmpty
                                ? 'auto'
                                : 'clear',
                            style: Theme.of(context).textTheme.labelSmall!
                                .apply(
                                  color: isDarkTheme
                                      ? CColors.darkGrey
                                      : CColors.rBrown,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                  suffixIcon: IconButton(
                    icon: const Icon(Iconsax.scan, size: CSizes.iconSm),
                    color: isDarkTheme ? CColors.darkGrey : CColors.rBrown,
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
              const SizedBox(
                height: CSizes.spaceBtnInputFields / 1.5,
              ),

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
              const SizedBox(
                height: CSizes.spaceBtnInputFields / 1.5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // -- item metrics dropdown button --
                  SizedBox(
                    width: CHelperFunctions.screenWidth() * .42,
                    height: 55.0,
                    child: Obx(
                      () {
                        return DropdownButton<String>(
                          borderRadius: BorderRadius.circular(12),
                          items: invController.demMetrics.map(
                            (
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: Theme.of(context).textTheme.labelLarge!
                                      .apply(
                                        color: isDarkTheme
                                            ? CColors.white
                                            : CColors.rBrown,
                                      ),
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            if (value != '') {
                              invController.itemMetrics.value = value!;
                            }
                          },
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                            color: CColors.rBrown,
                          ),
                          dropdownColor: isDarkTheme
                              ? CColors.rBrown
                              : CColors.white.withValues(
                                  alpha: 0.6,
                                ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: isDarkTheme ? CColors.white : CColors.rBrown,
                          ),
                          underline: Container(
                            // color: isDarkTheme ? CColors.white : CColors.rBrown,
                            color: CColors.white,
                            height: 2,
                          ),
                          padding: const EdgeInsets.only(
                            left: 5.0,
                            right: 5.0,
                          ),
                          value: invController.setItemMetrics(),
                        );
                      },
                    ),
                  ),
                  // Obx(
                  //   () {
                  //     return SizedBox(
                  //       width: CHelperFunctions.screenWidth() * .42,
                  //       height: 65.0,
                  //       child: DropdownButtonFormField<String>(
                  //         decoration: InputDecoration(
                  //           constraints: BoxConstraints(minHeight: 60.0),
                  //           // contentPadding: const EdgeInsets.symmetric(
                  //           //   horizontal: 2.0,
                  //           // ),
                  //           contentPadding: const EdgeInsets.only(
                  //             left: 1.0,
                  //           ),
                  //           filled: true,
                  //           fillColor: isDarkTheme
                  //               ? CColors.transparent
                  //               : CColors.lightGrey,

                  //           labelStyle: textStyle,
                  //           labelText: 'metric unit',

                  //           maintainHintSize: true,
                  //           prefixIcon: Icon(
                  //             Iconsax.quote_down_circle,
                  //             color: CColors.darkGrey,
                  //             size: CSizes.iconXs,
                  //           ),
                  //         ),
                  //         initialValue:
                  //             invController.itemCalibration.value != ''
                  //             ? invController.itemCalibration.value
                  //             : null,
                  //         // hint: Text(
                  //         //   'metric unit',
                  //         //   style: Theme.of(context).textTheme.labelMedium,
                  //         // ),
                  //         onChanged: (String? newValue) {
                  //           if (newValue != '' || newValue != null) {
                  //             invController.itemCalibration.value = newValue!;
                  //           }
                  //         },
                  //         validator: (String? value) {
                  //           if (value == null || value.isEmpty) {
                  //             return 'unit of measurement is required';
                  //           }
                  //           return null;
                  //         },
                  //         items:
                  //             <String>[
                  //               'units',
                  //               'litre',
                  //               'kg',
                  //             ].map<DropdownMenuItem<String>>((String value) {
                  //               return DropdownMenuItem<String>(
                  //                 value: value,
                  //                 child: Text(value),
                  //               );
                  //             }).toList(),
                  //       ),
                  //     );
                  //   },
                  // ),

                  // -- inventory qty field --
                  SizedBox(
                    width: CHelperFunctions.screenWidth() * .42,
                    height: 55.0,
                    child: Obx(
                      () {
                        return TextFormField(
                          controller: invController.txtQty,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}$'),
                            ),
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
                            //labelText:  'qty (units, kg, litre)',
                            labelText:
                                'qty in ${CFormatter.formatItemMetrics(invController.itemMetrics.value)}(s):',
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
                            return CValidator.validateNumber(
                              'qty/no. of units',
                              value,
                            );
                          },
                          onChanged: (value) {
                            if (invController.txtBP.text.isNotEmpty &&
                                value.isNotEmpty) {
                              invController.computeUnitBP(
                                double.parse(invController.txtBP.text.trim()),
                                double.parse(value.trim()),
                              );
                            }

                            if (value.isNotEmpty) {
                              invController.computeLowStockThreshold(
                                double.parse(value.trim()),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              Obx(
                () {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // -- buying price textfield --
                      SizedBox(
                        width: CHelperFunctions.screenWidth() * .42,
                        height: 55.0,
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
                            constraints: BoxConstraints(minHeight: 40.0),
                            filled: true,
                            fillColor: isDarkTheme
                                ? CColors.transparent
                                : CColors.lightGrey,
                            labelStyle: textStyle,
                            labelText: 'buying price:',
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
                                double.parse(invController.txtQty.text),
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

                      SizedBox(
                        width: CSizes.spaceBtnInputFields / 2.5,
                      ),

                      // -- unit selling price field --
                      SizedBox(
                        width: CHelperFunctions.screenWidth() * .42,
                        height: 55.0,
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
                            labelText:
                                invController.itemMetrics.value == '' ||
                                    (invController.itemMetrics.value != '' &&
                                        invController.itemMetrics.value ==
                                            'units')
                                ? 'unit selling price:'
                                : 'selling price per ${invController.itemMetrics.value}:',
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
                            return CValidator.validateNumber(
                              'unit selling price',
                              value,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              // const SizedBox(
              //   height: CSizes.spaceBtnInputFields / 1.5,
              // ),
              Obx(
                () {
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
                },
              ),
              TextFormField(
                // autovalidateMode: AutovalidateMode.onUserInteraction,
                autovalidateMode: AutovalidateMode.onUnfocus,
                controller: invController.txtStockNotifierLimit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+(\.\d*)?'),
                  ),
                  // FilteringTextInputFormatter.digitsOnly,
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
                  labelText: 'alert when qty falls below:',
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

              Obx(() {
                return Column(
                  children: [
                    Visibility(
                      visible: invController.includeSupplierDetails.value,
                      replacement: SizedBox.shrink(),
                      child: Column(
                        children: [
                          const SizedBox(height: CSizes.spaceBtnInputFields),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: invController.txtSupplierName,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDarkTheme
                                  ? CColors.transparent
                                  : CColors.lightGrey,
                              // labelStyle: Theme.of(
                              //   context,
                              // ).textTheme.labelSmall,
                              labelText: 'supplier name:',
                              prefixIcon: Icon(
                                Iconsax.user_add,
                                color: CColors.darkGrey,
                                size: CSizes.iconXs,
                              ),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(
                            height: CSizes.spaceBtnInputFields / 2,
                          ),
                          TextFormField(
                            controller: invController.txtSupplierContacts,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDarkTheme
                                  ? CColors.transparent
                                  : CColors.lightGrey,
                              // labelStyle: TextStyle(
                              //   color: CColors.darkGrey,
                              //   inherit: true,
                              // ),
                              labelText: 'supplier contacts:',

                              prefixIcon: Icon(
                                Icons.contact_mail,
                                color: CColors.darkGrey,
                                size: CSizes.iconXs,
                              ),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(
                            height: CSizes.spaceBtnInputFields / 2,
                          ),
                        ],
                      ),
                    ),
                    // -- expiry date field --
                    Visibility(
                      replacement: const SizedBox.shrink(),
                      visible: invController.includeExpiryDate.value,

                      child: TextFormField(
                        //autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: invController.txtExpiryDatePicker,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkTheme
                              ? CColors.transparent
                              : CColors.lightGrey,
                          labelText: 'pick expiry date:',
                          labelStyle: textStyle,
                          prefixIcon: Icon(
                            Iconsax.calendar,
                            color: CColors.darkGrey,
                            size: CSizes.iconXs,
                          ),
                        ),
                        onTap: () async {
                          final dateController = Get.put(
                            CDateController(),
                          );
                          dateController.triggerCupertinoDatePicker(
                            Get.overlayContext!,
                          );
                        },
                        readOnly: true,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
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
                        icon: Icon(
                          Iconsax.save_add,
                          size: CSizes.iconSm,
                          color: isDarkTheme ? CColors.rBrown : CColors.white,
                        ),
                        label: Text(
                          invController.itemExists.value ? 'update' : 'add',
                          style: Theme.of(context).textTheme.labelMedium!.apply(
                            color: isDarkTheme ? CColors.rBrown : CColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              CColors.white, // foreground (text) color
                          backgroundColor: isDarkTheme
                              ? CColors.white
                              : CColors.rBrown, // background color
                        ),
                        onPressed: () async {
                          // -- form validation
                          if (!invController.addInvItemFormKey.currentState!
                              .validate()) {
                            return;
                          }

                          if (invController.unitBP.value >
                              double.parse(
                                invController.txtUnitSP.text.trim(),
                              )) {
                            invController.confirmInvalidUspModal(context);
                            return;
                          }

                          if (await invController.addOrUpdateInventoryItem(
                            inventoryItem,
                          )) {
                            switch (fromHomeScreen) {
                              case true:
                                navController.selectedIndex.value = 1;
                                Navigator.pop(Get.overlayContext!, true);

                                Get.to(const NavMenu());
                                break;
                              default:
                                Navigator.pop(Get.overlayContext!, true);
                                break;
                            }
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
                        color: CColors.error,
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
                        Navigator.pop(context, true);
                        invController.resetInvFields();
                        //invController.fetchUserInventoryItems();
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
