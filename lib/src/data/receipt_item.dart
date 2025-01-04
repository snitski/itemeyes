import 'package:itemeyes/src/data/person.dart';

class ReceiptItem {
  ReceiptItem(this.name, this.price);
  final String name;
  final double price;

  Set<String> people = <String>{
    'Alex',
    'Arty',
  };

  @override
  String toString() {
    return '$name: \$${price.toStringAsFixed(2)}';
  }
}