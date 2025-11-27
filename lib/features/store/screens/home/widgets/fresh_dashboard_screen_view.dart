import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/features/store/controllers/inv_controller.dart';
import 'package:cri_v3/features/store/models/inv_model.dart';
import 'package:cri_v3/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CFreshDashboardScreenView extends StatelessWidget {
  const CFreshDashboardScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    AddUpdateItemDialog dialog = AddUpdateItemDialog();
    final invController = Get.put(CInventoryController());

    return CRoundedContainer(
      width: CHelperFunctions.screenWidth() * .45,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(CSizes.defaultSpace / 3),
            onTap: () {
              invController.resetInvFields();
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (BuildContext context) => dialog.buildDialog(
                  context,
                  CInventoryModel(
                    '',
                    '',
                    '',
                    '',
                    '',
                    0,
                    0,
                    0,
                    0,
                    0.0,
                    0.0,
                    0.0,
                    0,
                    '',
                    '',
                    '',
                    '',
                    '',
                    0,
                    '',
                  ),
                  true,
                  true,
                ),
              );
            },
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'add your first item to get started!'.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.apply(color: CColors.rBrown),
                textAlign: TextAlign.center,
              ),
            ),
            title: Icon(Icons.add, color: CColors.rBrown),

            //trailing: Icon(Icons.more_vert),
          ),
          const SizedBox(),
        ],
      ),
    );
  }
}
