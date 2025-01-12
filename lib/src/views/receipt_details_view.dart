import 'package:flutter/material.dart';
import 'package:itemeyes/src/components/linked_textfield.dart';
import 'package:itemeyes/src/data/receipt.dart';
import 'package:itemeyes/src/views/receipt_item_view.dart';

/// Displays detailed information about a SampleItem.
class ReceiptDetailsView extends StatefulWidget {
  static const String routeName = '/receipt';
  static const String dollarFilter = r'^\d+\.?\d{0,2}$';
  static const String percentFilter = r'^\d+\.?\d{0,4}$';
  static const String dollarPrefix = '\$';
  static const String percentSuffix = '%';

  const ReceiptDetailsView({ super.key });

  @override
  State<ReceiptDetailsView> createState() => _ReceiptDetailsViewState();
}

class _ReceiptDetailsViewState extends State<ReceiptDetailsView> {
  late Receipt receipt;

  TextEditingController taxDollarController = TextEditingController();
  TextEditingController taxPercentController = TextEditingController();

  TextEditingController tipDollarController = TextEditingController();
  TextEditingController tipPercentController = TextEditingController();

  @override
  void dispose() {
    taxDollarController.dispose();
    taxPercentController.dispose();
    tipDollarController.dispose();
    tipPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    receipt = ModalRoute.of(context)!.settings.arguments as Receipt;

    taxDollarController.text = receipt.tax.toStringAsFixed(2);
    taxPercentController.text = receipt.calculateTaxPercentage().toStringAsFixed(3);

    tipDollarController.text = receipt.tip.toStringAsFixed(2);
    tipPercentController.text = receipt.calculateTipPercentage().toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('Add Person'),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: TextField(
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (String value) {
                            Navigator.pop(context, value);
                          },
                        ),
                      )
                    ],
                  );
                }
              );

              if (result is String && result.isNotEmpty) {
                setState(() {
                  receipt.people.add(result);
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
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
                        inputFilter: RegExp(ReceiptDetailsView.dollarFilter),
                        prefixText: ReceiptDetailsView.dollarPrefix,
                        submitFunction: (String value) {
                          receipt.tax = double.parse(value);
                          taxPercentController.text = receipt.calculateTaxPercentage().toStringAsFixed(3);
                        }
                      ),
                      LinkedTextField(
                        textController: taxPercentController,
                        inputFilter: RegExp(ReceiptDetailsView.percentFilter),
                        suffixText: ReceiptDetailsView.percentSuffix,
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
                        inputFilter: RegExp(ReceiptDetailsView.dollarFilter),
                        prefixText: ReceiptDetailsView.dollarPrefix,
                        submitFunction: (String value) {
                          receipt.tip = double.parse(value);
                          tipPercentController.text = receipt.calculateTipPercentage().toStringAsFixed(0);
                        }
                      ),
                      LinkedTextField(
                        textController: tipPercentController,
                        inputFilter: RegExp(ReceiptDetailsView.percentFilter),
                        suffixText: ReceiptDetailsView.percentSuffix,
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
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: receipt.items.length,
              itemBuilder: (BuildContext context, int index) {
                return ReceiptItemView(
                  receiptItem: receipt.items[index],
                  allPeople: receipt.people,
                  onDelete: () => receipt.items.removeAt(index), // Will have to turn into a stateful widget to update the UI
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
