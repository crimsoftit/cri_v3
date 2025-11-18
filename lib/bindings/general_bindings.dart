import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/checkout_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:cri_v3/utils/local_storage/storage_utility.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CGeneralBindings extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(() => CNetworkManager(), fenix: true);
    Get.lazyPut(() => CUserController(), fenix: true);
    Get.lazyPut(() => CTxnsController(), fenix: true);
    // Get.put(CNetworkManager());
    // Get.put(CTxnsController());

    /// -- todo: init local storage (GetX Local Storage) --
    GetStorage.init().then((_) async {
      Get.put(CLocalStorage.instance());

      Get.put(CCheckoutController());
    });
  }
}
