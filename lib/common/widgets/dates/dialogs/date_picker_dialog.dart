
import 'package:cri_v3/common/widgets/dates/date_picker_widget.dart';
import 'package:flutter/material.dart';

class CDatePickerDialog {
  Widget buildDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Date'),
      content: SizedBox(
        width: double.maxFinite,
        child: CDateRangePickerWidget(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}