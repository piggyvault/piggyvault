class Currency {
  final String? name, symbol, symbolNative, code;
  final int? id;

  Currency(this.name, this.id, this.symbol, this.symbolNative, this.code);

  Currency.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        code = json['code'],
        symbol = json['symbol'],
        symbolNative = json['symbolNative'];
}
