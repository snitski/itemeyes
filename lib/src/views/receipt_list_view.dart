import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../settings/settings_view.dart';
import '../data/receipt.dart';
import 'receipt_details_view.dart';

/// Displays a list of SampleItems.
class ReceiptListView extends StatefulWidget {
  const ReceiptListView({ super.key });

  static const routeName = '/';

  @override
  State<ReceiptListView> createState() => _ReceiptListViewState();
}

class _ReceiptListViewState extends State<ReceiptListView> {
  List<Receipt> receipts = <Receipt>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Receipts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'receiptListView',
        itemCount: receipts.length,
        itemBuilder: (BuildContext context, int index) {
          final receipt = receipts[index];

          return ListTile(
            title: Text('Receipt ${receipt.id}'),
            leading: const CircleAvatar(
              // Display the Flutter Logo image asset.
              foregroundImage: AssetImage('assets/images/flutter_logo.png'),
            ),
            onTap: () {
              // Navigate to the details page. If the user leaves and returns to
              // the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.pushNamed(
                context,
                ReceiptDetailsView.routeName,
                arguments: receipt,
              );
            }
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          ImageSource? imageSource = await showDialog(context: context,
            builder: (BuildContext context) => SimpleDialog(
              title: const Text('Scan receipt'),
              children: [
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  child: const Text('Camera'),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  child: const Text('Gallery'),
                ),
              ],
            )
          );
          if (imageSource == null) return;

          final image = await ImagePicker().pickImage(source: imageSource);
          if (image == null) return;

          if(!context.mounted) return;
          final croppedImage = await ImageCropper().cropImage(
            sourcePath: image.path,
            uiSettings: [AndroidUiSettings(hideBottomControls: true,
                                           lockAspectRatio: false,
            )]);

          if (croppedImage == null) return;

          final receipt = Receipt(receipts.length + 1, croppedImage);
          await receipt.parseReceipt();
          setState(() => receipts.insert(0, receipt));
        },
        label: const Text('Scan receipt'),
        icon: const Icon(Icons.camera_alt_outlined),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
