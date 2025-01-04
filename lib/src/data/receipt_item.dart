import 'package:itemeyes/src/data/person.dart';

class ReceiptItem {
  ReceiptItem(this.name, this.price);
  final String name;
  final double price;

  Set<Person> people = <Person>{};

  @override
  String toString() {
    return '$name: \$${price.toStringAsFixed(2)}';
  }
}