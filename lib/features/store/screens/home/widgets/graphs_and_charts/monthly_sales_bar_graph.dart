import 'package:cri_v3/common/widgets/buttons/custom_dropdown_btn.dart';
import 'package:cri_v3/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:cri_v3/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:cri_v3/features/personalization/controllers/user_controller.dart';
import 'package:cri_v3/features/store/controllers/dashboard_controller.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:cri_v3/utils/helpers/network_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CCustomMonthlySalesBarGraph extends StatelessWidget {
  const CCustomMonthlySalesBarGraph({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.put(CDashboardController());
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    final userController = Get.put(CUserController());
    final userCurrency = CHelperFunctions.formatCurrency(
      userController.user.value.currencyCode,
    );

    return Column(
      children: [
        Obx(
          () {
            return CRoundedContainer(
              bgColor: CColors.white,
              borderRadius: CSizes.cardRadiusSm,
              boxShadow: [
                BoxShadow(
                  blurRadius: 3.0,
                  color: CColors.grey.withValues(
                    alpha: .1,
                  ),
                  offset: const Offset(0.0, 3.0),
                  spreadRadius: 5.0,
                ),
              ],
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              width: CHelperFunctions.screenWidth(),
              child: Column(
                children: [],
              ),
            );
          },
        ),
      ],
    );
  }
}
