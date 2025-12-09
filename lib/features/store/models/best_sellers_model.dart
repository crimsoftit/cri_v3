class CBestSellersModel {
  int _productId = 0;
  String _productName = "";

  int _totalSales = 0;

  CBestSellersModel(this._productId, this._productName, this._totalSales);

  //CBestSellersModel.withId(this._productName, this._quantity);

  static List<String> getHeaders() {
    return ['productId',  'productName', 'totalSales'];
  }

  int get productId => _productId;
  String get productName => _productName;
  int get totalSales => _totalSales;

  set productId(int newPid) {
    _productId = newPid;
  }

  set productName(String newPname) {
    _productName = newPname;
  }

  set totalSales(int newTotalSales) {
    if (newTotalSales >= 0) {
      _totalSales = newTotalSales;
    }
  }

  // convert a SoldItemsModel Object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['productId'] = _productId;
    map['productName'] = _productName;
    map['totalSales'] = _totalSales;

    return map;
  }

  // extract a SoldItemsModel object from a Map object
  CBestSellersModel.fromMapObject(Map<String, dynamic> map) {
    _productId = map['productId'];
    _productName = map['productName'];
    _totalSales = map['totalSales'];
  }
}
