import 'package:cri_v3/common/widgets/search_bar/expanded_search_field.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:cri_v3/features/store/controllers/search_bar_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CAnimatedSearchBar extends StatelessWidget {
  const CAnimatedSearchBar({
    super.key,
    required this.hintTxt,
    this.boxColor,
    required this.controller,
  });

  final String hintTxt;
  final Color? boxColor;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(CSearchBarController());
    final salesController = Get.put(CTxnsController());
    final invController = Get.put(CInventoryController());

    return Obx(() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: searchController.showSearchField.value ? double.maxFinite : 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          borderRadius: searchController.showSearchField.value
              ? BorderRadius.circular(10.0)
              : BorderRadius.circular(20.0),
          color: boxColor,
          //boxShadow: kElevationToShadow[2],
        ),
        child: searchController.showSearchField.value
            ? CExpandedSearchField(
                txtColor: CColors.rBrown,
                controller: controller,
              )
            : Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(32),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(32),
                  ),
                  onTap: () {
                    searchController.toggleSearchFieldVisibility();
                    invController.fetchUserInventoryItems();
                    salesController.fetchSoldItems();
                  },
                  child: const Icon(
                    Iconsax.search_normal,
                    color: CColors.rBrown,
                    size: CSizes.iconMd,
                  ),
                ),
              ),
      );
    });
  }
}
