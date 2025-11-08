import 'package:flutter/material.dart';

class CSectionHeading extends StatelessWidget {
  const CSectionHeading({
    super.key,
    this.txtColor,
    required this.showActionBtn,
    required this.title,
    required this.btnTitle,
    this.onPressed,
    this.btnTxtColor,
    required this.editFontSize,
    this.fSize = 13.0,
  });

  final Color? txtColor, btnTxtColor;
  final bool showActionBtn, editFontSize;
  final String title, btnTitle;
  final double? fSize;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        editFontSize
            ? Text(
                title,
                style: TextStyle(
                  color: txtColor,
                  fontSize: fSize,
                  fontWeight: FontWeight.w100,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall!.apply(
                      color: txtColor,
                      fontSizeFactor: 0.75,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        if (showActionBtn)
          TextButton(
            onPressed: onPressed,
            child: Text(
              btnTitle,
              style: Theme.of(context).textTheme.labelMedium!.apply(
                    color: txtColor,
                    //fontSizeFactor: 0.75,
                  ),
            ),
          ),
      ],
    );
  }
}
