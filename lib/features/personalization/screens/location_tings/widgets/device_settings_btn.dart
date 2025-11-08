import 'package:cri_v3/data/repos/auth/auth_repo.dart';
import 'package:cri_v3/features/personalization/controllers/location_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceSettingsBtn extends StatelessWidget {
  const DeviceSettingsBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final CLocationController locationController = Get.put<CLocationController>(
      CLocationController(),
    );

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              locationController.uCurCode.value != '' &&
                  locationController.uCountry.value != '' &&
                  locationController.uAddress.value != ''
              ? () async {
                  if (!locationController.updateLoading.value) {
                    locationController.updateUserLocationAndCurrencyDetails();
                    if (await locationController
                        .updateUserLocationAndCurrencyDetails()) {
                      AuthRepo.instance.screenRedirect();
                    }
                  }
                }
              : null,
          child: Text(
            locationController.updateLoading.value ? 'loading...' : 'CONTINUE',
            style: Theme.of(context).textTheme.labelMedium!.apply(
              color: locationController.uCurCode.value == ''
                  ? CColors.rBrown
                  : CColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
