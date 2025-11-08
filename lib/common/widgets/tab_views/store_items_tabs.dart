import 'package:cri_v3/features/store/screens/store_items_tings/widgets/inv_gridview_screen.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/widgets/items_listview.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class CStoreItemsTabs extends StatelessWidget {
  const CStoreItemsTabs({
    super.key,
    required this.tab1Title,
    required this.tab2Title,
    required this.tab3Title,
  });

  final String tab1Title, tab2Title, tab3Title;

  @override
  Widget build(BuildContext context) {
    //final tabBarController = Get.put(CTabBarController());

    return Column(
      children: [
        /// -- tabs --
        SizedBox(
          child: TabBar(
            dividerColor: CColors.rBrown.withValues(alpha: 0.5),
            isScrollable: true,
            labelColor: CColors.rBrown,
            // labelPadding: const EdgeInsets.only(
            //   left: 10.0,
            //   right: 10.0,
            // ),
            onTap: (value) {
              //tabBarController.onTabItemTap(value);
            },
            unselectedLabelColor: CColors.darkGrey,
            tabs: [
              Tab(text: tab1Title),
              Tab(text: tab2Title),
              Tab(text: tab3Title),
            ],
          ),
        ),

        /// -- tab bar views
        SizedBox(
          height: CHelperFunctions.screenHeight() * 0.7,
          child: const TabBarView(
            physics: BouncingScrollPhysics(),
            children: [
              /// -- inventory list items --
              CInvGridviewScreen(),

              /// -- transactions list view --
              CItemsListView(space: 'sales'),

              CItemsListView(space: 'refunds'),
            ],
          ),
        ),
      ],
    );
  }
}
