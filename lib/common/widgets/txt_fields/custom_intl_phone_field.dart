import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class CCustomIntlPhoneField extends StatelessWidget {
  const CCustomIntlPhoneField({
    super.key,
    required this.intlPhoneFieldController,
    this.fieldHeight = 40.0,
    this.fieldWidth,
  });

  final TextEditingController intlPhoneFieldController;
  final double? fieldHeight, fieldWidth;

  @override
  Widget build(BuildContext context) {
    //final isDarkTheme = CHelperFunctions.isDarkMode(context);
    FocusNode focusNode = FocusNode();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IntlPhoneField(
              initialCountryCode: 'KE',
              initialValue: "0",
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'customer phone no.',
                border: OutlineInputBorder(borderSide: BorderSide()),
              ),
              languageCode: "en",
              onChanged: (phone) {
                if (kDebugMode) {
                  print(phone.completeNumber);
                }
              },
              onCountryChanged: (country) {
                if (kDebugMode) {
                  print('Country changed to: ${country.name}');
                }
              },
            ),
            const SizedBox(height: 3.0),
            Align(
              alignment: Alignment.bottomRight,
              child: MaterialButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: () {
                  formKey.currentState?.validate();
                },
                child: const Text('request payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
