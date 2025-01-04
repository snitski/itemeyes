import 'package:flutter/material.dart';
import 'package:itemeyes/src/data/receipt_item.dart';

class ReceiptItemView extends StatelessWidget {

  const ReceiptItemView({ super.key, required this.receiptItem });

  final ReceiptItem receiptItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(receiptItem.name),
      trailing: Text('\$${receiptItem.price.toStringAsFixed(2)}'),
    );
  }
}