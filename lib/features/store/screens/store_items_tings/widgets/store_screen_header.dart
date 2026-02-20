import 'package:cri_v3/common/widgets/products/cart/cart_counter_icon.dart';
import 'package:cri_v3/common/widgets/shimmers/shimmer_effects.dart';
import 'package:cri_v3/features/store/controllers/cart_controller.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/sync_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/features/store/models/inv_model.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/checkout/widgets/checkout_scan_fab.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CStoreScreenHeader extends StatelessWidget {
  const CStoreScreenHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    AddUpdateItemDialog dialog = AddUpdateItemDialog();
    final cartController = Get.put(CCartController());
    final invController = Get.put(CInventoryController());
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    final syncController = Get.put(CSyncController());
    final txnsController = Get.put(CTxnsController());

    return Obx(() {
      return Container(
        // padding: const EdgeInsets.only(left: 2.0),
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge!.apply(
                color: CNetworkManager.instance.hasConnection.value
                    ? CColors.rBrown
                    : CColors.darkGrey,
                fontSizeFactor: 2.5,
                fontWeightDelta: -7,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// -- button to add inventory item --
                FloatingActionButton(
                  elevation: 0, // -- removes shadow
                  onPressed: () {
                    invController.resetInvFields();
                    showDialog(
                      context: context,
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
                          '',
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
                          '',
                          0,
                          '',
                        ),
                        true,
                        false,
                      ),
                    );
                  },
                  backgroundColor: CColors.transparent,
                  foregroundColor: isConnectedToInternet
                      ? CColors.rBrown
                      : CColors.darkGrey,
                  heroTag: 'add',
                  child: Icon(
                    // Iconsax.scan_barcode,
                    Iconsax.add,
                  ),
                ),

                invController.unSyncedAppends.isEmpty &&
                        invController.unSyncedUpdates.isEmpty &&
                        txnsController.unsyncedTxnAppends.isEmpty &&
                        txnsController.unsyncedTxnUpdates.isEmpty
                    ? Icon(
                        Iconsax.cloud_add,
                        color: isConnectedToInternet
                            ? CColors.rBrown
                            : CColors.darkGrey,
                      )
                    : syncController.processingSync.value
                    ? CShimmerEffect(width: 40.0, height: 40.0, radius: 40.0)
                    : FloatingActionButton(
                        elevation: 0, // -- removes shadow
                        onPressed:
                            invController.unSyncedAppends.isEmpty &&
                                invController.unSyncedUpdates.isEmpty &&
                                txnsController.unsyncedTxnAppends.isEmpty &&
                                txnsController.unsyncedTxnUpdates.isEmpty &&
                                syncController.processingSync.value &&
                                invController.isLoading.value &&
                                txnsController.isLoading.value
                            ? null
                            : () async {
                                // -- check internet connectivity --
                                final internetIsConnected =
                                    await CNetworkManager.instance
                                        .isConnected();

                                if (internetIsConnected) {
                                  // -- check if sync is really necessary --
                                  await invController.fetchUserInventoryItems();
                                  await txnsController.fetchSoldItems();

                                  if (invController
                                          .unSyncedAppends
                                          .isNotEmpty ||
                                      invController
                                          .unSyncedUpdates
                                          .isNotEmpty ||
                                      txnsController
                                          .unsyncedTxnAppends
                                          .isNotEmpty ||
                                      txnsController
                                          .unsyncedTxnUpdates
                                          .isNotEmpty) {
                                    await syncController.processSync();
                                  } else {
                                    if (kDebugMode) {
                                      print('rada safi mkuu!!');
                                      CPopupSnackBar.customToast(
                                        message: 'rada safi nani',
                                        forInternetConnectivityStatus: false,
                                      );
                                    }
                                  }
                                } else {
                                  CPopupSnackBar.customToast(
                                    message:
                                        'internet connection required for cloud sync!',
                                    forInternetConnectivityStatus: true,
                                  );
                                }
                              },
                        backgroundColor: CColors.transparent,
                        foregroundColor: isConnectedToInternet
                            ? CColors.rBrown
                            : CColors.darkGrey,
                        heroTag: 'sync',
                        child: Icon(Iconsax.cloud_change),
                      ),

                /// -- checkout --
                if (cartController.cartItems.isEmpty)
                  CCartCounterIcon(
                    iconColor: isConnectedToInternet
                        ? CColors.rBrown
                        : CColors.darkGrey,
                  ),

                // -- scan item for checkout btn --
                CCheckoutScanFAB(
                  elevation: 0.0,
                  bgColor: CColors.transparent,
                  foregroundColor: CNetworkManager.instance.hasConnection.value
                      ? CColors.rBrown
                      : CColors.darkGrey,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
