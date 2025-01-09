import 'package:flutter/material.dart';
import 'package:itemeyes/src/components/linked_textfield.dart';
import 'package:itemeyes/src/data/receipt.dart';
import 'package:itemeyes/src/views/receipt_item_view.dart';

/// Displays detailed information about a SampleItem.
class ReceiptDetailsView extends StatelessWidget {
  static const String routeName = '/receipt';
  static const String dollarFilter = r'^\d+\.?\d{0,2}$';
  static const String percentFilter = r'^\d+\.?\d{0,4}$';
  static const String dollarPrefix = '\$';
  static const String percentSuffix = '%';

  const ReceiptDetailsView({ super.key });

  @override
  Widget build(BuildContext context) {
    final receipt = ModalRoute.of(context)!.settings.arguments as Receipt;

    TextEditingController taxDollarController = TextEditingController(text: receipt.tax.toStringAsFixed(2));
    TextEditingController taxPercentController = TextEditingController(text: receipt.calculateTaxPercentage().toStringAsFixed(3));

    TextEditingController tipDollarController = TextEditingController(text: receipt.tip.toStringAsFixed(2));
    TextEditingController tipPercentController = TextEditingController(text: receipt.calculateTipPercentage().toStringAsFixed(0));

    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt ${receipt.id} Details'),
      ),
      body: ListView.builder(
        itemCount: receipt.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ReceiptItemView(
            receiptItem: receipt.items[index],
            allPeople: receipt.people,
            onDelete: () => receipt.items.removeAt(index), // Will have to turn into a stateful widget to update the UI
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: \$${(receipt.getSubtotal() + receipt.tip + receipt.tax).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Row(
                  spacing: 8,
                  children: [
                    Text('Tax:'),
                    LinkedTextField(
                      textController: taxDollarController,
                      inputFilter: RegExp(dollarFilter),
                      prefixText: dollarPrefix,
                      submitFunction: (String value) {
                        receipt.tax = double.parse(value);
                        taxPercentController.text = receipt.calculateTaxPercentage().toStringAsFixed(3);
                      }
                    ),
                    LinkedTextField(
                      textController: taxPercentController,
                      inputFilter: RegExp(percentFilter),
                      suffixText: percentSuffix,
                      submitFunction: (String value) {
                        receipt.tax = receipt.calculateTax(double.parse(value));
                        taxDollarController.text = receipt.tax.toStringAsFixed(2);
                      }
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    Text('Tip:'),
                    LinkedTextField(
                      textController: tipDollarController,
                      inputFilter: RegExp(dollarFilter),
                      prefixText: dollarPrefix,
                      submitFunction: (String value) {
                        receipt.tip = double.parse(value);
                        tipPercentController.text = receipt.calculateTipPercentage().toStringAsFixed(0);
                      }
                    ),
                    LinkedTextField(
                      textController: tipPercentController,
                      inputFilter: RegExp(percentFilter),
                      suffixText: percentSuffix,
                      submitFunction: (String value) {
                        receipt.tip = receipt.calculateTip(double.parse(value));
                        tipDollarController.text = receipt.tip.toStringAsFixed(2);
                      }
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
