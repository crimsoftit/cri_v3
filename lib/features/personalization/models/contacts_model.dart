class CContactsModel {
  int? _contactId;

  String _contactName = '';
  String _contactPhone = '';
  String _contactEmail = '';
  String _contactCategory = '';

  CContactsModel(
    this._contactName,
    this._contactPhone,
    this._contactEmail,
    this._contactCategory,
  );

  CContactsModel.withId(
    this._contactId,
    this._contactName,
    this._contactPhone,
    this._contactEmail,
    this._contactCategory,
  );

  CContactsModel empty() {
    return CContactsModel.withId(
      0,
      '',
      '',
      '',
      '',
    );
  }
}
