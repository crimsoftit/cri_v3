import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/features/store/controllers/dashboard_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CDateRangePickerWidget extends StatelessWidget {
  const CDateRangePickerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.put(CDashboardController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return SizedBox(
      //borderRadius: CSizes.borderRadiusLg,
      height: 47.0,
      width: CHelperFunctions.screenWidth() * .9,

      child: TextFormField(
        controller: dashboardController.dateRangeFieldController,
        decoration: InputDecoration(
          //border: InputBorder.none,
          //focusedBorder: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17.0),
            borderSide: BorderSide(
              width: .01,
              color: isDarkTheme ? CColors.darkGrey : CColors.rBrown,
            ),
          ),
          //disabledBorder: InputBorder.none,
          //errorBorder: InputBorder.none,
          filled: true,
          fillColor: isDarkTheme ? CColors.transparent : CColors.lightGrey,

          labelText: 'filter by date/period',
          //labelStyle: textStyle,
          prefixIcon: Icon(
            Iconsax.calendar,
            color: CColors.darkGrey,
            size: CSizes.iconSm + 4,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.close,
              color: CColors.darkGrey,
              size: CSizes.iconSm,
            ),
            onPressed: () {
              dashboardController.dateRangeFieldController.text = '';
              dashboardController.filterEndDate.value = '';
              dashboardController.filterStartDate.value = '';
              dashboardController.toggleDateFieldVisibility();
            },
          ),
        ),
        onTap: () {
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
                  title: Align(
                    alignment: Alignment.center,
                    child: Text(
                      dashboardController.dateRangeFieldController.text == ''
                          ? 'pick start date'
                          : 'pick end date',
                    ),
                  ),
                  content: SizedBox(
                    width: CHelperFunctions.screenWidth() * .95,
                    height: 200.0,
                    child: CupertinoDatePicker(
                      initialDateTime: DateTime.now(),
                      onDateTimeChanged: (newDate) {
                        dashboardController.setFilterDates(newDate);
                      },
                      mode: CupertinoDatePickerMode.date,
                      showDayOfWeek: true,
                      //showTimeSeparator: true,
                    ),
                  ),
                  actions: [
                    // TextButton.icon(
                    //   onPressed: () {},
                    //   icon: Icon(
                    //     Iconsax.filter,
                    //     color: CColors.white,
                    //     size: CSizes.iconSm,
                    //   ),
                    //   label: Text(
                    //     'filter',
                    //     style: Theme.of(context).textTheme.labelMedium!.apply(
                    //       color: CColors.white,
                    //       fontSizeFactor: 1.2,
                    //     ),
                    //   ),
                    //   style: ElevatedButton.styleFrom(
                    //     foregroundColor:
                    //         CColors.white, // foreground (text) color
                    //     backgroundColor: isDarkTheme
                    //         ? CColors.white
                    //         : CColors.rBrown.withValues(
                    //             alpha: .2,
                    //           ), // background color
                    //   ),
                    // ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            CColors.error, // foreground (text) color
                        backgroundColor: isDarkTheme
                            ? CColors.white
                            : CColors.rBrown.withValues(
                                alpha: .2,
                              ), // background color
                      ),

                      child: Text(
                        'close',
                        style: Theme.of(context).textTheme.labelMedium!.apply(
                          color: CColors.rBrown,
                          fontSizeFactor: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
