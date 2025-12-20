import 'package:cri_v3/features/store/controllers/date_range_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateRangePicker extends StatelessWidget {
  DateRangePicker({super.key});
  final CDateRangeController controller = Get.put(CDateRangeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              final range = controller.selectedDateRange.value;
              if (range == null) {
                return Text("No date range selected");
              }
              return Text(
                "${range.start.toLocal().toString().split(' ')[0]} - "
                "${range.end.toLocal().toString().split(' ')[0]}",
              );
            }),
            ElevatedButton(
              onPressed: () => controller.pickDateRange(context),
              child: Text("Pick Date Range"),
            ),
          ],
        ),
      ),
    );
  }
}
