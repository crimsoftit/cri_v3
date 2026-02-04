import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cri_v3/api/sheets/store_sheets_api.dart';
import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/icon_buttons/circular_icon_btn.dart';
import 'package:cri_v3/features/personalization/controllers/notification_tings/flutter_local_notifications/local_notifications_controller.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/dashboard_controller.dart';
import 'package:cri_v3/features/store/controllers/date_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/search_bar_controller.dart';
import 'package:cri_v3/features/store/controllers/sync_controller.dart';
import 'package:cri_v3/features/store/models/best_sellers_model.dart';
import 'package:cri_v3/features/store/models/inv_model.dart';
import 'package:cri_v3/features/store/models/txns_model.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/db/sqflite/db_helper.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/flutter_barcode_scanner.dart';

/// TODO: get summary data
class CTxnsController extends GetxController {
  static CTxnsController get instance {
    return Get.find();
  }

  /// -- variables --
  final localStorage = GetStorage();
  final dateRangeController = Get.put(CDateController());
  final dateRangeFieldController = TextEditingController();

  DbHelper dbHelper = DbHelper.instance;

  final RxList<CTxnsModel> foundInvoices = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> invoices = <CTxnsModel>[].obs;

  final RxList<CTxnsModel> sales = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> foundSales = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> txns = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> foundTxns = <CTxnsModel>[].obs;
  RxList<CTxnsModel> transactionItems = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> refunds = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> foundRefunds = <CTxnsModel>[].obs;

  final RxList<CBestSellersModel> bestSellers = <CBestSellersModel>[].obs;

  final RxList<CTxnsModel> receipts = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> foundReceipts = <CTxnsModel>[].obs;

  final RxList<CTxnsModel> allGsheetTxnsData = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> unsyncedTxnAppends = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> unsyncedTxnUpdates = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> userGsheetTxnsData = <CTxnsModel>[].obs;

  final RxString sellItemScanResults = ''.obs;
  final RxString selectedPaymentMethod = 'Cash'.obs;
  final RxString stockUnavailableErrorMsg = ''.obs;
  final RxString customerBalErrorMsg = ''.obs;
  final RxString amtIssuedFieldError = ''.obs;

  final RxBool isImportingTxnsFromCloud = false.obs;
  final RxBool itemExists = false.obs;
  final RxBool showAmountIssuedField = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool txnItemsLoading = false.obs;
  final RxBool txnsSyncIsLoading = false.obs;
  final RxBool includeCustomerDetails = false.obs;
  final RxBool txnSuccesfull = false.obs;
  final RxBool txnsFetched = false.obs;
  final RxBool soldItemsFetched = false.obs;
  final RxBool updatesOnRefundDone = false.obs;
  final RxBool refundDataUpdated = false.obs;

  /// -- summary variables --
  final RxDouble costOfSales = 0.0.obs;
  final RxDouble grossRevenue = 0.0.obs;
  final RxDouble invoicesValue = 0.0.obs;
  final RxDouble moneyCollected = 0.0.obs;
  final RxDouble totalProfit = 0.0.obs;

  final txtAmountIssued = TextEditingController();
  final txtCustomerName = TextEditingController();
  final txtCustomerContacts = TextEditingController();
  final txtRefundReason = TextEditingController();
  final txtSaleItemQty = TextEditingController();
  final txtTxnAddress = TextEditingController();

  final RxInt sellItemId = 0.obs;
  final RxDouble qtyAvailable = 0.0.obs;
  final RxDouble totalSales = 0.0.obs;
  final RxDouble refundQty = 0.0.obs;

  final RxString saleItemName = ''.obs;
  final RxString saleItemCode = ''.obs;

  final RxDouble saleItemBp = 0.0.obs;
  final RxDouble saleItemUnitBP = 0.0.obs;
  final RxDouble saleItemUsp = 0.0.obs;
  final RxDouble deposit = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxDouble customerBal = 0.0.obs;

  /// -- controllers - classes --

  final userController = Get.put(CUserController());
  final searchController = Get.put(CSearchBarController());
  final invController = Get.put(CInventoryController());
  final notsController = Get.put(CLocalNotificationsController());
  final txnsFormKey = GlobalKey<FormState>();

  @override
  void onInit() async {
    dateRangeFieldController.text = '';
    //dbHelper.openDb();

    if (await CNetworkManager.instance.isConnected()) {
      StoreSheetsApi.initSpreadSheets();
    }

    fetchSoldItems();
    fetchTxns();
    initTxnsSync();

    showAmountIssuedField.value = true;
    refundQty.value = 0;

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.onInit();
  }

  @override
  void dispose() {
    dateRangeFieldController.dispose(); // Dispose of the controller

    super.dispose();
  }

  /// -- initialize cloud sync --
  Future initTxnsSync() async {
    if (localStorage.read('SyncTxnsDataWithCloud') == true) {
      await importTxnsFromCloud();
      if (await importTxnsFromCloud()) {
        localStorage.write('SyncTxnsDataWithCloud', false);
      } else {
        localStorage.write('SyncTxnsDataWithCloud', true);
      }

      await fetchSoldItems();
    }
  }

