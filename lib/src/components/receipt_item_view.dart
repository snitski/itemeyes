import 'package:flutter/material.dart';

import 'package:itemeyes/src/data/receipt_item.dart';

class ReceiptItemView extends StatefulWidget {
  const ReceiptItemView({ super.key, required this.receiptItem, required this.allPeople, required this.onDelete });

  final ReceiptItem receiptItem;
  final Set<String> allPeople;
  final Function onDelete;

  @override
  State<ReceiptItemView> createState() => _ReceiptItemViewState();
}

class _ReceiptItemViewState extends State<ReceiptItemView> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.receiptItem.name),
      trailing: Column(
        children: [
          Text('\$${widget.receiptItem.price.toStringAsFixed(2)}'),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          )
        ],
      ),
      subtitle:
        SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.allPeople.length,
          itemBuilder: (BuildContext context, int index) {
            final String name = widget.allPeople.elementAt(index);
            final String initials = name.split(' ').map((String word) => word[0]).join();

            if (widget.receiptItem.people.contains(name)) {
              return IconButton.filledTonal(
                icon: Text(initials),
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
    );
  }
}