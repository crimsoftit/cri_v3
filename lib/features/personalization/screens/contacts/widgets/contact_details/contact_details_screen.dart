import 'package:cri_v3/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class CContactDetailsScreen extends StatelessWidget {
  const CContactDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CColors.rBrown.withValues(
        alpha: 0.2,
      ),
    );
  }
}