  /// -- fetch sold items from sqflite db --
  Future<List<CTxnsModel>> fetchSoldItems() async {
    try {
      // start loader while txns are fetched
      isLoading.value = true;
      foundSales.clear();
      foundRefunds.clear();

      // fetch sales from local db
      final soldItems = await dbHelper.fetchAllSoldItems(
        userController.user.value.email,
      );

      // assign sold items to sales list
      // sales.assignAll(soldItems.where((sale) => sale.quantity > 0));
      sales.assignAll(soldItems);

      // assign values for unsynced txn appends
      unsyncedTxnAppends.value = soldItems
          .where(
            (unAppendedTxn) =>
                unAppendedTxn.syncAction.toLowerCase().contains('append'),
          )
          .toList();

      // assign values for unsynced txn updates
      var txnsForUpdates = soldItems
          .where(
            (unUpdatedTxn) =>
                unUpdatedTxn.syncAction.toLowerCase().contains('update') &&
                unUpdatedTxn.isSynced == 1,
          )
          .toList();
      unsyncedTxnUpdates.assignAll(txnsForUpdates);

      // assign values for refunded items
      var refundedItems = soldItems
          .where((refundedItem) => refundedItem.qtyRefunded >= 1)
          .toList();
      refunds.assignAll(refundedItems);

      if (searchController.showSearchField.value &&
          searchController.txtSearchField.text == '') {
        // foundSales.assignAll(soldItems);
        foundSales.assignAll(sales);
        foundRefunds.assignAll(refundedItems);
      }

      /// -- initialize sales summary values --

      final dashboardController = Get.put(CDashboardController());
      if (dateRangeFieldController.text == '' &&
          !dashboardController.showSummaryFilterField.value) {
        initializeSalesSummaryValues();
      }

      /// -- compute hourly sales --
      dashboardController.filterHourlySales();

      // stop loader
      isLoading.value = false;
      soldItemsFetched.value = true;

      return sales;
    } catch (e) {
      isLoading.value = false;
      soldItemsFetched.value = false;

      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      }
      //throw e.toString();
      rethrow;
    }
  }

  /// -- fetch txns from sqflite db --
  Future<List<CTxnsModel>> fetchTxns() async {
    try {
      // start loader while txns are fetched
      isLoading.value = true;
      //await dbHelper.openDb();
      await fetchSoldItems();

      // fetch txns from sqflite db
      final transactions = await dbHelper.fetchSoldItemsGroupedByTxnId(
        userController.user.value.email,
      );

      // assign transactions to txns list
      txns.assignAll(transactions);

      if (searchController.showSearchField.value &&
          searchController.txtSearchField.text == '') {
        foundTxns.assignAll(transactions);
      }

      // assign complete txns to receipts list
      final completeTxns = txns
          .where((txn) => txn.txnStatus.toLowerCase().contains('complete'))
          .toList();
      receipts.assignAll(completeTxns);

      // assign credit sales to invoices list
      final creditSales = txns
          .where((txn) => txn.txnStatus.toLowerCase().contains('invoiced'))
          .toList();
      invoices.assignAll(creditSales);

      if (searchController.showSearchField.value &&
          searchController.txtSearchField.text == '') {
        foundReceipts.assignAll(receipts);
        foundInvoices.assignAll(creditSales);
      }

      txnsFetched.value = true;

      // stop loader
      isLoading.value = false;

      return txns;
    } catch (e) {
      txnsFetched.value = false;
      isLoading.value = false;

      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      }
      //throw e.toString();
      rethrow;
    }
  }

  /// -- fetch txn items by txn id --
  Future<List<CTxnsModel>> fetchTxnItems(int txnId) async {
    try {
      // start loader while txns are fetched
      txnItemsLoading.value = true;
      isLoading.value = true;

      fetchTxns().then((_) {
        if (txns.isNotEmpty && soldItemsFetched.value && txnsFetched.value) {
          var listToSearchFrom = foundSales.isNotEmpty ? foundSales : sales;
          var txnItems = listToSearchFrom
              .where(
                (soldItem) =>
                    soldItem.txnId.toString().contains(txnId.toString()),
              )
              .toList();

          transactionItems.assignAll(txnItems);
        } else {
          // stop loader
          txnItemsLoading.value = false;
          isLoading.value = false;
          transactionItems.clear();
          return CPopupSnackBar.warningSnackBar(
            title: 'items not found',
            message: 'items NOT found for this txn',
          );
        }
      });

      txnItemsLoading.value = false;
      isLoading.value = false;

      return transactionItems;
    } catch (e) {
      txnItemsLoading.value = false;
      isLoading.value = false;
      transactionItems.clear();
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'Oh Snap! error fetching txn items',
          message: e.toString(),
        );
      }
      //throw e.toString();
      rethrow;
    }
  }

  /// -- barcode scanner using flutter_barcode_scanner package --
  Future<void> scanItemForSale() async {
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

      sellItemScanResults.value = barcodeScanRes;

      // -- set inventory item details to fields --
      if (sellItemScanResults.value != '' &&
          sellItemScanResults.value != '-1') {
        await fetchSoldItems();
        await fetchForSaleItemByCode(barcodeScanRes);
      }

      if (itemExists.value && !isLoading.value) {
        Get.toNamed('/sales/sell_item/');
      } else {
        CPopupSnackBar.customToast(
          message: 'item not found! please scan again or search inventory',
          forInternetConnectivityStatus: false,
        );
        await fetchSoldItems();
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
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'sell item scan error!',
          message: e.toString(),
        );
      }
      //throw e.toString();
      rethrow;
    }
  }

  /// -- fetch top sellers grouped by product id --
  Future<List<CBestSellersModel>> fetchTopSellersFromSales() async {
    try {
      // -- start loader while top sellers are fetched --
      isLoading.value = true;

      final topSales = await dbHelper
          .fetchTopSellersFromSalesGroupedByProductId(
            userController.user.value.email,
          );

      bestSellers.assignAll(topSales);

      // stop loader
      isLoading.value = false;

      return bestSellers;
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('error fetching top sellers from sales table: $e');
        CPopupSnackBar.errorSnackBar(
          title: 'error fetching top sellers from sales table',
          message: e.toString(),
        );
      }
      CPopupSnackBar.errorSnackBar(
        title: 'error fetching top sellers',
        message:
            'an unknown error occurred while fetching top sellers! please try again later...',
      );
      rethrow;
    }
  }

  /// -- fetch inventory item by code --
  Future<List<CInventoryModel>> fetchForSaleItemByCode(String code) async {
    try {
      // start loader while products are fetched
      isLoading.value = true;

      // fetch scanned item from sqflite db
      final fetchedItem = await dbHelper.fetchInvItemByCodeAndEmail(
        code,
        userController.user.value.email,
      );

      //fetchInventoryItems();
      updatesOnRefundDone.value = false;
      refundDataUpdated.value = false;

      if (fetchedItem.isNotEmpty) {
        itemExists.value = true;
        sellItemId.value = fetchedItem.first.productId!;
        saleItemCode.value = fetchedItem.first.pCode;
        saleItemName.value = fetchedItem.first.name;
        saleItemBp.value = fetchedItem.first.buyingPrice;
        saleItemUnitBP.value = fetchedItem.first.unitBp;
        saleItemUsp.value = fetchedItem.first.unitSellingPrice;

        qtyAvailable.value = fetchedItem.first.quantity;
        totalSales.value = fetchedItem.first.qtySold;
      } else {
        itemExists.value = false;
        txtSaleItemQty.text = '';
        totalSales.value = 0;
      }

      isLoading.value = false;

      return fetchedItem;
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('****');
        print(e.toString());
        print('****');
        CPopupSnackBar.errorSnackBar(
          title: 'error fetching scan item!',
          message: 'error fetching scan item for sale: $e',
        );
      }

      //throw e.toString();
      rethrow;
    }
  }

  // -- search store --
  searchSales(String value) async {
    try {
      await fetchTxns();

      /// -- search all sold items --
      var salesFound = sales
          .where(
            (soldItem) =>
                soldItem.productName.toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                soldItem.txnId.toString().toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                soldItem.productCode.toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                soldItem.productId.toString().toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                soldItem.lastModified.toLowerCase().contains(
                  value.toLowerCase(),
                ),
          )
          .toList();
      foundSales.assignAll(salesFound);

      /// -- search refunded items --
      var refundsFound = refunds
          .where(
            (refundedItem) =>
                refundedItem.productCode.toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                refundedItem.productId.toString().toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                refundedItem.productName.toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                refundedItem.txnId.toString().toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                refundedItem.lastModified.toLowerCase().contains(
                  value.toLowerCase(),
                ),
          )
          .toList();
      foundRefunds.assignAll(refundsFound);

      /// -- search receipt items(complete txns) --
      var receiptsFound = receipts
          .where(
            (completeTxn) =>
                completeTxn.productCode.toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                completeTxn.productId.toString().toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                completeTxn.productName.toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                completeTxn.txnId.toString().toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                completeTxn.lastModified.toLowerCase().contains(
                  value.toLowerCase(),
                ),
          )
          .toList();
      foundReceipts.assignAll(receiptsFound);

      /// -- search itemssold on credit (invoices) --
      var invoicesFound = invoices
          .where(
            (invoice) =>
                invoice.productCode.toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                invoice.productId.toString().toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                invoice.productName.toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                invoice.txnId.toString().toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                invoice.lastModified.toLowerCase().contains(
                  value.toLowerCase(),
                ),
          )
          .toList();
      foundInvoices.assignAll(invoicesFound);
    } catch (e) {
      CPopupSnackBar.errorSnackBar(
        title: 'error searching sales',
        message: '$e',
      );
      //throw e.toString();
      rethrow;
    }
  }

  /// -- when search result item is selected --
  onSellItemBtnAction(CInventoryModel foundItem) {
    //onInit();
    selectedPaymentMethod.value == "Cash";
    showAmountIssuedField.value == true;
    setTransactionDetails(foundItem);
    Get.toNamed('/sales/sell_item/');
  }

  /// -- calculate totals --
  computeTotals(String value, double usp) {
    if (value.isNotEmpty) {
      totalAmount.value = int.parse(value) * usp;

      checkStockStatus(value);
    } else {
      totalAmount.value = 0.0;
    }
  }

  /// -- check if stock is available for sale --
  checkStockStatus(String value) {
    if (value != '') {
      if (int.parse(value) > qtyAvailable.value) {
        stockUnavailableErrorMsg.value = 'insufficient stock!!';
      } else {
        //qtyAvailable.value -= int.parse(value);
        stockUnavailableErrorMsg.value = '';
      }
    }
  }

  /// -- calculate customer balance --
  computeCustomerBal(double amountIsued, double totals) {
    if (txtAmountIssued.text.isNotEmpty && txtSaleItemQty.text.isNotEmpty) {
      customerBal.value = amountIsued - totals;
    } else {
      customerBal.value = 0.0;
    }
  }

  /// -- set payment method --
  setPaymentMethod(String value) {
    selectedPaymentMethod.value = value;
    if (selectedPaymentMethod.value == 'Cash') {
      showAmountIssuedField.value = true;
    } else {
      showAmountIssuedField.value = false;
    }
  }

  /// -- set sale details --
  setTransactionDetails(CInventoryModel foundItem) {
    sellItemId.value = foundItem.productId!;
    saleItemCode.value = foundItem.pCode;
    saleItemName.value = foundItem.name;
    saleItemBp.value = foundItem.buyingPrice;
    saleItemUnitBP.value = foundItem.unitBp;
    saleItemUsp.value = foundItem.unitSellingPrice;
    qtyAvailable.value = foundItem.quantity;
    totalSales.value = foundItem.qtySold;
    showAmountIssuedField.value = true;
    selectedPaymentMethod.value == 'Cash';
    if (selectedPaymentMethod.value == 'Cash') {
      showAmountIssuedField.value = true;
    } else {
      showAmountIssuedField.value = false;
    }
  }

  /// -- reset sales --
  resetSalesFields() {
    customerBal.value = 0.0;
    sellItemScanResults.value = '';
    selectedPaymentMethod.value == 'Cash';
    itemExists.value = false;
    showAmountIssuedField.value = true;
    updatesOnRefundDone.value = false;
    refundDataUpdated.value = false;
    refundQty.value = 0;
    isLoading.value = false;

    saleItemName.value = '';
    saleItemCode.value = '';
    qtyAvailable.value = 0;
    totalSales.value = 0;
    saleItemBp.value = 0.0;
    saleItemUnitBP.value = 0.0;
    saleItemUsp.value = 0.0;
    deposit.value = 0.0;
    totalAmount.value = 0.0;

    txtSaleItemQty.text = '';
    txtAmountIssued.text = '';
    txtCustomerName.text = '';
    txtCustomerContacts.text = '';
    txtTxnAddress.text = '';
  }

  /// -- add unsynced txns to the cloud --
  Future<bool> addUpdateSalesDataToCloud() async {
    try {
      isLoading.value = true;
      txnsSyncIsLoading.value = true;
      fetchSoldItems().then((result) {
        if (result.isNotEmpty) {
          final unsyncedTxnsForAppends = sales.where(
            (unsyncedTxn) =>
                unsyncedTxn.syncAction.toLowerCase() ==
                    'append'.toLowerCase() &&
                unsyncedTxn.isSynced == 0,
          );

          // -- update refunds data
          if (unsyncedTxnUpdates.isNotEmpty) {
            for (var updateItem in unsyncedTxnUpdates) {
              updateItem.syncAction = 'none';
              updateItem.txnStatus = updateItem.txnStatus == 'invoiced'
                  ? 'invoiced'
                  : 'complete';

              // -- update sales data on the cloud
              updateReceiptItemCloudData(updateItem.soldItemId!, updateItem);

              // -- update sales data locally
              dbHelper.updateReceiptItem(updateItem, updateItem.soldItemId!);
            }
          }

          if (unsyncedTxnsForAppends.isNotEmpty) {
            var gSheetTxnAppends = unsyncedTxnsForAppends
                .map(
                  (sale) => {
                    'soldItemId': sale.soldItemId,
                    'txnId': sale.txnId,
                    'userId': sale.userId,
                    'userEmail': sale.userEmail,
                    'userName': sale.userName,
                    'productId': sale.productId,
                    'productCode': sale.productCode,
                    'productName': sale.productName,
                    'quantity': sale.quantity,
                    'qtyRefunded': sale.qtyRefunded,
                    'refundReason': sale.refundReason,
                    'totalAmount': sale.totalAmount,
                    'amountIssued': sale.amountIssued,
                    'customerBalance': sale.customerBalance,
                    'unitBP': sale.unitBP,
                    'unitSellingPrice': sale.unitSellingPrice,
                    'deposit': sale.deposit,
                    'paymentMethod': sale.paymentMethod,
                    'customerName': sale.customerName,
                    'customerContacts': sale.customerContacts,
                    'txnAddress': sale.txnAddress,
                    'txnAddressCoordinates': sale.txnAddressCoordinates,
                    'lastModified': sale.lastModified,
                    'isSynced': 1,
                    'syncAction': 'none',
                    'txnStatus': sale.txnStatus,
                  },
                )
                .toList();

            // -- save sales data to cloud --
            StoreSheetsApi.initSpreadSheets();
            StoreSheetsApi.saveTxnsToGSheets(gSheetTxnAppends).then((
              result,
            ) async {
              if (result) {
                // -- update txns status locally --
                fetchSoldItems();
                for (var forSyncItem in unsyncedTxnsForAppends) {
                  await dbHelper.updateTxnItemsSyncStatus(
                    1,
                    'none',
                    forSyncItem.soldItemId!,
                  );
                }
                isLoading.value = false;
                txnsSyncIsLoading.value = false;
              } else {
                txnsSyncIsLoading.value = false;
                CPopupSnackBar.errorSnackBar(
                  title: 'ERROR SYNCING TXNS TO CLOUD...',
                  message: 'an error occurred while uploading txns to cloud',
                );
              }
            });
          } else {
            txnsSyncIsLoading.value = false;
            isLoading.value = false;
            if (kDebugMode) {
              print('***** ALL TXNS RADA SAFI *****');
              CPopupSnackBar.customToast(
                message: '***** ALL TXNS RADA SAFI *****',
                forInternetConnectivityStatus: false,
              );
            }
          }
        } else {
          txnsSyncIsLoading.value = false;
          isLoading.value = false;
          // CPopupSnackBar.customToast(
          //   message: 'NO SALES/TXNS FOUND!',
          //   forInternetConnectivityStatus: false,
          // );
        }
      });
      fetchSoldItems();
      return true;
    } catch (e) {
      txnsSyncIsLoading.value = false;
      isLoading.value = false;
      if (kDebugMode) {
        print('***');
        print('* an error occurred while uploading txns to cloud: $e *');
        print('***');
        CPopupSnackBar.errorSnackBar(
          title: 'ERROR SYNCING TXNS TO CLOUD...',
          message: 'an error occurred while uploading txns to cloud: $e',
        );
      }

      //throw e.toString();
      return false;
    }
    // finally {
    //   txnsSyncIsLoading.value = false;
    //   isLoading.value = false;
    // }
  }

  /// -- fetch txns from google sheets by userEmail --
  Future fetchUserTxnsSheetData() async {
    try {
      isLoading.value = true;

      var gSheetTxnsList = await StoreSheetsApi.fetchAllTxnsFromCloud();

      allGsheetTxnsData.assignAll(gSheetTxnsList!);

      userGsheetTxnsData.value = allGsheetTxnsData
          .where(
            (element) => element.userEmail.toLowerCase().contains(
              userController.user.value.email.toLowerCase(),
            ),
          )
          .toList();

      return userGsheetTxnsData;
    } catch (e) {
      isLoading.value = false;

      if (kDebugMode) {
        print('***');
        print(
          '* an error occurred while fetching user\'s cloud txn data: $e *',
        );
        print('***');
        CPopupSnackBar.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      }

      return CPopupSnackBar.errorSnackBar(
        title: 'Oh Snap!',
        message: 'an error occurred while fetching user\'s cloud txn data',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// -- import transactions from cloud --
  Future<bool> importTxnsFromCloud() async {
    try {
      isImportingTxnsFromCloud.value = true;

      await fetchSoldItems();

      await fetchUserTxnsSheetData();

      if (userGsheetTxnsData.isNotEmpty) {
        if (sales.isEmpty) {
          for (var element in userGsheetTxnsData) {
            var dbTxnImports = CTxnsModel.withId(
              element.soldItemId,
              element.txnId,
              element.userId,
              element.userEmail,
              element.userName,
              element.productId,
              element.productCode,
              element.productName,
              element.quantity,
              element.qtyRefunded,
              element.refundReason,
              element.totalAmount,
              element.amountIssued,
              element.customerBalance,
              element.unitBP,
              element.unitSellingPrice,
              element.deposit,
              element.paymentMethod,
              element.customerName,
              element.customerContacts,
              element.txnAddress,
              element.txnAddressCoordinates,
              element.lastModified,
              element.isSynced,
              element.syncAction,
              element.txnStatus,
            );

            await dbHelper.addSoldItem(dbTxnImports);
            await fetchSoldItems();
            isImportingTxnsFromCloud.value = false;
            isLoading.value = false;

            if (kDebugMode) {
              print(
                "----------\n ===SYNCED TXNS=== \n ${userGsheetTxnsData.iterator} \n\n ----------",
              );
            }
          }
        }
      }
      isImportingTxnsFromCloud.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('ERROR IMPORTING USER TXNS DATA FROM CLOUD!: $e');
        CPopupSnackBar.errorSnackBar(
          title: 'ERROR IMPORTING USER DATA FROM CLOUD!',
          message: e.toString(),
        );
      }
      return false;
    }
  }

  /// -- popup for item refund --
  void refundItemWarningPopup(CTxnsModel soldItem) {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(CSizes.sm),
      title: 'refund ${soldItem.productName}?',
      // middleText:
      //     'Are you certain you want to refund ${soldItem.productName} for $userCurrency.${soldItem.unitSellingPrice * soldItem.quantity}? This action can\'t be undone!',
      middleText: 'Are you certain you want to refund ${soldItem.productName}?',
      confirm: ElevatedButton(
        onPressed: () async {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: CSizes.sm),
          child: Text('confirm refund'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () {
          Navigator.of(Get.overlayContext!).pop();
        },
        child: const Text('cancel'),
      ),
    );
  }

  Future<dynamic> refundItemActionModal(
    BuildContext context,
    CTxnsModel soldItem,
  ) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      //transitionAnimationController: ,
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
                  'refund ${soldItem.productName.toUpperCase()}?',
                  style: Theme.of(context).textTheme.labelMedium!.apply(
                    color: isDarkTheme ? CColors.white : CColors.rBrown,
                  ),
                ),
                Text(
                  '${soldItem.quantity} sold (${soldItem.qtyRefunded} refunded)',
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
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('qty'),
                      const SizedBox(width: CSizes.spaceBtnInputFields),
                      CCircularIconBtn(
                        icon: Iconsax.minus,
                        iconBorderRadius: 100,
                        bgColor: CColors.black.withValues(alpha: 0.5),
                        width: 45.0,
                        height: 45.0,
                        iconColor: CColors.white,
                        onPressed: () {
                          if (refundQty.value > 0 &&
                              refundQty.value <= soldItem.quantity) {
                            refundQty.value -= 1;
                          }
                        },
                      ),
                      //const CFavoriteIcon(),
                      const SizedBox(width: CSizes.spaceBtnItems),
                      Text(
                        refundQty.value > soldItem.quantity
                            ? soldItem.quantity.toString()
                            : refundQty.value.toString(),
                        style: Theme.of(context).textTheme.titleSmall!.apply(
                          color: isDarkTheme ? CColors.white : CColors.rBrown,
                        ),
                      ),
                      const SizedBox(width: CSizes.spaceBtnItems),

                      CCircularIconBtn(
                        iconBorderRadius: 100,
                        // bgColor: (CNetworkManager.instance.hasConnection.value
                        //     ? CColors.rBrown
                        //     : CColors.black),
                        bgColor: CColors.black,
                        icon: Iconsax.add,
                        iconColor: CColors.white,
                        width: 45.0,
                        height: 45.0,
                        onPressed: () {
                          if (refundQty.value < soldItem.quantity) {
                            refundQty.value += 1;
                          }
                        },
                      ),
                    ],
                  );
                }),
                const SizedBox(height: CSizes.spaceBtnInputFields),

                // -- textarea for reason of refund --
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: txtRefundReason,
                    decoration: InputDecoration(
                      labelText: 'reason for refund(optional)',
                      //labelStyle: textStyle,
                      suffixIcon: const Icon(Iconsax.message),
                    ),
                    maxLines: 1, // marked for observation - could be a textarea
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
                // Divider(
                //   color: isDarkTheme ? CColors.white : CColors.rBrown,
                // ),
                const SizedBox(height: CSizes.spaceBtnInputFields),
                Row(
                  children: [
                    SizedBox(
                      width: CHelperFunctions.screenWidth() * 0.45,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // refund item actions - inventory & txn item updates;

                          await fetchSoldItems().then((result) async {
                            if (result.isNotEmpty) {
                              invController.fetchUserInventoryItems();
                              var invItemIndex = invController.inventoryItems
                                  .indexWhere(
                                    (item) =>
                                        item.productId == soldItem.productId,
                                  );
                              if (invItemIndex == -1) {
                                CPopupSnackBar.warningSnackBar(
                                  message:
                                      '${soldItem.productName} is no longer listed in your inventory',
                                  title: 'item not found!',
                                );
                              } else {
                                var inventoryItem = invController.inventoryItems
                                    .firstWhere(
                                      (item) =>
                                          item.productId == soldItem.productId,
                                    );

                                // -- update stock count & total sales for this inventory item --
                                if (inventoryItem.productId! > 100) {
                                  inventoryItem.quantity += refundQty.value;
                                  inventoryItem.qtyRefunded += refundQty.value;
                                  inventoryItem.qtySold -= refundQty.value;
                                  inventoryItem.lastModified = DateFormat(
                                    'yyyy-MM-dd @ kk:mm',
                                  ).format(clock.now());
                                  inventoryItem.syncAction =
                                      inventoryItem.isSynced == 1
                                      ? 'update'
                                      : 'append';

                                  await dbHelper
                                      .updateInventoryItem(
                                        inventoryItem,
                                        inventoryItem.productId!,
                                      )
                                      .then((result) async {
                                        /// -- update receipt item --
                                        var txnItem = sales.firstWhere(
                                          (txnItem) =>
                                              txnItem.productId ==
                                              soldItem.productId,
                                        );

                                        txnItem.refundReason = txtRefundReason
                                            .text
                                            .trim();
                                        txnItem.quantity -= refundQty.value;
                                        txnItem.qtyRefunded += refundQty.value;
                                        txnItem.totalAmount -=
                                            refundQty.value *
                                            txnItem.unitSellingPrice;
                                        txnItem.lastModified = DateFormat(
                                          'yyyy-MM-dd @ kk:mm',
                                        ).format(clock.now());
                                        txnItem.syncAction =
                                            txnItem.isSynced == 0
                                            ? 'append'
                                            : 'update';
                                        //txnItem.txnStatus = 'refunded';

                                        dbHelper
                                            .updateReceiptItem(
                                              txnItem,
                                              txnItem.soldItemId!,
                                            )
                                            .then((_) {
                                              fetchSoldItems();
                                              refundDataUpdated.value = true;
                                            });

                                        Navigator.of(
                                          Get.overlayContext!,
                                        ).pop(true);
                                      });
                                } else {
                                  if (kDebugMode) {
                                    print('ERROR: INVENTORY ITEM IS NULL');
                                    CPopupSnackBar.errorSnackBar(
                                      title: 'inv item error!!',
                                      message:
                                          'ERROR: INVENTORY ITEM productId IS NULL!!',
                                    );
                                  }
                                }
                              }
                            } else {
                              if (kDebugMode) {
                                print("** ========== **\n");
                                print("ERROR UPDATING DATA AFTER REFUND");
                                print("** ========== **\n");
                              }
                            }
                          });
                        },
                        label: Text(
                          'REFUND',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.apply(color: Colors.red),
                        ),
                        icon: Icon(Iconsax.wallet_check, color: Colors.red),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CColors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: CSizes.spaceBtnInputFields),
                    SizedBox(
                      width: CHelperFunctions.screenWidth() * 0.45,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          resetSalesFields();
                          Navigator.of(context).pop(true);
                        },
                        label: Text(
                          'cancel',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.apply(color: CColors.white),
                        ),
                        icon: Icon(Iconsax.undo, color: CColors.rBrown),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CColors.black.withValues(alpha: 0.5),
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
    ).whenComplete(() {
      onRefundBottomSheetClose();
    });
  }

  /// -- reset refundQty to 0 when bottomSheetModal dismisses --
  void onRefundBottomSheetClose() async {
    try {
      final syncController = Get.put(CSyncController());

      final internetIsConnected = await CNetworkManager.instance.isConnected();

      if (refundDataUpdated.value) {
        if (internetIsConnected) {
          //await syncController.processSync();
          if (await syncController.processSync()) {
            await fetchSoldItems();
            await invController.fetchUserInventoryItems();
            if (invController.unSyncedAppends.isNotEmpty ||
                invController.unSyncedUpdates.isNotEmpty ||
                unsyncedTxnAppends.isNotEmpty ||
                unsyncedTxnUpdates.isNotEmpty) {
              await syncController.processSync();
            }
          }
          // else {
          //   if (kDebugMode) {
          //     print('error processing cloud sync');
          //     CPopupSnackBar.errorSnackBar(
          //       title: 'error processing cloud sync',
          //       message: 'error processing cloud sync',
          //     );
          //   }
          // }
        } else {
          if (kDebugMode) {
            print('internet connection required for txns cloud sync!');
            CPopupSnackBar.customToast(
              message: 'internet connection required for txns cloud sync!',
              forInternetConnectivityStatus: true,
            );
          }
        }
      }

      updatesOnRefundDone.value = false;
      resetSalesFields();

      if (kDebugMode) {
        print('------------------\n');
        print('refundQty: ${refundQty.value} \n');
        print('------------------\n');
        print('bottomSheet closed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('### error syncing refund item ###\n');
        print('$e\n');
        print('### error syncing refund item ###\n');
        CPopupSnackBar.errorSnackBar(
          title: 'error syncing refund item!',
          message: e.toString(),
        );
      }
      rethrow;
    }
  }

  Future updateReceiptItemCloudData(int itemId, CTxnsModel itemModel) async {
    try {
      await StoreSheetsApi.updateReceiptItem(itemId, itemModel.toMap());
    } catch (e) {
      CPopupSnackBar.errorSnackBar(
        title: 'error updating sheet data',
        message: e.toString(),
      );

      //throw e.toString();
      rethrow;
    }
  }

  /// -- check if an inventory item exists by product name --
  Future<bool> checkIfInventoryItemExistsByName(String name) async {
    try {
      isLoading.value = true;

      final fetchedItemIndex = sales.indexWhere(
        (item) => item.productName.toLowerCase() == name.toLowerCase(),
      );

      bool returnValue;

      if (fetchedItemIndex != -1) {
        returnValue = true;
      } else {
        returnValue = false;
      }

      isLoading.value = false;

      return returnValue;
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('error checking inventory item by name: $e');
        CPopupSnackBar.errorSnackBar(
          title: 'error checking inventory item by name',
          message: e.toString(),
        );
      }
      rethrow;
    }
  }

  /// -- initialize sales summary values --
  Future<void> initializeSalesSummaryValues() async {
    try {
      // -- start loader --
      isLoading.value = true;
      // -- compute value of goods sold on credit --
      invoicesValue.value = sales
          .where(
            (creditSale) =>
                creditSale.txnStatus.toLowerCase().contains('invoiced'),
          )
          .fold(
            0.0,
            (sum, sale) => sum + (sale.quantity * sale.unitSellingPrice),
          );

      // -- compute cost of sales --
      costOfSales.value = sales
          .where((sale) => sale.quantity >= 1)
          .fold(0.0, (sum, sale) => sum + (sale.quantity * sale.unitBP));

      grossRevenue.value = sales.fold(
        0.0,
        (sum, sale) => sum + (sale.quantity * sale.unitSellingPrice),
      );

      // -- compute total revenue --
      moneyCollected.value = sales
          .where(
            (sale) =>
                sale.quantity >= 1 &&
                sale.txnStatus.toLowerCase().contains('complete'),
          )
          .fold(
            0.0,
            (sum, sale) => sum + (sale.quantity * sale.unitSellingPrice),
          );

      // -- compute gross profit --
      totalProfit.value = grossRevenue.value - costOfSales.value;

      await fetchTopSellersFromSales();

      // -- stop loader
      isLoading.value = false;
    } catch (e) {
      // -- stop loader
      isLoading.value = false;
      if (kDebugMode) {
        print('error summarizing sales: $e');
        CPopupSnackBar.errorSnackBar(
          message: 'error summarizing sales: $e',
          title: 'sales summary error',
        );
      }
      rethrow;
    }
  }

  /// -- summarize sales data --
  void summarizeSalesData() {
    try {
      // -- start loader --
      isLoading.value = true;

      final rawDateRange = dateRangeController.selectedDateRange.value;

      // final formattedStartDate = DateTime.parse(
      //   rawDateRange!.start.toLocal().toString().split(' ')[0],
      // );
      // var formattedEndDate = DateTime.parse(
      //   rawDateRange.end.toLocal().toString().split(' ')[0],
      // );
      final formattedStartDate = DateTime.parse(
        rawDateRange!.start.toLocal().toString().split(' ')[0],
      );
      var formattedEndDate = DateTime.parse(
        rawDateRange.end.toLocal().toString().split(' ')[0],
      );

      // -- compute total revenue --
      var filteredSales = sales
          .where(
            (soldItem) =>
                DateTime.parse(
                  soldItem.lastModified.replaceAll(' @', ''),
                ).isAfter(formattedStartDate.subtract(Duration(days: 0))) &&
                DateTime.parse(
                  soldItem.lastModified.replaceAll(' @', ''),
                ).isBefore(formattedEndDate.add(Duration(days: 1))),
          )
          .toList();
      // var filteredSales = sales
      //     .where(
      //       (soldItem) =>
      //           DateTime.parse(
      //             soldItem.lastModified.replaceAll(' @', ''),
      //           ).isAfter(formattedStartDate) &&
      //           DateTime.parse(
      //             soldItem.lastModified.replaceAll(' @', ''),
      //           ).isBefore(formattedEndDate),
      //     )
      //     .toList();

      // -- compute cost of sales --
      var cogs = filteredSales.fold(
        0.0,
        (sum, sale) => sum + (sale.unitBP * sale.quantity),
      );
      costOfSales.value = cogs;

      // -- compute money collected --
      moneyCollected.value = filteredSales
          .where((sale) => sale.txnStatus == 'complete')
          .fold(
            0.0,
            (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
          );

      // -- compute value of items sold on credit --
      invoicesValue.value = filteredSales
          .where((sale) => sale.txnStatus.toLowerCase().contains('invoiced'))
          .fold(
            0.0,
            (sum, credit) => sum + (credit.unitSellingPrice * credit.quantity),
          );

      // -- compute gross revenue --
      var tRevenue = filteredSales.fold(
        0.0,
        (sum, sale) => sum + (sale.unitSellingPrice * sale.quantity),
      );
      grossRevenue.value = tRevenue;

      // -- compute gross profit --
      totalProfit.value = grossRevenue.value - costOfSales.value;

      // -- stop loader --
      isLoading.value = false;
    } catch (e) {
      // -- stop loader --
      isLoading.value = false;
      if (kDebugMode) {
        print('error computing summary sales: $e');
        CPopupSnackBar.errorSnackBar(
          message: 'error fetching sales summary: $e',
          title: 'error fetching sales summary!',
        );
      }
      rethrow;
    }
  }

  String fetchInvItemById(int productId) {
    try {
      var itemInvIndex = invController.inventoryItems.indexWhere(
        (item) => item.productId == productId,
      );
      if (itemInvIndex != -1) {
        var thisItem = invController.inventoryItems.firstWhereOrNull(
          (invItem) => invItem.productId == productId,
        );

        var formattedOutput = thisItem!.calibration == 'units'
            ? thisItem.calibration.substring(0, thisItem.calibration.length - 1)
            : thisItem.calibration;

        return formattedOutput;
      } else {
        CPopupSnackBar.customToast(
          message: 'item is not listed in your inventory list',
          forInternetConnectivityStatus: false,
        );
        return '';
      }
    } catch (e) {
      if (kDebugMode) {
        print('error fetching inventory item by id: $e');
        CPopupSnackBar.errorSnackBar(
          message: 'error fetching inventory item by id: $e',
          title: 'error fetching inventory item!',
        );
      }
      rethrow;
    }
  }
}
