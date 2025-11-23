import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cri_v3/api/sheets/store_sheets_api.dart';
import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/success_screen/txn_success.dart';
import 'package:cri_v3/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:cri_v3/features/personalization/controllers/app_settings_controller.dart';
import 'package:cri_v3/features/personalization/controllers/location_controller.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/cart_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/nav_menu_controller.dart';
import 'package:cri_v3/features/personalization/controllers/notifications_controller.dart';
import 'package:cri_v3/features/store/controllers/sync_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/features/store/models/cart_item_model.dart';
import 'package:cri_v3/features/store/models/inv_model.dart';
import 'package:cri_v3/features/store/models/notifications_model.dart';
import 'package:cri_v3/features/store/models/payment_method_model.dart';
import 'package:cri_v3/features/store/models/txns_model.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/checkout/checkout_screen.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/checkout/widgets/amt_issued_field.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/checkout/widgets/payment_methods/payment_methods_tile.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/inventory/inventory_details/widgets/add_to_cart_bottom_nav_bar.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:cri_v3/nav_menu.dart';
import 'package:cri_v3/services/location_services.dart';
import 'package:cri_v3/services/pdf_services.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/img_strings.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/db/sqflite/db_helper.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:cri_v3/utils/popups/full_screen_loader.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:mpesa_flutter_plugin/initializer.dart';
import 'package:mpesa_flutter_plugin/payment_enums.dart';
import 'package:simple_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class CCheckoutController extends GetxController {
  static CCheckoutController get instance => Get.find();

  @override
  void onInit() async {
    await dbHelper.openDb();

    amtIssuedFieldController.text = '';
    customerContactsFieldController.text = '';
    customerNameFieldController.text = '';
    customerBalField.text == '';
    setFocusOnAmtIssuedField.value = false;
    includeAmtIssuedFieldonModal.value = false;
    CLocationServices.instance.getUserLocation(
      locationController: locationController,
    );

    super.onInit();
  }

  /// -- variables --
  AddUpdateItemDialog dialog = AddUpdateItemDialog();

  final Rx<CPaymentMethodModel> selectedPaymentMethod = CPaymentMethodModel(
    platformLogo: CImages.cash6,
    platformName: 'cash',
  ).obs;

  final pdfServices = CPdfServices.instance;

  RxList<CCartItemModel> itemsInCart = <CCartItemModel>[].obs;

  final CLocationController locationController = Get.put<CLocationController>(
    CLocationController(),
  );

  final RxString checkoutItemScanResults = ''.obs;

  final RxBool setFocusOnAmtIssuedField = false.obs;

  final appSettingsController = Get.put(CAppSettingsController());
  final cartController = Get.put(CCartController());
  final invController = Get.put(CInventoryController());
  final navController = Get.put(CNavMenuController());
  final notificationsController = Get.put(CNotificationsController());
  final txnsController = Get.put(CTxnsController());
  final userController = Get.put(CUserController());

  TextEditingController amtIssuedFieldController = TextEditingController();

  TextEditingController customerNameFieldController = TextEditingController();
  TextEditingController customerContactsFieldController =
      TextEditingController();
  final customerBalField = TextEditingController();
  final TextEditingController modalQtyFieldController = TextEditingController();

  DbHelper dbHelper = DbHelper.instance;

  final RxBool includeAmtIssuedFieldonModal = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool itemExists = false.obs;

  final RxDouble customerBal = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;

  final RxInt itemStockCount = 0.obs;
  final RxInt checkoutItemId = 0.obs;
  final RxInt checkoutItemSales = 0.obs;
  final RxInt txnId = 0.obs;

  final RxString checkoutItemCode = ''.obs;
  final RxString checkoutItemLastModified = ''.obs;
  final RxString checkoutItemName = ''.obs;
  final RxString customerMpesaNumber = ''.obs;

  final Rx<FocusNode> customerNameFocusNode = FocusNode().obs;

  /// -- process txn --
  void processTxn(String txnStatus) async {
    try {
      // -- start loader --
      CFullScreenLoader.openLoadingDialog(
        'processing txn...',
        CImages.docerAnimation,
      );

      txnsController.fetchSoldItems();

      final cartController = Get.put(CCartController());

      // -- fetch cart content --
      cartController.fetchCartItems();

      // -- txn details --

      if (cartController.cartItems.isNotEmpty) {
        for (var item in cartController.cartItems) {
          itemsInCart.add(item);
        }
      }

      if (itemsInCart.isNotEmpty) {
        txnId.value = CHelperFunctions.generateTxnId();

        var userCoordinates = '';

        if (locationController.userLocation.value!.latitude == null ||
            locationController.userLocation.value!.longitude == null) {
          userCoordinates = userController.user.value.locationCoordinates;
        } else {
          userCoordinates =
              'lat: ${locationController.userLocation.value!.latitude} long: ${locationController.userLocation.value!.longitude}';
        }

        for (var cartItem in itemsInCart) {
          var newTxnData = CTxnsModel(
            txnId.value,
            userController.user.value.id,
            userController.user.value.email,
            userController.user.value.fullName,
            cartItem.productId,
            cartItem.pCode,
            cartItem.pName,
            cartItem.quantity,
            0,
            '',
            cartController.totalCartPrice.value,
            selectedPaymentMethod.value.platformName == 'cash'
                ? double.parse(amtIssuedFieldController.text.trim())
                : 0.00,
            selectedPaymentMethod.value.platformName == 'cash'
                ? customerBal.value
                : 0.00,
            cartItem.price,
            0.00,
            selectedPaymentMethod.value.platformName,
            customerNameFieldController.text.trim(),
            customerContactsFieldController.text.trim(),
            locationController.uAddress.value != ''
                ? locationController.uAddress.value
                : userController.user.value.userAddress,
            userCoordinates,
            //'lat: ${locationController.userLocation.value!.latitude ?? ''} long: ${locationController.userLocation.value!.longitude ?? ''}',
            DateFormat('yyyy-MM-dd @ kk:mm').format(clock.now()),
            0,
            'append',
            txnStatus,
            //'complete',
          );

          // save txn data into the db
          await dbHelper.addSoldItem(newTxnData).then((result) async {
            if (dbHelper.saleItemAddedToDb.value) {
              result = 'item added';

              // -- update stock count & total sales for this inventory item --
              final invController = Get.put(CInventoryController());
              invController.fetchUserInventoryItems();
              var invItem = invController.inventoryItems.firstWhere(
                (item) => item.productId == cartItem.productId,
              );

              invItem.qtySold += cartItem.quantity;

              if (invItem.quantity == cartItem.quantity) {
                invItem.quantity = 0;
              } else {
                invItem.quantity -= cartItem.quantity;
              }

              await dbHelper.updateInventoryItem(invItem, cartItem.productId);

              if (kDebugMode) {
                print('** inventory stock update successful **');
              }

              // -- update sync status/action for this inventory item --
              var sAction = invItem.isSynced == 1 ? 'update' : 'append';
              dbHelper.updateInvOfflineSyncAfterStockUpdate(
                sAction,
                cartItem.productId,
              );

              invController.fetchUserInventoryItems();
              // -- check and implement low stock count alert --
              if (invItem.quantity <= invItem.lowStockNotifierLimit) {
                var alertBody = '';
                switch (invItem.quantity) {
                  case 0:
                    alertBody = '${invItem.name} is out of stock!!';
                    break;

                  case >= 1:
                    alertBody =
                        'only ${invItem.quantity} item(s) of ${invItem.name} is (are) left!!';
                    break;
                  default:
                    alertBody = '';
                }

                var alertItem = CNotificationsModel(
                  0,
                  'low stock alert',
                  alertBody,
                  0,
                  invItem.productId ?? 0,
                  userController.user.value.email,
                  DateFormat('yyyy-MM-dd @ kk:mm').format(clock.now()),
                );
                notificationsController.saveAndOrTriggerNotification(
                  alertItem,
                  CHelperFunctions.generateAlertId(),
                  alertItem.notificationTitle,
                  alertBody,
                  alertItem.alertCreated == 1 ? true : false,
                );
              }
            } else {
              result = 'ERROR ADDING SALE ITEM';
            }
          });
        }
        Get.offAll(() {
          final syncController = Get.put(CSyncController());
          return CTxnSuccessScreen(
            lottieImage: syncController.processingSync.value
                ? CImages.loadingAnime
                : CImages.paymentSuccessfulAnimation,
            title: 'txn success',
            subTitle: syncController.processingSync.value
                ? 'processing cloud sync...'
                : 'transaction successful',
            onContinueBtnPressed: () async {
              txnsController.fetchSoldItems();

              final internetIsConnected = await CNetworkManager.instance
                  .isConnected();

              if (internetIsConnected &&
                  appSettingsController.dataSyncIsOn.value) {
                //await syncController.processSync();
                if (await syncController.processSync()) {
                  await txnsController.fetchSoldItems();
                  await invController.fetchUserInventoryItems();
                  if (invController.unSyncedAppends.isNotEmpty ||
                      invController.unSyncedUpdates.isNotEmpty ||
                      txnsController.unsyncedTxnAppends.isNotEmpty ||
                      txnsController.unsyncedTxnUpdates.isNotEmpty) {
                    await syncController.processSync();
                  }
                }
                // else {
                //   if (kDebugMode) {
                //     print('error processing cloud sync on checkout!');
                //     CPopupSnackBar.errorSnackBar(
                //       title: 'error processing cloud sync on checkout!',
                //       message: 'error processing cloud sync on checkout!',
                //     );
                //   }
                // }
              } else {
                if (!internetIsConnected) {
                  CPopupSnackBar.customToast(
                    message:
                        'internet connection required for cloud sync during checkout!',
                    forInternetConnectivityStatus: true,
                  );
                } else {
                  CPopupSnackBar.warningSnackBar(
                    title: 'auto-sync is off',
                    message:
                        'data auto-synchronization is turned off in you account settings!',
                  );
                }
              }
              refreshData();
            },
          );
        });
      } else {
        CPopupSnackBar.errorSnackBar(
          title: 'empty cart...',
          message: 'your cart is empty',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'error processing txn..',
          message: '$e',
        );
      }

      rethrow;
    }
  }

  /// -- method to select payment method --
  Future<dynamic> selectPaymentMethod(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(CSizes.lg / 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CSectionHeading(
                  showActionBtn: false,
                  title: 'select payment method...',
                  btnTitle: '',
                  editFontSize: true,
                ),
                const SizedBox(height: CSizes.spaceBtnSections / 4),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.deferred1,
                    platformName: 'credit',
                  ),
                ),
                const SizedBox(height: CSizes.spaceBtnSections / 4),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.cash6,
                    platformName: 'cash',
                  ),
                ),
                const SizedBox(height: CSizes.spaceBtnSections / 4),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.mpesaExpressLogo,
                    platformName: 'mPesa online',
                  ),
                ),
                const SizedBox(height: CSizes.spaceBtnSections / 4),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.mPesaLogo,
                    platformName: 'mPesa (offline)',
                  ),
                ),
                const SizedBox(height: CSizes.spaceBtnSections / 4),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.googlePayLogo,
                    platformName: 'google pay',
                  ),
                ),
                const SizedBox(height: CSizes.spaceBtnSections / 4),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.paypalLogo,
                    platformName: 'paypal',
                  ),
                ),
                const SizedBox(height: CSizes.spaceBtnSections / 4),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.masterCardLogo,
                    platformName: 'master card',
                  ),
                ),
                const SizedBox(height: CSizes.spaceBtnSections / 4),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.visaLogo,
                    platformName: 'visa',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// -- scan item for checkout --
  Future<void> scanItemForCheckout() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'cancel',
        true,
        ScanMode.BARCODE,
        3000,
        CameraFace.back.toString(),
        ScanFormat.ALL_FORMATS,
      );
      checkoutItemScanResults.value = barcodeScanRes;
      // -- set inventory item details to fields --
      if (checkoutItemScanResults.value != '' &&
          checkoutItemScanResults.value != '-1') {
        await invController.fetchUserInventoryItems();
        fetchForSaleItemByCode(checkoutItemScanResults.value);

        await fetchForSaleItemByCode(barcodeScanRes);
        if (itemExists.value) {
          nextActionAfterScanModal(Get.overlayContext!);
        } else {
          invController.resetInvFields();
          invController.txtCode.text = checkoutItemScanResults.value;
          showDialog(
            context: Get.overlayContext!,
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
                0,
                '',
              ),
              true,
            ),
          );
        }
      }
    } on PlatformException catch (platformException) {
      if (platformException.code == BarcodeScanner.cameraAccessDenied) {
        CPopupSnackBar.warningSnackBar(
          title: 'camera access denied',
          message: 'permission to use your camera is denied!!!',
        );
      } else {
        CPopupSnackBar.errorSnackBar(
          title: 'platform exception error!',
          message: platformException.message,
        );
      }
    } on FormatException catch (formatException) {
      CPopupSnackBar.errorSnackBar(
        title: 'format exception error!!',
        message: formatException.message,
      );
    } catch (e) {
      CPopupSnackBar.errorSnackBar(title: 'scan error!', message: e.toString());
    }
  }

  /// -- modal for next action after successful item scan --
  Future<dynamic> nextActionAfterScanModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        final invItem = invController.inventoryItems.firstWhere(
          (item) => item.productId == checkoutItemId.value,
        );
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(CSizes.lg / 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${checkoutItemLastModified.value} ',
                        style: Theme.of(context).textTheme.labelSmall!.apply(),
                      ),
                      TextSpan(
                        text: '(${itemStockCount.value} stocked)',
                        style: Theme.of(context).textTheme.labelSmall!.apply(),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  checkoutItemName.value.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium!.apply(),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'code: ${checkoutItemCode.value}',
                        style: Theme.of(context).textTheme.labelSmall!.apply(),
                      ),
                      TextSpan(
                        text: ' (${checkoutItemSales.value} sold)',
                        style: Theme.of(context).textTheme.labelSmall!.apply(),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Divider(
                  color: CHelperFunctions.isDarkMode(context)
                      ? CColors.white
                      : CColors.rBrown,
                ),
                CAddToCartBottomNavBar(
                  inventoryItem: invItem,
                  minusIconBtnColor: CHelperFunctions.isDarkMode(context)
                      ? CColors.white.withValues(alpha: 0.5)
                      : CColors.rBrown.withValues(alpha: 0.5),
                  minusIconTxtColor: CHelperFunctions.isDarkMode(context)
                      ? CColors.rBrown
                      : CColors.white,
                  addIconBtnColor: CHelperFunctions.isDarkMode(context)
                      ? CColors.white
                      : CColors.rBrown,
                  addIconTxtColor: CHelperFunctions.isDarkMode(context)
                      ? CColors.rBrown
                      : CColors.white,
                  add2CartBtnBorderColor: CHelperFunctions.isDarkMode(context)
                      ? CColors.white
                      : CColors.rBrown,
                  fromCheckoutScreen: true,
                ),
                const SizedBox(height: CSizes.spaceBtnItems),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<CInventoryModel>> fetchForSaleItemByCode(String code) async {
    try {
      isLoading.value = true;

      // fetch scanned item from sqflite db
      final fetchedItem = await dbHelper.fetchInvItemByCodeAndEmail(
        code,
        userController.user.value.email,
      );

      if (fetchedItem.isNotEmpty) {
        itemExists.value = true;
        checkoutItemId.value = fetchedItem.first.productId!;
        checkoutItemName.value = fetchedItem.first.name;
        checkoutItemCode.value = fetchedItem.first.pCode;
        checkoutItemSales.value = fetchedItem.first.qtySold;
        itemStockCount.value = fetchedItem.first.quantity;
        checkoutItemLastModified.value = fetchedItem.first.lastModified;
      } else {
        resetSalesFields();
        itemExists.value = false;
      }
      return fetchedItem;
    } catch (e) {
      isLoading.value = false;
      itemExists.value = false;
      if (kDebugMode) {
        print(e.toString());
        throw CPopupSnackBar.errorSnackBar(
          title: 'Oh Snap! error fetching for sale item by code!',
          message: e.toString(),
        );
      }
      return [];
    }
  }

  computeCustomerBal(double cartTotals, double amtIssued) {
    customerBal.value = amtIssued - cartTotals;
    customerBalField.text = customerBal.value.toString();
  }

  resetSalesFields() {
    amtIssuedFieldController.text = '';
    customerNameFieldController.text = '';
    customerContactsFieldController.text = '';
    customerBal.value = 0.0;
    customerContactsFieldController.text = '';
    customerBalField.text == '';
    itemExists.value = false;

    setFocusOnAmtIssuedField.value = false;
  }

  /// -- calculate totals --
  computeTotals(String value, double usp) {
    if (value.isNotEmpty) {
      totalAmount.value = int.parse(value) * usp;

      txnsController.checkStockStatus(value);
    } else {
      totalAmount.value = 0.0;
    }
  }

  Future handleNavToCheckout() async {
    final cartController = Get.put(CCartController());
    Get.put(CCheckoutController());
    cartController.fetchCartItems().then((_) async {
      if (await cartController.fetchCartItems()) {
        Get.to(() => const CCheckoutScreen());
      }
    });
  }

  refreshData() {
    final cartController = Get.put(CCartController());

    txnsController.fetchSoldItems();
    customerBal.value = 0.0;

    // clear cart
    cartController.clearCart();
    itemsInCart.clear();

    resetSalesFields();

    cartController.qtyFieldControllers.clear();
    if (cartController.qtyFieldControllers.isNotEmpty) {
      cartController.qtyFieldControllers.close();
    }
    navController.selectedIndex.value = 1;

    Get.offAll(() => NavMenu());
  }

  /// -- display bottom sheet modal popup for checkout --
  Future<dynamic> triggerCheckoutActionModal(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    return showModalBottomSheet(
      context: context,
      backgroundColor: CColors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: CRoundedContainer(
            height: CHelperFunctions.screenHeight() * 0.35,
            padding: const EdgeInsets.all(CSizes.lg / 3),
            bgColor: isDarkTheme ? CColors.rBrown : CColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'complete or suspend transaction?',
                  style: Theme.of(context).textTheme.labelMedium!.apply(
                    color: isDarkTheme ? CColors.white : CColors.rBrown,
                    fontSizeFactor: 1.2,
                    fontWeightDelta: 2,
                  ),
                ),
                const SizedBox(height: CSizes.spaceBtnInputFields),
                Text(
                  'if the customer is yet to pay, you are advised to suspend (or rather invoice) it',
                  style: Theme.of(context).textTheme.labelMedium!.apply(
                    color: isDarkTheme ? CColors.white : CColors.rBrown,
                  ),
                ),
                Divider(
                  color: isDarkTheme ? CColors.white : CColors.rBrown,
                  endIndent: 100.0,
                  indent: 100.0,
                  thickness: 0.2,
                ),
                const SizedBox(height: CSizes.spaceBtnInputFields / 4),
                Obx(() {
                  return Visibility(
                    visible:
                        (amtIssuedFieldController.text == '' ||
                            double.parse(customerBalField.text) < 0 ||
                            customerBalField.text == '') &&
                        includeAmtIssuedFieldonModal.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CAmountIssuedTxtField(
                          txtFieldWidth: CHelperFunctions.screenWidth() * 0.6,
                          txtFieldHeight: 45.0,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: CSizes.spaceBtnInputFields / 4),
                Row(
                  children: [
                    SizedBox(
                      width: CHelperFunctions.screenWidth() * 0.45,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          includeAmtIssuedFieldonModal.value = false;
                          amtIssuedFieldController.text = '';
                          customerBal.value =
                              0 - cartController.totalCartPrice.value;
                        },
                        label: Text(
                          'invoice/suspend',
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                            color: isDarkTheme ? CColors.white : CColors.rBrown,
                          ),
                        ),
                        icon: Icon(
                          Iconsax.brifecase_timer,
                          color: isDarkTheme ? CColors.white : CColors.rBrown,
                          //color: CColors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkTheme
                              ? CColors.black
                              : CColors.black.withValues(alpha: 0.25),
                          //backgroundColor: CColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: CSizes.spaceBtnInputFields),
                    SizedBox(
                      width: CHelperFunctions.screenWidth() * 0.45,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          includeAmtIssuedFieldonModal.value = true;
                          onCheckoutBtnPressed();
                        },
                        label: Text(
                          'complete txn',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.apply(color: CColors.white),
                        ),
                        icon: Icon(Iconsax.tick_circle, color: CColors.white),
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: CColors.black.withValues(alpha: 0.5),
                          backgroundColor: CColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// -- TODO: update stock count when item is sold o credit
  onCheckoutBtnPressed() {
    if (selectedPaymentMethod.value.platformName == 'cash') {
      if (amtIssuedFieldController.text == '') {
        CPopupSnackBar.customToast(
          message: 'please enter the amount issued by the customer!!',
          forInternetConnectivityStatus: false,
        );
        setFocusOnAmtIssuedField.value = true;

        return;
      }
      // else {
      //   includeAmtIssuedFieldonModal.value = false;
      // }
      if (amtIssuedFieldController.text == '' ||
          double.parse(amtIssuedFieldController.text.trim()) <
              cartController.totalCartPrice.value) {
        CPopupSnackBar.errorSnackBar(
          title: 'customer still owes you!!',
          message: 'the amount issued is not enough',
        );
        return;
      }
    }
    if ((selectedPaymentMethod.value.platformName == 'mPesa' ||
            selectedPaymentMethod.value.platformName == 'credit') &&
        customerNameFieldController.text == '') {
      customerNameFocusNode.value.requestFocus();
      CPopupSnackBar.warningSnackBar(
        title: 'customer details required!',
        message:
            'please provide customer\'s name for ${selectedPaymentMethod.value.platformName} payment verification',
      );
      return;
    }
    if (selectedPaymentMethod.value.platformName == 'credit') {
      if (customerNameFieldController.text == '') {
        customerNameFocusNode.value.requestFocus();
        CPopupSnackBar.warningSnackBar(
          title: 'customer details required!',
          message:
              'please provide customer\'s name and (or) contacts for ${selectedPaymentMethod.value.platformName} payment verification',
        );
        return;
      }
    }

    /// -- check if txn is to be completed or invoiced --
    String txnType;
    switch (selectedPaymentMethod.value.platformName) {
      case "credit":
        txnType = 'invoiced';
        break;
      default:
        txnType = 'complete';
    }
    processTxn(txnType);
  }

  confirmInvoicePaymentDialog(int txnId) {
    // TODO: confirm if seller is sure to sell on credit
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(CSizes.md),
      title: 'complete transaction?',
      middleText: 'are you certain payment is complete?',
      confirm: ElevatedButton(
        onPressed: () async {
          // -- check internet connectivity --
          if (txnsController.transactionItems.isEmpty) {
            if (kDebugMode) {
              print('receipt items cleared!!');
              CPopupSnackBar.customToast(
                message: 'receipt items cleared!!',
                forInternetConnectivityStatus: false,
              );
            }
            txnsController.fetchTxnItems(txnId);
          }

          for (var item in txnsController.transactionItems) {
            item.lastModified = DateFormat(
              'yyyy-MM-dd @ kk:mm',
            ).format(clock.now()).toString();

            item.syncAction = item.isSynced == 0 ? 'append' : 'update';

            item.txnStatus = 'complete';

            await dbHelper.updateMultipleFieldsWithTransactionId(
              item.txnId,
              item.lastModified,
              item.syncAction,
              item.txnStatus,
            );
          }
          txnsController.fetchTxns();
          Navigator.of(Get.overlayContext!).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: CSizes.lg),
          child: Text('confirm'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () {
          //fetchUserInventoryItems();
          Navigator.of(Get.overlayContext!).pop();
        },
        child: const Text('cancel'),
      ),
    );
  }

  Future updateTxnItemCloudData(int txnId, CTxnsModel itemModel) async {
    try {
      await StoreSheetsApi.updateCloudTxnItems(txnId, itemModel.toMap());
    } catch (e) {
      CPopupSnackBar.errorSnackBar(
        title: 'error updating txn #$txnId\'s cloud data',
        message: e.toString(),
      );

      throw e.toString();
    }
  }

  /// -- lipa na mpesa (daraja) api integration --
  Future<dynamic> initializeMpesaTxn(
    double txnAmount,
    String customerPhoneNumber,
  ) async {
    dynamic txnInit;
    try {
      txnInit = await MpesaFlutterPlugin.initializeMpesaSTKPush(
        businessShortCode: "174379",
        // transactionType: "CustomerPayBillOnline",
        transactionType: TransactionType.CustomerPayBillOnline,
        amount: txnAmount,
        //partyA: "254708374149",
        partyA: customerPhoneNumber,
        partyB: "174379",
        callBackURL: Uri.parse("https://mydomain.com/path"),
        accountReference: "payment test",
        //phoneNumber: "254708374149",
        phoneNumber: customerPhoneNumber,
        baseUri: Uri(scheme: "https", host: "sandbox.safaricom.co.ke"),
        transactionDesc: "Test Payment",
        passKey:
            "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
      );

      //HashMap response = txnInit as HashMap;
      if (kDebugMode) {
        print("Response: $txnInit");
      }
    } catch (e) {
      /// -- you can implement your exception handling here --
      /// -- network unreachability is a sure exception --
      if (kDebugMode) {
        print("Exception Caught: $e");
      }
      rethrow;
    }
    return txnInit;
  }

  @override
  void dispose() {
    customerNameFocusNode.value.dispose();
    super.dispose();
  }
}
