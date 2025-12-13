import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class CStoreSummaryCard extends StatelessWidget {
  const CStoreSummaryCard({
    super.key,
    required this.titleTxt,
    this.iconData,
    this.onTap,
    this.subTitleTxt,
    this.containerWidth,
  });

  final double? containerWidth;
  final IconData? iconData;
  final String? subTitleTxt;
  final String titleTxt;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// -- store summary widgets go here --
        CRoundedContainer(
          width: containerWidth ?? CHelperFunctions.screenWidth() * 0.28,
          borderRadius: CSizes.cardRadiusSm / 1.5,
          padding: EdgeInsets.only(
            top: 2,
            bottom: CSizes.sm / 2,
            left: CSizes.sm / 3,
            right: CSizes.sm / 3,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: onTap,
            subtitle: Align(
              alignment: Alignment.topLeft,
              child: Text(
                subTitleTxt ?? '',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall!.apply(color: CColors.rBrown),
                textAlign: TextAlign.center,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titleTxt,
                      style: Theme.of(context).textTheme.titleMedium!.apply(
                        color: CColors.rBrown,
                        //fontSizeFactor: 1.1,
                        //fontWeightDelta: 2,
                      ),
                    ),
                    Icon(iconData, color: CColors.rBrown, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
