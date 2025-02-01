import 'package:flutter/material.dart';

import 'package:itemeyes/src/data/receipt.dart';

class ReceiptSplitView extends StatelessWidget {
  static const String routeName = '/receipt/split';

  const ReceiptSplitView({ super.key });

  @override
  Widget build(BuildContext context) {
    final Receipt receipt = ModalRoute.of(context)!.settings.arguments as Receipt;
    final owedTotals = receipt.splitItems();

    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt Breakdown'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: receipt.people.length,
          itemBuilder: (BuildContext context, int index) {
            final String person = receipt.people.elementAt(index);
            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListTile(
                  title: Text(person, style: Theme.of(context).textTheme.headlineSmall),
                  subtitle: Text('\$${owedTotals[person]!.toStringAsFixed(2)}'),
                  onTap: () {
                    // Request Money?
                  }
                )
              ),
            );
          },
        )
      ),
    );
  }
}