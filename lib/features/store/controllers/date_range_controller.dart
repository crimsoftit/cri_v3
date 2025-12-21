import 'package:cri_v3/features/store/controllers/txns_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CDateRangeController extends GetxController {
  // Initialize as null-friendly reactive variable
  final Rxn<DateTimeRange> selectedDateRange = Rxn<DateTimeRange>();

  // Optional: with default dates
  // final Rx<DateTimeRange> selectedDateRange = DateTimeRange(
  //   start: DateTime.now(),
  //   end: DateTime.now().add(const Duration(days: 7)),
  // ).obs;

  @override
  void onInit() {
    selectedDateRange.value = null;
    // TODO: implement onInit
    super.onInit();
  }

  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      cancelText: 'cancel',
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      saveText: "select",
    );

    if (result != null) {
      final txnsController = Get.put(CTxnsController());
      selectedDateRange.value = result; // Update reactive value

      final rawDateRange = selectedDateRange.value;

      final formattedDateRange =
          "${rawDateRange!.start.toLocal().toString().split(' ')[0]} to "
          "${rawDateRange.end.toLocal().toString().split(' ')[0]}";
      txnsController.dateRangeFieldController.text = formattedDateRange;

      txnsController.summarizeSalesData();
    }
  }
}
