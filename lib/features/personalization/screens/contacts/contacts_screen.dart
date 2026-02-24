import 'package:cri_v3/common/widgets/appbar/tab_bar.dart';
import 'package:cri_v3/common/widgets/appbar/v2_app_bar.dart';
import 'package:cri_v3/common/widgets/products/circle_avatar.dart';
import 'package:cri_v3/features/personalization/controllers/contacts_controller.dart';
import 'package:cri_v3/features/personalization/screens/contacts/widgets/contacts_expansion_panel_view.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/widgets/store_screen_header.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class CContactsScreen extends StatelessWidget {
  const CContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final contactsController = Get.put(CContactsController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    //final userController = Get.put(CUserController());

    return DefaultTabController(
      animationDuration: Duration(
        milliseconds: 300,
      ),
      length: 3,
      child: Container(
        color: isDarkTheme ? CColors.transparent : CColors.white,
        child: Scaffold(
          /// -- app bar --
          appBar: CVersion2AppBar(
            autoImplyLeading: false,
          ),
          backgroundColor: CColors.rBrown.withValues(alpha: 0.2),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  automaticallyImplyLeading: true,
                  backgroundColor: CColors.transparent,
                  bottom: const CTabBar(
                    tabs: [
                      Tab(
                        child: Text(
                          'Customers',
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Suppliers',
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Friends',
                        ),
                      ),
                    ],
                  ),
                  expandedHeight: 50.0,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        CStoreScreenHeader(
                          forStoreScreen: false,
                          title: 'Contacts',
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),
                  floating: false,
                  pinned: true,
                ),
              ];
            },
            body: const TabBarView(
              physics: BouncingScrollPhysics(),
              children: [
                CContactsExpansionPanelView(
                  space: 'customers',
                ),

                CContactsExpansionPanelView(
                  space: 'suppliers',
                ),

                Text(
                  'friend_1',
                ),
              ],
            ),
          ),

          // SingleChildScrollView(
          //   child: Padding(
          //     padding: const EdgeInsets.only(
          //       left: 10.0,
          //       right: 10.0,
          //       top: 10.0,
          //     ),
          //     child: Obx(
          //       () {
          //         return Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               'my contacts',
          //               style: Theme.of(context).textTheme.labelLarge!.apply(
          //                 color: CNetworkManager.instance.hasConnection.value
          //                     ? CColors.rBrown
          //                     : CColors.darkGrey,
          //                 fontSizeFactor: 2.5,
          //                 fontWeightDelta: -7,
          //               ),
          //             ),

          //             /// -- custom divider --
          //             CCustomDivider(leftPadding: 5.0),

          //             const SizedBox(
          //               height: CSizes.spaceBtnSections,
          //             ),
          //             CRoundedContainer(
          //               bgColor: CColors.transparent,
          //               child: TabBar(
          //                 tabs: [
          //                   Tab(
          //                     text: 'Suppliers',
          //                   ),
          //                   Tab(
          //                     text: 'Customers',
          //                   ),
          //                   Tab(
          //                     text: 'Friends',
          //                   ),
          //                 ],
          //               ),
          //             ),

          //             CRoundedContainer(
          //               bgColor: CColors.transparent,
          //               width: double.maxFinite,
          //               height: double.maxFinite,
          //               child: TabBarView(
          //                 physics: BouncingScrollPhysics(),
          //                 children: [
          //                   // Text(
          //                   //   'customer_1',
          //                   // ),
          //                   CTxnItemsListView(
          //                     space: 'sales',
          //                   ),
          //                   Text(
          //                     'supplier_1',
          //                   ),
          //                   Text(
          //                     'friend_1',
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ],
          //         );
          //       },
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}

class ContactsListView extends StatelessWidget {
  const ContactsListView({
    super.key,
    required this.isDarkTheme,
    required this.contactsController,
  });

  final bool isDarkTheme;
  final CContactsController contactsController;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        CSizes.borderRadiusLg,
      ),
      child: ListView.separated(
        itemBuilder: (_, index) {
          return Card(
            color: isDarkTheme
                ? CColors.rBrown.withValues(alpha: 0.3)
                : CColors.lightGrey,
            margin: EdgeInsets.all(1),
            child: ListTile(
              contentPadding: EdgeInsets.only(
                left: 5,
                right: 10.0,
              ),
              leading: CCircleAvatar(
                avatarInitial:
                    contactsController.myContacts[index].contactName[0],
              ),
              subtitle: Column(
                children: [
                  Text(
                    'mobile ${contactsController.myContacts[index].contactPhone}',
                  ),
                  Text(
                    'email ${contactsController.myContacts[index].contactEmail}',
                  ),
                  Text(
                    'productId ${contactsController.myContacts[index].productId}; category ${contactsController.myContacts[index].contactCategory}',
                  ),
                  Text(
                    'created ${contactsController.myContacts[index].createdAt}; last modified ${contactsController.myContacts[index].lastModified}',
                  ),
                ],
              ),
              title: Text(
                contactsController.myContacts[index].contactName,
              ),
              //tileColor: CColors.rBrown,
            ),
          );
        },
        itemCount: contactsController.myContacts.length,
        separatorBuilder: (_, __) {
          return SizedBox(
            height: CSizes.spaceBtnSections / 8,
          );
        },
        shrinkWrap: true,
      ),
    );
  }
}
