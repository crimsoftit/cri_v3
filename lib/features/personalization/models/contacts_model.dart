// ignore_for_file: unnecessary_getters_setters

class CContactsModel {
  int? _contactId;
  int? _productId;

  String _contactName = '';
  String _contactPhone = '';
  String _contactEmail = '';
  String _contactCategory = '';
  String _lastModified = '';

  CContactsModel(
    this._productId,
    this._contactName,
    this._contactPhone,
    this._contactEmail,
    this._contactCategory,
    this._lastModified,
  );

  CContactsModel.withId(
    this._productId,
    this._contactId,
    this._contactName,
    this._contactPhone,
    this._contactEmail,
    this._contactCategory,
    this._lastModified,
  );

  CContactsModel empty() {
    return CContactsModel.withId(0, 0, '', '', '', '', '');
  }

  int? get contactId => _contactId;
  int? get productId => _productId;
  String get contactName => _contactName;
  String get contactPhone => _contactPhone;
  String get contactEmail => _contactEmail;
  String get contactCategory => _contactCategory;
  String get lastModified => _lastModified;

  set contactId(int? newContactId) {
    _contactId = newContactId;
  }

  set productId(int? newProductId) {
    _contactId = newProductId;
  }

  set contactName(String newContactName) {
    _contactName = newContactName;
  }

  set contactPhone(String newContactPhone) {
    _contactPhone = newContactPhone;
  }

  set contactEmail(String newContactEmail) {
    _contactEmail = newContactEmail;
  }

  set contactCategory(String newContactCategory) {
    _contactCategory = newContactCategory;
  }

  set lastModified(String newLastModified) {
    _lastModified = newLastModified;
  }

  /// -- convert a Contact object into a Map object --
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'contactName': _contactName,
      'contactPhone': _contactPhone,
      'contactEmail': _contactEmail,
      'contactCategory': _contactCategory,
      'lastModified': _lastModified,
    };
    if (contactId != null) {
      map['contactId'] = _contactId;
    }
    if (productId != null) {
      map['productId'] = _productId;
    }
    return map;
  }

  /// -- extract a Contact object from a Map object --
  CContactsModel.fromMapObject(Map<String, dynamic> map) {
    _contactId = map['contactId'];
    _productId = map['productId'];
    _contactName = map['contactName'];
    _contactPhone = map['contactPhone'];
    _contactEmail = map['contactEmail'];
    _contactCategory = map['contactCategory'];
    _lastModified = map['lastModified'];
  }
}
