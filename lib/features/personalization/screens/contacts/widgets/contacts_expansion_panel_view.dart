import 'package:cri_v3/common/widgets/shimmers/vert_items_shimmer.dart';
import 'package:cri_v3/features/personalization/controllers/contacts_controller.dart';
import 'package:cri_v3/features/personalization/screens/no_data/no_data_screen.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/img_strings.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:cri_v3/utils/validators/validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CContactsExpansionPanelView extends StatelessWidget {
  const CContactsExpansionPanelView({
    super.key,
    required this.space,
  });

  final String space;

  @override
  Widget build(BuildContext context) {
    final contactsController = Get.put(CContactsController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return SingleChildScrollView(
      child: Obx(
        () {
          var demContacts = [];

          switch (space) {
            case 'all':
              demContacts.assignAll(contactsController.myContacts);
              break;
            case 'customers':
              demContacts.assignAll(
                contactsController.myContacts.where(
                  (contact) => contact.contactCategory.toLowerCase().contains(
                    'customer'.toLowerCase(),
                  ),
                ),
              );
              break;
            case 'friends':
              demContacts.assignAll(
                contactsController.myContacts.where(
                  (contact) => contact.contactCategory.toLowerCase().contains(
                    'friend'.toLowerCase(),
                  ),
                ),
              );
              break;
            case 'suppliers':
              demContacts.assignAll(
                contactsController.myContacts.where(
                  (contact) => contact.contactCategory.toLowerCase().contains(
                    'supplier'.toLowerCase(),
                  ),
                ),
              );
              break;
            default:
              demContacts.clear();

              if (kDebugMode) {
                CPopupSnackBar.errorSnackBar(
                  message: 'no contacts for this tab space!',
                  title: 'invalid tab space',
                );
              }
          }

          if (contactsController.isLoading.value &&
              contactsController.myContacts.isNotEmpty) {
            return const CVerticalProductShimmer(
              itemCount: 5,
            );
          }
          if (demContacts.isEmpty && !contactsController.isLoading.value) {
            return Center(
              child: NoDataScreen(
                lottieImage: CImages.pencilAnimation,
                txt: space == 'all'
                    ? 'All your contacts appear here...'
                    : 'Your $space\' contacts appear here...',
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(
              left: 2.0,
              right: 2.0,
              top: 10.0,
            ),
            child: Card(
              color: isDarkTheme
                  ? CColors.rBrown.withValues(
                      alpha: 0.3,
                    )
                  : CColors.lightGrey,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  CSizes.borderRadiusLg,
                ),
                child: ExpansionPanelList.radio(
                  animationDuration: const Duration(
                    milliseconds: 400,
                  ),
                  elevation: 3,
                  expandedHeaderPadding: EdgeInsets.all(
                    2.0,
                  ),
                  // expandIconColor: CNetworkManager.instance.hasConnection.value
                  //     ? CColors.rBrown
                  //     : CColors.darkGrey,
                  expandIconColor: CColors.transparent,
                  expansionCallback: (panelIndex, isExpanded) {
                    if (isExpanded) {
                      // Perform an action when the panel is expanded
                      if (kDebugMode) {
                        print('Panel at index $panelIndex is now expanded');
                      }
                    } else {
                      // Perform an action when the panel is collapsed
                      if (kDebugMode) {
                        print('Panel at index $panelIndex is now collapsed');
                      }
                    }
                  },
                  materialGapSize: 10.0,
                  children: demContacts.map(
                    (contact) {
                      return ExpansionPanelRadio(
                        backgroundColor: isDarkTheme
                            ? CColors.rBrown.withValues(
                                alpha: 0.3,
                              )
                            : CColors.lightGrey,
                        canTapOnHeader: true,
                        highlightColor: CColors.rBrown,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 2.0,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      CHelperFunctions.randomAstheticColor(),
                                  radius: 20.0,
                                  child:
                                      CValidator.isFirstCharacterALetter(
                                        contact.contactName,
                                      )
                                      ? Text(
                                          contact.contactName[0].toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .apply(
                                                color: CColors.white,
                                              ),
                                        )
                                      : Icon(
                                          Iconsax.user,
                                          color:
                                              CHelperFunctions.randomAstheticColor(),
                                        ),
                                ),
                                const SizedBox(
                                  width: CSizes.spaceBtnItems,
                                ),
                                // Text(
                                //   contact.contactId.toString(),
                                // ),
                                Text(
                                  contact.contactName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .apply(
                                        fontSizeFactor: 1.1,
                                      ),
                                ),
                              ],
                            ),
                            trailing: SizedBox.shrink(),
                          );
                        },
                        value: contact.contactId,

                        body: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 4.0,
                            left: 63.0,
                            right: 4.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'mobile ${contact.contactPhone}',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelMedium!.apply(
                                            fontWeightDelta: 2,
                                          ),
                                    ),
                                    TextButton.icon(
                                      icon: Icon(
                                        Iconsax.add,
                                        color: isDarkTheme
                                            ? CColors.white
                                            : CColors.rBrown,
                                        size: CSizes.iconSm,
                                      ),
                                      label: Text(
                                        contact.contactPhone != ''
                                            ? 'add e-mail'
                                            : 'add phone no.',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium!.apply(),
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton.outlined(
                                    color: CColors.rBrown,
                                    icon: Icon(
                                      Iconsax.call_outgoing,
                                      color: isDarkTheme
                                          ? CColors.white
                                          : CColors.rBrown,
                                    ),
                                    onPressed: () {},
                                  ),
                                  IconButton.outlined(
                                    color: CColors.rBrown,
                                    //focusColor: CColors.rBrown,
                                    icon: Icon(
                                      Iconsax.message,
                                      color: isDarkTheme
                                          ? CColors.white
                                          : CColors.rBrown,
                                    ),
                                    onPressed: () {},
                                  ),
                                  IconButton.outlined(
                                    //color: Colors.lightGreen,
                                    icon: Icon(
                                      Iconsax.information,
                                      color: isDarkTheme
                                          ? CColors.white
                                          : CColors.rBrown,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
