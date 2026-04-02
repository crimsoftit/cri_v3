import 'package:cri_v3/features/personalization/controllers/contacts_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CContactDetailsScreen extends StatelessWidget {
  const CContactDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsController = Get.put(CContactsController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    var contactId = Get.arguments;

    var contactItem = contactsController.myContacts.firstWhereOrNull(
      (element) => element.contactId == contactId,
    );

    return Container(
      color: isDarkTheme ? CColors.transparent : CColors.white,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 1.0,
          shadowColor: CColors.rBrown.withValues(alpha: 0.1),
          iconTheme: IconThemeData(
            color: isDarkTheme ? CColors.white : CColors.rBrown,
          ),
          title: Text(
            '#${contactItem!.contactId}',
            style: Theme.of(context).textTheme.labelMedium!.apply(
              color: isDarkTheme ? CColors.grey : CColors.rBrown,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Iconsax.star,
                color: isDarkTheme ? CColors.white : CColors.rBrown,
                size: CSizes.iconMd,
              ),
            ),
            IconButton(
              onPressed: () {
                contactsController.updateContactActionModal(
                  context,
                  contactItem,
                  'edit',
                );
              },
              icon: Icon(
                Iconsax.edit,
                color: isDarkTheme ? CColors.white : CColors.rBrown,
                size: CSizes.iconMd,
              ),
            ),

            // IconButton(
            //   onPressed: () {

            //   },
            //   icon: Icon(
            //     Iconsax.notification,
            //     color: isDarkTheme ? CColors.white : CColors.rBrown,
            //   ),
            // ),
          ],
        ),
        backgroundColor: CColors.rBrown.withValues(
          alpha: 0.2,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10.0,
                      top: 20.0,
                    ),
                    child: CircleAvatar(
                      backgroundColor: CHelperFunctions.randomAstheticColor(),
                      radius: 40.0,
                      child:
                          CValidator.isFirstCharacterALetter(
                            contactItem.contactName,
                          )
                          ? Text(
                              contactItem.contactName[0].toUpperCase(),
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .apply(
                                    color: CColors.white,
                                    fontSizeFactor: 2.0,
                                  ),
                            )
                          : Icon(
                              Iconsax.user,
                              color: CHelperFunctions.randomAstheticColor(),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: CSizes.spaceBtnItems,
                ),
                Text(
                  contactItem.contactName,
                  style: Theme.of(context).textTheme.labelLarge!.apply(
                    fontSizeFactor: 2.0,
                  ),
                ),
                Text(
                  'country code: ${contactItem.contactCountryCode}',
                  style: Theme.of(context).textTheme.labelLarge!.apply(
                    fontSizeFactor: 1.0,
                  ),
                ),
                Text(
                  'iso code: ${contactItem.contactIsoCode}',
                  style: Theme.of(context).textTheme.labelLarge!.apply(
                    fontSizeFactor: 1.0,
                    color: CColors.white,
                  ),
                ),
                Text(
                  'last modified: ${contactItem.lastModified}',
                  style: Theme.of(context).textTheme.labelLarge!.apply(
                    fontSizeFactor: 1.0,
                    color: CColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
