class CryptoModel {
  String name;
  String symbol;
  double price;
  String icon;
  bool isUp;

  CryptoModel({
    required this.name,
    required this.symbol,
    required this.price,
    required this.icon,
    this.isUp = true,
  });
}
