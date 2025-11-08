import 'package:cri_v3/common/widgets/appbar/app_bar.dart';
import 'package:cri_v3/features/personalization/controllers/update_name_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CUpdateName extends StatelessWidget {
  const CUpdateName({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final editNameController = Get.put(CUpdateNameController());

    return Scaffold(
      // -- custom appbar --
      appBar: CAppBar(
        showBackArrow: true,
        backIconColor: isDarkTheme ? CColors.white : CColors.rBrown,
        title: Text(
          'change your name',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backIconAction: () {
          Navigator.of(context).pop();
          //Get.back();
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(CSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- headings --
            Text(
              'use your real name for easy verification. this name will appear on several pages...',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: CSizes.spaceBtnSections),

            // -- textfield & button --
            Form(
              key: editNameController.editNameFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: editNameController.fullName,
                    validator: (value) =>
                        CValidator.validateEmptyText('full name', value),
                    expands: false,
                    decoration: const InputDecoration(
                      labelText: 'full name:',
                      prefixIcon: Icon(Iconsax.user),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CSizes.spaceBtnSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  editNameController.updateName();
                },
                child: const Text('save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
