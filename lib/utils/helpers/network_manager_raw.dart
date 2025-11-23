import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CNetworkManagerRaw extends GetxController {
  static CNetworkManagerRaw get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final RxList<ConnectivityResult> _connectionStatus =
      <ConnectivityResult>[].obs;

  // -- initialize the network manager and set up a stream to continually check the connection status --
  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  // -- check internet connection status --
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();

      if (result.any((element) => element == ConnectivityResult.none)) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }

  // -- update the connection status and show relevant popup --
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _connectionStatus.value = result;
    if (result.contains(ConnectivityResult.none)) {
      CPopupSnackBar.customToast(
        message: 'no internet connection! offline cruise...',
        forInternetConnectivityStatus: true,
      );
    }
  }

  // -- dispose or close the active connectivity stream
  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }
}
