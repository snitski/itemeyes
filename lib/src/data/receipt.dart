import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:itemeyes/src/data/receipt_item.dart';

class Receipt {
  static final String taxItem = 'Tax';
  static final String tipItem = 'Tip';

  Receipt(this.id, this.image);

  final int id;
  final CroppedFile image;

  Set<String> people = <String>{
    'Alex',
    'Bob',
    'Charlie',
    'Arty',
  };

  List<ReceiptItem> items = <ReceiptItem>[];
  double tip = 0.00;
  double tax = 0.00;

  double getSubtotal() {
    double subtotal = 0;
    for (final ReceiptItem item in items) {
      subtotal += item.price;
    }
    return double.parse(subtotal.toStringAsFixed(2));
  }

  double calculateTax(double percentage) {
    tax = getSubtotal() * (percentage / 100);
    return tax;
  }

  double calculateTaxPercentage() {
    return tax / getSubtotal() * 100;
  }

  double calculateTip(double percentage) {
    tip = getSubtotal() * (percentage / 100);
    return tip;
  }

  double calculateTipPercentage() {
    return tip / getSubtotal() * 100;
  }

  Future<void> parseReceipt() async {
    final List<String> lines = await _getLinesFromImage();

    RegExp pricePattern = RegExp(r'^\$?\s*\d+\.\d{2}$');
    RegExp totalPattern = RegExp(r'^[Tt][Oo][Tt][Aa][Ll]$');
    RegExp subtotalPattern = RegExp(r'^[Ss][Uu][Bb][Tt][Oo][Tt][Aa][Ll]$');
    RegExp taxPattern = RegExp(r'[Tt][Aa][Xx]$');
    RegExp tipPattern = RegExp(r'^[Tt][Ii][Pp]$');

    List<String> itemList = <String>[];
    List<double> priceList = <double>[];
    List<int> topPrices = [-1, -1];
    bool foundTotal = false;
    bool foundSubtotal = false;

    for(String line in lines) {
      final String cleanedLine = line.trim().replaceAll(RegExp(r'\s+'), '');

      if (pricePattern.hasMatch(cleanedLine)) {
        final double price = double.parse(cleanedLine.replaceAll('\$', ''));
        priceList.add(price);

        for (int i = 0; i < topPrices.length; i++) {
          if (topPrices[i] == -1 || price > priceList[topPrices[i]]) {
            for (int j = topPrices.length - 1; j > i; j--) {
              topPrices[j] = topPrices[j - 1];
            }
            topPrices[i] = priceList.length - 1;
            break;
          }
        }
      } else if (totalPattern.hasMatch(cleanedLine)) {
        foundTotal = true;
      } else if (subtotalPattern.hasMatch(cleanedLine)){
        foundSubtotal = true;
      } else if (taxPattern.hasMatch(cleanedLine)) {
        itemList.add(Receipt.taxItem);
      } else if (tipPattern.hasMatch(cleanedLine)) {
        itemList.add(Receipt.tipItem);
      } else {
        itemList.add(line);
      }
    }

    if (foundTotal || foundSubtotal) {
      priceList.removeAt(topPrices[0]);
    }
    if (foundTotal && foundSubtotal) {
      if (topPrices[1] > topPrices[0]) {
        topPrices[1]--;
      }
      priceList.removeAt(topPrices[1]);
    }

    _buildItemList(itemList, priceList);
  }

  Future<List<String>> _getLinesFromImage() async {
    final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    return recognizedText.text.split('\n');
  }

  void _addItem(String item, double price) {
    if (item == Receipt.taxItem) {
      tax = price;
    } else if (item == Receipt.tipItem) {
      tip = price;
    } else {
      items.add(ReceiptItem(item, price));
    }
  }

  void _buildItemList(List<String> itemList, List<double> priceList) {
    int itemIndex = 0;
    int priceIndex = 0;

    int diff = itemList.length - priceList.length;
    while (diff > 0) {
      _addItem(itemList[itemIndex], 0.0);
      diff--;
      itemIndex++;
    }
    while (diff < 0) {
      _addItem('Unknown Item ${-1 * diff}', priceList[priceIndex]);
      diff++;
      priceIndex++;
    }
    while (itemIndex < itemList.length && priceIndex < priceList.length) {
      _addItem(itemList[itemIndex], priceList[priceIndex]);
      itemIndex++;
      priceIndex++;
    }
  }

  @override
  String toString() {
    String result = 'Receipt $id\n';
    double total = 0;
    for (final ReceiptItem item in items) {
      result += '$item\n';
      total += item.price;
    }
    result += 'Total: ${total.toStringAsFixed(2)}';
    return result;
  }
}
