import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class CCustomDropdownBtn extends StatelessWidget {
  const CCustomDropdownBtn({
    super.key,
    required this.dropdownItems,
    required this.onValueChanged,
    this.initialValue,
    this.underlineColor = CColors.white,
    this.underlineHeight,
  });

  final Color? underlineColor;
  final double? underlineHeight;
  final List<String> dropdownItems;
  final String? initialValue;
  final void Function(String?) onValueChanged;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return DropdownButton<String>(
      borderRadius: BorderRadius.circular(10.0),
      elevation: 10,
      items: dropdownItems.map(
        (
          String value,
        ) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelLarge!.apply(
                color: isDarkTheme ? CColors.white : CColors.rBrown,
              ),
            ),
          );
        },
      ).toList(),
      onChanged: onValueChanged,
      style: Theme.of(context).textTheme.labelLarge!.apply(
        color: CColors.rBrown,
      ),
      dropdownColor: isDarkTheme
          ? CColors.rBrown
          : CColors.white.withValues(
              alpha: 0.6,
            ),
      icon: Icon(
        Icons.arrow_drop_down,
        color: isDarkTheme ? CColors.white : CColors.rBrown,
      ),
      underline: Container(
        // color: isDarkTheme ? CColors.white : CColors.rBrown,
        color: underlineColor,
        height: underlineHeight ?? 2.0,
      ),
      padding: const EdgeInsets.only(
        left: 5.0,
        right: 5.0,
      ),
      value: initialValue,
    );
  }
}
