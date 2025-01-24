import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:itemeyes/src/data/receipt_item.dart';

enum ReceiptItemViewAction { delete, save, cancel }

class ReceiptItemView extends StatefulWidget {
  const ReceiptItemView({ super.key, required this.receiptItem, required this.allPeople, required this.onDelete });

  final ReceiptItem receiptItem;
  final Set<String> allPeople;
  final Function onDelete;

  @override
  State<ReceiptItemView> createState() => _ReceiptItemViewState();
}

class _ReceiptItemViewState extends State<ReceiptItemView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.receiptItem.name),
      trailing: Text('\$${widget.receiptItem.price.toStringAsFixed(2)}'),
      subtitle: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.allPeople.length,
          itemBuilder: (BuildContext context, int index) {
            final String name = widget.allPeople.elementAt(index);
            final String initials = name.split(' ').map((String word) => word[0]).join();

            if (widget.receiptItem.people.contains(name)) {
              return IconButton.filled(
                icon: Text(initials, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                onPressed: () => setState(() => widget.receiptItem.people.remove(name))
              );
            } else {
              return IconButton.outlined(
                icon: Text(initials),
                onPressed: () => setState(() => widget.receiptItem.people.add(name))
              );
            }
          },
        ),
      ),
      onLongPress: () async {
        final result = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            nameController.text = widget.receiptItem.name;
            priceController.text = widget.receiptItem.price.toStringAsFixed(2);

            return PopScope(
              canPop: false,
              child: AlertDialog(
                title: const Text('Edit Item'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                    TextField(
                      controller: priceController,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))],
                      decoration: const InputDecoration(
                        prefix: Text('\$'),
                        labelText: 'Price'
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, ReceiptItemViewAction.delete),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Delete'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, ReceiptItemViewAction.cancel),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, ReceiptItemViewAction.save),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          }
        );

        if (result == ReceiptItemViewAction.delete) {
          widget.onDelete();
        } else if (result == ReceiptItemViewAction.save) {
          setState(() => widget.receiptItem.name = nameController.text);
          setState(() => widget.receiptItem.price = double.parse(priceController.text));
        }
      },
    );
  }
}