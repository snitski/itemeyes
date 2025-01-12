import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:itemeyes/src/settings/settings_view.dart';
import 'package:itemeyes/src/data/receipt.dart';
import 'package:itemeyes/src/views/receipt_details_view.dart';

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
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      body: ListView.builder(
        restorationId: 'receiptListView',
        itemCount: receipts.length,
        itemBuilder: (BuildContext context, int index) {
          final receipt = receipts[index];

          return ListTile(
            title: Text('Receipt'),
            leading: const CircleAvatar(
              foregroundImage: AssetImage('assets/images/flutter_logo.png'),
            ),
            onTap: () {
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
            uiSettings: [
              AndroidUiSettings(
                hideBottomControls: true,
                lockAspectRatio: false,
              ),
            ],
          );

          if (croppedImage == null) return;

          final receipt = Receipt();
          await receipt.parseImage(croppedImage);
          setState(() => receipts.insert(0, receipt));
        },
        label: const Text('Scan receipt'),
        icon: const Icon(Icons.camera_alt_outlined),
      ),
    );
  }
}
