import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itemeyes/src/data/receipt.dart';
import 'package:itemeyes/src/views/receipt_item_view.dart';

/// Displays detailed information about a SampleItem.
class ReceiptDetailsView extends StatelessWidget {
  static const String routeName = '/receipt';

  static Widget _createTextField(TextEditingController controller, bool isDollar, {void Function(String)? submitFunction}) {
    RegExp inputFilter = RegExp(isDollar ? r'^\d+\.?\d{0,2}$' : r'^\d+\.?\d{0,4}$');
    return Expanded(
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(inputFilter)],
        controller: controller,
        decoration: InputDecoration(
          prefixText: isDollar ? '\$' : '',
          suffixText: isDollar ? '' : '%',
          border: UnderlineInputBorder(),
          isCollapsed: true,
        ),
        onSubmitted: submitFunction,
      ),
    );
  }

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
          return ReceiptItemView(receiptItem: receipt.items[index]);
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
                    _createTextField(taxDollarController, true, submitFunction: (String value) {
                      receipt.tax = double.parse(value);
                      taxPercentController.text = receipt.calculateTaxPercentage().toStringAsFixed(3);
                    }),
                    _createTextField(taxPercentController, false, submitFunction: (String value) {
                      receipt.tax = receipt.calculateTax(double.parse(value));
                      taxDollarController.text = receipt.tax.toStringAsFixed(2);
                    }),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    Text('Tip:'),
                    _createTextField(tipDollarController, true, submitFunction: (String value) {
                      receipt.tip = double.parse(value);
                      tipPercentController.text = receipt.calculateTipPercentage().toStringAsFixed(0);
                    }),
                    _createTextField(tipPercentController, false, submitFunction: (String value) {
                      receipt.tip = receipt.calculateTip(double.parse(value));
                      tipDollarController.text = receipt.tip.toStringAsFixed(2);
                    }),
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
