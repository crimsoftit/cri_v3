import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CDateRangePickerWidget extends StatelessWidget {
  const CDateRangePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          fullscreenDialog: true,
          builder: (BuildContext context) {
            return CRoundedContainer(
              bgColor: isDarkTheme
                  ? CColors.transparent
                  : CColors.white.withValues(alpha: 0.6),
              width: CHelperFunctions.screenWidth() * .95,
              height: 200.0,
              child: AlertDialog(
                insetPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                title: const Text('select date/range'),
                content: SizedBox(
                  width: CHelperFunctions.screenWidth() * .95,
                  height: 200.0,
                  child: CupertinoDatePicker(
                    onDateTimeChanged: (newDate) {},
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime.now(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
      label: Text('pick date range'),
      icon: Icon(Iconsax.calendar),
    );
  }
}
