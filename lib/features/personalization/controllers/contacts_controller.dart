import 'package:clock/clock.dart';
import 'package:cri_v3/features/personalization/models/contacts_model.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/utils/db/sqflite/db_helper.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:cri_v3/utils/validators/validation.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CContactsController extends GetxController {
  /// -- constructor --
  static CContactsController get instance => Get.find();

  /// -- variables --
  DbHelper dbHelper = DbHelper.instance;
  final invController = Get.put(CInventoryController());

  final RxBool isLoading = false.obs;

  final RxList<CContactsModel> myContacts = <CContactsModel>[].obs;

  @override
  void onInit() {
    fetchContacts();
    super.onInit();
  }

  /// -- add a contact to the database --
  Future addContact(
    bool fromInventoryDetails,
    CContactsModel? contact,
    int? productId,
  ) async {
    try {
      var contactDetails = CContactsModel(
        fromInventoryDetails ? productId : 0,
        fromInventoryDetails
            ? invController.txtSupplierName.text.trim()
            : contact!.contactName,
        fromInventoryDetails &&
                CValidator.isValidPhoneNumber(
                  invController.txtSupplierContacts.text.trim(),
                )
            ? invController.txtSupplierContacts.text.trim()
            : fromInventoryDetails &&
                  !CValidator.isValidPhoneNumber(
                    invController.txtSupplierContacts.text.trim(),
                  )
            ? ''
            : contact!.contactPhone,
        fromInventoryDetails &&
                CValidator.isValidEmail(
                  invController.txtSupplierContacts.text.trim(),
                )
            ? invController.txtSupplierContacts.text.trim()
            : fromInventoryDetails &&
                  !CValidator.isValidEmail(
                    invController.txtSupplierContacts.text.trim(),
                  )
            ? ''
            : contact!.contactEmail,
        fromInventoryDetails ? 'supplier' : contact!.contactCategory,
        DateFormat(
          'yyyy-MM-dd kk:mm',
        ).format(clock.now()),
        DateFormat('yyyy-MM-dd kk:mm').format(clock.now()),
      );

      await dbHelper.addContact(contact ?? contactDetails);

      if (kDebugMode) {
        print(
          '${contactDetails.contactName} ${contactDetails.contactPhone} ${contactDetails.contactEmail} added successfully',
        );
        CPopupSnackBar.successSnackBar(
          message:
              '${contactDetails.contactName} ${contactDetails.contactPhone} ${contactDetails.contactEmail} added successfully',
          title: 'contact added',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('error adding contact: $e');
        CPopupSnackBar.errorSnackBar(
          message: 'an error occurred while adding contact: $e',
          title: 'error adding contact!',
        );
      }
      rethrow;
    }
  }

  /// -- fetch contacts from sqflite db --
  Future<List<CContactsModel>> fetchContacts() async {
    try {
      // start loader while contacts are fetched
      isLoading.value = true;

      final fetchedContacts = await dbHelper.fetchContacts();
      myContacts.assignAll(fetchedContacts);

      List<CContactsModel> returnItems;

      switch (myContacts.isEmpty) {
        case true:
          returnItems = [];
          break;
        case false:
          returnItems = myContacts;
          break;
      }

      // stop loader
      isLoading.value = false;
      return returnItems;
    } catch (e) {
      // stop loader
      isLoading.value = false;
      if (kDebugMode) {
        print('error fetching contacts: $e');
        CPopupSnackBar.errorSnackBar(
          message: 'an error occurred while fetching contacts: $e',
          title: 'error fetching contacts!',
        );
      }
      rethrow;
    }
  }

  // static List<String> getSuggestions(String query) {
  //   List<String> matches = [];
  //   matches.addAll(iterable)
  // }
}
