import 'package:clock/clock.dart';
import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/txt_fields/custom_typeahed_field.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/personalization/models/contacts_model.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/db/sqflite/db_helper.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:cri_v3/utils/validators/validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:send_message/send_message.dart';

class CContactsController extends GetxController {
  /// -- constructor --
  static CContactsController get instance => Get.find();

  /// -- variables --
  DbHelper dbHelper = DbHelper.instance;
  final invController = Get.put(CInventoryController());
  final updateContactItemFormKey = GlobalKey<FormState>();
  final userController = Get.put(CUserController());

  final txtEmailController = TextEditingController();
  final txtPhoneController = TextEditingController();

  final RxBool isLoading = false.obs;

  final RxList<CContactsModel> myContacts = <CContactsModel>[].obs;
  final RxList<CContactsModel> foundMatches = <CContactsModel>[].obs;
  final RxString contactCountryCode = ''.obs;

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
                        ) &&
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

  /// -- add a contact to the local database --
  Future addContact(
    bool fromInventoryDetails,
    CContactsModel? contact,
    int? productId,
  ) async {
    try {
      var contactDetails = CContactsModel(
        userController.user.value.email,
        productId,
        fromInventoryDetails
            ? invController.txtSupplierName.text.trim()
            : contact!.contactName,
        fromInventoryDetails ? '' : contact!.contactCountryCode,
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
        fromInventoryDetails
            ? DateFormat(
                'yyyy-MM-dd kk:mm',
              ).format(clock.now())
            : contact!.lastModified,
        fromInventoryDetails
            ? DateFormat('yyyy-MM-dd kk:mm').format(clock.now())
            : contact!.createdAt,
        0,
        'add',
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

  /// -- update contact details --
  Future<bool> updateContact(CContactsModel contact) async {
    try {
      // --  start loader --
      isLoading.value = true;

      dbHelper.updateContact(contact);

      // -- stop loader --
      isLoading.value = false;

      CPopupSnackBar.customToast(
        forInternetConnectivityStatus: false,
        message: 'contact updated successfully',
      );

      return true;
    } catch (e) {
      // -- stop loader --
      isLoading.value = false;
      if (kDebugMode) {
        print('error updating contact: $e');
        CPopupSnackBar.errorSnackBar(
          message: 'error updating contact: $e',
          title: 'error updating contact!',
        );
      } else {
        CPopupSnackBar.errorSnackBar(
          message: 'an unknown error occurred while updating contact details!',
          title: 'error updating contact!',
        );
      }
      rethrow;
    }
  }

  Future<dynamic> updateContactActionModal(
    BuildContext context,
    CContactsModel contactItem,
    String updateAction,
  ) async {
    try {
      final isDarkTheme = CHelperFunctions.isDarkMode(context);
      return showModalBottomSheet(
        backgroundColor: isDarkTheme
            ? CColors.black.withValues(
                alpha: .9,
              )
            : CColors.white,
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        useSafeArea: true,
        useRootNavigator: true,
        builder: (context) {
          // -- set field values --

          txtEmailController.text = txtEmailController.text == ''
              ? contactItem.contactEmail
              : txtEmailController.text.trim();
          txtPhoneController.text = txtPhoneController.text == ''
              ? contactItem.contactPhone
              : txtPhoneController.text.trim();

          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: CRoundedContainer(
              bgColor: CColors.transparent,
              height: CHelperFunctions.screenHeight() * 0.39,
              padding: const EdgeInsets.all(
                CSizes.lg / 3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: CHelperFunctions.randomAstheticColor(),
                        radius: 20.0,
                        child:
                            CValidator.isFirstCharacterALetter(
                              contactItem.contactName,
                            )
                            ? Text(
                                contactItem.contactName[0].toUpperCase(),
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .apply(
                                      color: CColors.white,
                                    ),
                              )
                            : Icon(
                                Iconsax.user,
                                color: CHelperFunctions.randomAstheticColor(),
                              ),
                      ),
                      const SizedBox(
                        width: CSizes.spaceBtnItems / 2.0,
                      ),
                      Text(
                        contactItem.contactName.toUpperCase(),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium!.apply(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30.0,
                      right: 30.0,
                      top: 30.0,
                    ),
                    child: Form(
                      key: updateContactItemFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CCustomTypeahedField(
                            fillColor: isDarkTheme
                                ? CColors.transparent
                                : CColors.lightGrey,
                            focusedBorderColor: isDarkTheme
                                ? CColors.white
                                : CColors.rBrown,
                            includePrefixIcon: true,
                            labelTxt: 'E-mail address',
                            onFieldValueChanged: (value) {
                              txtEmailController.text = value.trim();
                            },
                            onItemSelected: (suggestion) {
                              txtEmailController.text = suggestion.contactEmail;
                            },
                            prefixIcon: Icon(
                              Icons.contact_mail,
                              color: CColors.darkGrey,
                              size: CSizes.iconXs,
                            ),
                            typeAheadFieldController: txtEmailController,
                            fieldValidator: (value) {
                              if (value == null ||
                                  value == '' ||
                                  !CValidator.isValidEmail(
                                    value.trim(),
                                  )) {
                                return 'Please enter a valid e-mail address!';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(
                            height: CSizes.spaceBtnInputFields,
                          ),

                          // CInternationalPhoneNumberInput(
                          //   controller: txtPhoneController,
                          // ),

                          // const SizedBox(
                          //   height: CSizes.spaceBtnInputFields,
                          // ),
                          IntlPhoneField(
                            controller: txtPhoneController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: isDarkTheme
                                  ? CColors.transparent
                                  : CColors.lightGrey,
                              labelText: 'Phone number',
                            ),
                            // Default country code (e.g., India)
                            initialCountryCode: 'KE',
                            invalidNumberMessage: 'Invalid phone number!',
                            onChanged: (phone) {
                              if (kDebugMode) {
                                print('=========\n');
                                print('country code: ${phone.countryCode}\n');
                                print('---------\n');
                                print(
                                  'country iso code: ${phone.countryISOCode}\n',
                                );
                                print('---------\n');
                                print(
                                  'complete number: ${phone.completeNumber}\n',
                                );
                                print('=========\n');
                              }
                            },
                          ),
                          const SizedBox(
                            height: CSizes.spaceBtnInputFields,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 4,
                                child: TextButton.icon(
                                  icon: Icon(
                                    Iconsax.save_add,
                                    size: CSizes.iconSm,
                                    color: isDarkTheme
                                        ? CColors.rBrown
                                        : CColors.white,
                                  ),
                                  label: Text(
                                    'Update',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .apply(
                                          color: isDarkTheme
                                              ? CColors.rBrown
                                              : CColors.white,
                                        ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: CColors
                                        .white, // foreground (text) color
                                    backgroundColor: isDarkTheme
                                        ? CColors.white
                                        : CColors.rBrown, // background color
                                  ),
                                  onPressed: () async {
                                    // -- form validation
                                    if (!updateContactItemFormKey.currentState!
                                        .validate()) {
                                      return;
                                    }

                                    if (kDebugMode) {
                                      print('<<< safi >>>\n');
                                      print('radaree kaka...');
                                      print('<<< safi >>>\n');
                                    }
                                    contactItem.contactPhone =
                                        txtPhoneController.text.trim();
                                    contactItem.contactEmail =
                                        txtEmailController.text.trim();
                                    contactItem.lastModified = DateFormat(
                                      'yyyy-MM-dd kk:mm',
                                    ).format(clock.now());

                                    if (await updateContact(contactItem)) {
                                      Navigator.pop(
                                        Get.overlayContext!,
                                        true,
                                      );
                                      resetFields();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: CSizes.spaceBtnSections / 4,
                              ),
                              Expanded(
                                flex: 4,
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Iconsax.undo,
                                    size: CSizes.iconSm,
                                    color: CColors.rBrown,
                                  ),
                                  label: Text(
                                    'Back',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.labelMedium!.apply(
                                          color: CColors.rBrown,
                                        ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: CColors
                                        .rBrown, // foreground (text) color
                                    backgroundColor:
                                        CColors.white, // background color
                                  ),
                                  onPressed: () {
                                    //Navigator.pop(context, true);

                                    resetFields();
                                    Navigator.pop(
                                      Get.overlayContext!,
                                      true,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('error displaying bottom sheet modal: $e');
        CPopupSnackBar.errorSnackBar(
          message: 'error displaying bottom sheet modal: $e',
          title: 'error popping bottom sheet modal!',
        );
      }
      rethrow;
    }
  }

  Future<void> sendSimpleSms(List<String> recipients) async {
    String message = "hi,";
    try {
      String result = await sendSMS(
        message: message,
        recipients: recipients,
      );
      if (kDebugMode) {
        print("SMS sent: $result");
        CPopupSnackBar.successSnackBar(
          message: result,
          title: 'sms sent!',
        );
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error: $error");
        CPopupSnackBar.errorSnackBar(
          message: 'error sending simple sms: $error',
          title: 'error sending simple sms!',
        );
      } else {
        CPopupSnackBar.errorSnackBar(
          message: 'an unknown error occurred while sending sms!',
          title: 'error sending sms!',
        );
      }
      rethrow;
    }
  }

  Future<void> sendDirectSms() async {
    String message = "Test message!";
    List<String> recipients = ["1234567890", "5556787676"];

    try {
      String result = await sendSMS(
        message: message,
        recipients: recipients,
        sendDirect: true, // Skips confirmation dialog (Android only)
      );
      if (kDebugMode) {
        print("Direct SMS sent: $result");
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error: $error");
      }
      rethrow;
    }
  }

  resetFields() {
    contactCountryCode.value = '';
    txtEmailController.text = '';
    txtPhoneController.text = '';
  }
}
