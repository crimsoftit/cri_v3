import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class CFreshDashboardScreenView extends StatelessWidget {
  const CFreshDashboardScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return CRoundedContainer(
      width: CHelperFunctions.screenWidth() * .45,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(CSizes.defaultSpace / 3),
            //leading: Icon(Icons.account_circle),
            title: Icon(Icons.add),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'add your first item to get started!'.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ),
            //trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          const SizedBox(),
        ],
      ),
    );
  }
}
