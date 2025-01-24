import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReceiptItemDialogFields extends StatelessWidget {
  const ReceiptItemDialogFields({ super.key, required this.nameController, required this.priceController});

  final TextEditingController nameController;
  final TextEditingController priceController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        TextField(
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        TextField(
          controller: priceController,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))],
          decoration: const InputDecoration(
            prefix: Text('\$'),
            labelText: 'Price',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
        ),
      ]
    );
  }

}