import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class Receipt {
  static final String total = 'Total';
  static final String subtotal = 'Subtotal';
  static final String tax = 'Tax';
  static final String tip = 'Tip';

  Receipt(this.id, this.image);

  final int id;
  final CroppedFile image;

  Map<String, double> items = <String, double>{};

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
        itemList.add(Receipt.tax);
      } else if (tipPattern.hasMatch(cleanedLine)) {
        itemList.add(Receipt.tip);
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

    _generateItemMap(itemList, priceList);
  }

  Future<List<String>> _getLinesFromImage() async {
    final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    return recognizedText.text.split('\n');
  }

  void _generateItemMap(List<String> itemList, List<double> priceList) {
    int itemIndex = 0;
    int priceIndex = 0;

    int diff = itemList.length - priceList.length;
    while (diff > 0) {
      items[itemList[itemIndex]] = 0.0;
      diff--;
      itemIndex++;
    }
    while (diff < 0) {
      items['Unknown Item ${-1 * diff}'] = priceList[priceIndex];
      diff++;
      priceIndex++;
    }
    while (itemIndex < itemList.length && priceIndex < priceList.length) {
      items[itemList[itemIndex]] = priceList[priceIndex];
      itemIndex++;
      priceIndex++;
    }
  }

  @override
  String toString() {
    String result = 'Receipt $id\n';
    double total = 0;
    for (String item in items.keys) {
      result += '$item: ${items[item]}\n';
      total += items[item]!;
    }
    result += 'Total: $total';
    return result;
  }
}
