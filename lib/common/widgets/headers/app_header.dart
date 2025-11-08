import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/img_strings.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.title,
    required this.subTitle,
    required this.includeAfterSpace,
  });

  final bool includeAfterSpace;
  final String title, subTitle;

  @override
  Widget build(BuildContext context) {
    //final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge!.apply(
                  color: CNetworkManager.instance.hasConnection.value
                      ? CColors.rBrown
                      : CColors.darkGrey,
                  fontSizeFactor: 2.5,
                  fontWeightDelta: -7,
                ),
              ),
              const SizedBox(
                //width: double.infinity,
                child: Image(
                  height: 40.0,
                  //image: AssetImage( isDark ? RImages.darkAppLogo_1 : RImages.lightAppLogo_1),
                  // image: AssetImage(
                  //   isDarkTheme ? CImages.darkAppLogo : CImages.lightAppLogo,
                  // ),
                  image: AssetImage(CImages.darkAppLogo),
                ),
              ),
            ],
          ),

          // const SizedBox(
          //   height: CSizes.spaceBtnSections,
          // ),
          // Text(
          //   CTexts.loginTitle,
          //   style: Theme.of(context).textTheme.headlineMedium!.apply(
          //         color: CNetworkManager.instance.hasConnection.value
          //             ? CColors.rBrown
          //             : CColors.darkGrey,
          //       ),
          // ),
          Text(
            subTitle,
            style: Theme.of(context).textTheme.labelSmall!.apply(
              color: CNetworkManager.instance.hasConnection.value
                  ? CColors.rBrown
                  : CColors.darkGrey,
            ),
          ),
          const SizedBox(height: CSizes.spaceBtnSections / 2),
        ],
      ),
    );
  }
}
