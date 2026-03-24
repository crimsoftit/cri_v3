import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/features/personalization/controllers/contacts_controller.dart';
import 'package:cri_v3/features/personalization/models/contacts_model.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CCustomTypeahedField extends StatelessWidget {
  const CCustomTypeahedField({
    super.key,
    this.fieldHeight,
    this.fieldLabelStyle,
    this.fieldValidator,
    this.fillColor,
    this.minHeight,
    this.prefixIcon,
    required this.labelTxt,
    required this.typeAheadFieldController,
    required this.onItemSelected,
    required this.includePrefixIcon,
  });

  final bool includePrefixIcon;
  final Color? fillColor;
  final double? fieldHeight, minHeight;

  final String labelTxt;
  final TextEditingController typeAheadFieldController;
  final TextStyle? fieldLabelStyle;
  final Widget? prefixIcon;
  final void Function(CContactsModel) onItemSelected;
  final FormFieldValidator<String>? fieldValidator;

  // @override
  @override
  Widget build(BuildContext context) {
    final contactsController = Get.put(CContactsController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final screenWidth = CHelperFunctions.screenWidth();

    return CRoundedContainer(
      bgColor: CColors.transparent,
      height: fieldHeight ?? 60.0,
      width: screenWidth,
      child: TypeAheadField<CContactsModel>(
        controller: typeAheadFieldController,
        builder: (context, controller, focusNode) {
          return TextFormField(
            autofocus: false,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: controller,
            decoration: InputDecoration(
              constraints: BoxConstraints(
                minHeight: minHeight ?? 70.0,
              ),
              filled: true,
              fillColor:
                  fillColor ??
                  (isDarkTheme ? CColors.transparent : CColors.lightGrey),
              focusColor: CColors.rBrown.withValues(alpha: 0.3),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(CSizes.cardRadiusXs),
                borderSide: BorderSide(color: CColors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CColors.rBrown.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(
                  CSizes.cardRadiusXs,
                ),
              ),
              labelStyle: Theme.of(
                context,
              ).textTheme.labelSmall,
              labelText: labelTxt,
              prefixIcon: includePrefixIcon
                  ? prefixIcon ??
                        Icon(
                          Iconsax.user_add,
                          color: CColors.darkGrey,
                          size: CSizes.iconXs,
                        )
                  : null,
            ),
            focusNode: focusNode,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
            validator: fieldValidator,
          );

          // TextFormField(
          //   autofocus: false,
          //   autovalidateMode: AutovalidateMode.onUserInteraction,
          //   controller: controller,
          //   decoration: InputDecoration(
          //     filled: true,
          //     fillColor: isDarkTheme ? CColors.transparent : CColors.lightGrey,
          //     labelText: labelTxt,
          //     prefixIcon:
          //         prefixIcon ??
          //         Icon(
          //           Iconsax.pen_add,
          //           color: CColors.darkGrey,
          //           size: CSizes.iconXs,
          //         ),
          //   ),
          //   focusNode: focusNode,
          //   //key: fieldKey,
          //   onChanged: (value) {
          //     controller.text = value;
          //   },
          //   style: TextStyle(
          //     color: isDarkTheme ? CColors.white : CColors.rBrown,
          //     fontSize: 13.0,
          //     fontStyle: FontStyle.normal,
          //     fontWeight: FontWeight.normal,
          //     //height: 1.1,
          //   ),
          //   textAlign: TextAlign.start,
          //   textAlignVertical: TextAlignVertical.center,
          //   onFieldSubmitted: (value) {},
          // );
        },
        constraints: BoxConstraints(
          maxWidth: screenWidth,
        ),
        hideOnEmpty: true,
        offset: Offset(
          0,
          5.0,
        ),

        suggestionsCallback: (pattern) {
          return contactsController.contactSuggestionsCallBackAction(pattern);
        },
        itemBuilder: (context, suggestion) {
          if (contactsController.foundMatches.isEmpty) {
            return SizedBox.shrink();
          } else {
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
              ),
              tileColor: CColors.white,

              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   suggestion.lastModified,
                  //   style: Theme.of(
                  //     context,
                  //   ).textTheme.labelSmall!.apply(color: CColors.darkGrey),
                  // ),
                  Text(
                    '${suggestion.contactName} ',
                    style: Theme.of(context).textTheme.labelMedium!.apply(
                      color: CColors.rBrown,
                      fontSizeFactor: 1.2,
                      fontWeightDelta: 2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    '#${suggestion.productId}; phone: ${suggestion.contactPhone}; email: (${suggestion.contactEmail})',
                    style:
                        Theme.of(
                          context,
                        ).textTheme.labelSmall!.apply(
                          color: CColors.rBrown,
                        ),
                  ),
                ],
              ),
            );
          }
        },
        onSelected: onItemSelected,
      ),
    );
  }
}
