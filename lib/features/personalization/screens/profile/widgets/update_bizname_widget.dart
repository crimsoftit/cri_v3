import 'package:cri_v3/common/widgets/appbar/app_bar.dart';
import 'package:cri_v3/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:cri_v3/features/personalization/controllers/set_bizname_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/img_strings.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:cri_v3/utils/popups/snackbars.dart';
import 'package:cri_v3/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CUpdateBusinessName extends StatelessWidget {
  const CUpdateBusinessName({super.key});

  @override
  Widget build(BuildContext context) {
    final bizNameController = Get.put(CSetBiznameController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // -- header --
            CPrimaryHeaderContainer(
              child: Column(
                children: [
                  // app bar
                  CAppBar(
                    title: Text(
                      'set business name',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall!.apply(color: CColors.white),
                    ),
                    backIconAction: () {
                      Navigator.pop(context, true);
                      //Get.back();
                    },
                    showBackArrow: true,
                    backIconColor: CColors.white,
                    showSubTitle: true,
                  ),

                  const SizedBox(height: CSizes.spaceBtnSections / 2),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(CSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // -- headings --
                  const SizedBox(
                    child: Image(
                      height: 90.0,
                      image: AssetImage(CImages.darkAppLogo),
                    ),
                  ),
                  const SizedBox(height: CSizes.spaceBtnItems),
                  Text(
                    'use your real business name for easy verification. this name will appear on several pages...',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: CSizes.spaceBtnSections),

                  // -- textfield & button --
                  Form(
                    key: bizNameController.editBizNameFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: bizNameController.bizNameField,
                          validator: (value) => CValidator.validateEmptyText(
                            'busness name',
                            value,
                          ),
                          expands: false,
                          decoration: const InputDecoration(
                            labelText: 'busness name:',
                            prefixIcon: Icon(Iconsax.building),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: CSizes.spaceBtnSections / 4),
                  Center(
                    child: SizedBox(
                      width: CHelperFunctions.screenWidth() * 0.7,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              CNetworkManager.instance.hasConnection.value
                              ? CColors.rBrown
                              : CColors.black,
                          padding: const EdgeInsets.all(CSizes.xs),
                          side: const BorderSide(color: CColors.rBrown),
                        ),
                        onPressed: () async {
                          final internetIsConnected = await CNetworkManager
                              .instance
                              .isConnected();
                          if (internetIsConnected) {
                            bizNameController.updateBizName();
                          } else {
                            CPopupSnackBar.warningSnackBar(
                              title: 'offline',
                              message: 'no internet connection',
                            );
                          }
                        },
                        label: Text(
                          'continue'.toUpperCase(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.apply(color: CColors.white),
                        ),
                        icon: Icon(
                          Iconsax.save_add,
                          size: CSizes.iconSm,
                          color: CColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
