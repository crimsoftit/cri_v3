class CPaymentMethodModel {
  CPaymentMethodModel({
    required this.platformLogo,
    required this.platformName,
  });

  String platformLogo, platformName;

  static CPaymentMethodModel empty() {
    return CPaymentMethodModel(
      platformLogo: '',
      platformName: '',
    );
  }
}
