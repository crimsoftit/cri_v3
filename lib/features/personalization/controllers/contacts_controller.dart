import 'package:clock/clock.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
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
  final userController = Get.put(CUserController());

  final RxBool isLoading = false.obs;

  final RxList<CContactsModel> myContacts = <CContactsModel>[].obs;
  final RxList<CContactsModel> foundMatches = <CContactsModel>[].obs;

  // TODO: FETCH CLOUD CONTACTS FROM INVENTORY AND SALES
  @override
  void onInit() async {
    foundMatches.value = [];
    await fetchMyContacts();
    super.onInit();
  }

  /// -- check if contact details exist in the database --
  Future<bool> contactActionIsAdd(
    String contactName,
    String contactDetails,
  ) async {
    try {
      bool addContact = false;
      List<CContactsModel> contactMatches = [];
      await fetchMyContacts().then(
        (results) {
          switch (results.isNotEmpty) {
            case true:
              contactMatches = myContacts
                  .where(
                    (match) =>
                        match.contactName.toLowerCase().contains(
                          contactName.toLowerCase(),
                        ) ||
                        (match.contactEmail.toLowerCase().contains(
                              contactDetails.toLowerCase(),
                            ) ||
                            match.contactPhone.toLowerCase().contains(
                              contactDetails.toLowerCase(),
                            )),
                  )
                  .toList();
              if (contactMatches.isNotEmpty) {
                addContact = false;
              } else {
                addContact = true;
              }
              break;

            default:
              contactMatches = [];
              addContact = true;
              break;
          }
        },
      );

      return addContact;
    } catch (e) {
      if (kDebugMode) {
        print('error checking contact existence: $e');
        CPopupSnackBar.errorSnackBar(
          message: 'error checking contact existence: $e',
          title: 'error checking contact existence!',
        );
      }
      rethrow;
    }
  }

  /// -- add a contact to the database --
  Future addUpdateContact(
    bool fromInventoryDetails,
    CContactsModel? contact,
    int? productId,
  ) async {
    try {
      var contactDetails = CContactsModel(
        userController.user.value.email,
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
      fetchMyContacts();
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
  Future<List<CContactsModel>> fetchMyContacts() async {
    try {
      // start loader while contacts are fetched
      isLoading.value = true;

      final fetchedContacts = await dbHelper.fetchUserContacts(
        userController.user.value.email,
      );
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

  Future<List<CContactsModel>> getContactSuggestion(String query) async {
    try {
      List<CContactsModel> contactMatches = [];
      await fetchMyContacts();

      contactMatches.addAll(myContacts);
      contactMatches.retainWhere(
        (contact) {
          return contact.contactName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              contact.contactPhone.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              contact.contactEmail.toLowerCase().contains(
                query.toLowerCase(),
              );
        },
      );
      return contactMatches;
    } catch (e) {
      if (kDebugMode) {
        print('error fetching contact suggestions: $e');
        CPopupSnackBar.errorSnackBar(
          message: 'error fetching contact suggestions: $e',
          title: 'error fetching contact suggestions!',
        );
      }
      rethrow;
    }
  }

  contactSuggestionsCallBackAction(String pattern) {
    foundMatches.clear;
    foundMatches.value = myContacts
        .where(
          (contact) =>
              contact.contactName.toLowerCase().contains(
                pattern.toLowerCase(),
              ) ||
              contact.contactPhone.toLowerCase().contains(
                pattern.toLowerCase(),
              ) ||
              contact.contactEmail.toLowerCase().contains(
                pattern.toLowerCase(),
              ),
        )
        .toList();

    return foundMatches;
  }
}
