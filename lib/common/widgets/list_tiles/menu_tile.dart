import 'package:cri_v3/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class CMenuTile extends StatelessWidget {
  const CMenuTile({
    super.key,
    this.displayLeadingIcon = true,
    this.displaySubTitle = true,
    this.displayTrailingWidget = true,
    this.icon,
    required this.title,
    this.subTitle = '',
    this.trailing,
    this.onTap,
  });

  final bool displayLeadingIcon, displaySubTitle, displayTrailingWidget;
  final IconData? icon;
  final String title, subTitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: displayLeadingIcon
          ? Icon(icon, size: 28.0, color: CColors.primaryBrown)
          : SizedBox.shrink(),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: displaySubTitle
          ? Text(subTitle, style: Theme.of(context).textTheme.labelMedium)
          : SizedBox.shrink(),
      trailing: displayTrailingWidget ? trailing : SizedBox.shrink(),
      onTap: onTap,
    );
  }
}
