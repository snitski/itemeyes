import 'package:flutter/material.dart';
import 'package:itemeyes/src/data/receipt.dart';

/// Displays detailed information about a SampleItem.
class ReceiptDetailsView extends StatelessWidget {
  static const String routeName = '/receipt';

  const ReceiptDetailsView({ super.key });

  @override
  Widget build(BuildContext context) {
    final receipt = ModalRoute.of(context)!.settings.arguments as Receipt;

    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt ${receipt.id} Details'),
      ),
      body: Center(
        child: Text(receipt.toString()),
      ),
    );
  }
}
