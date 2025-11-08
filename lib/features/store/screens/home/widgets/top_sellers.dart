import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/products/circle_avatar.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CTopSellers extends StatelessWidget {
  const CTopSellers({super.key});

  @override
  Widget build(BuildContext context) {
    final invController = Get.put(CInventoryController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return Obx(() {
      return SizedBox(
        height: 40.0,
        child: ListView.separated(
          itemCount: invController.topSellers.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (_, __) {
            return SizedBox(width: CSizes.spaceBtnItems / 2);
          },
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Get.toNamed(
                  '/inventory/item_details/',
                  arguments: invController.topSellers[index].productId,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CCircleAvatar(
                    avatarInitial: invController.topSellers[index].name[0]
                        .toUpperCase(),
                    bgColor: CColors.white,
                    radius: 20.0,
                    txtColor: CColors.rBrown,
                  ),
                  const SizedBox(width: CSizes.spaceBtnItems / 5),
                  CRoundedContainer(
                    bgColor: CColors.transparent,
                    showBorder: false,
                    width: 90.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          invController.topSellers[index].name.toUpperCase(),
                          style: Theme.of(context).textTheme.labelMedium!.apply(
                            fontWeightDelta: -2,
                            color: isDarkTheme ? CColors.grey : CColors.rBrown,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '${invController.topSellers[index].qtySold} sold',
                          style: Theme.of(context).textTheme.labelMedium!.apply(
                            color: CColors.darkGrey,
                          ),
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
