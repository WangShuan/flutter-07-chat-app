import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/snackbar_utils.dart';

class AuthImagePicker extends StatefulWidget {
  const AuthImagePicker(this.selectedImg, {super.key});

  final void Function(File img) selectedImg;

  @override
  State<AuthImagePicker> createState() => _AuthImagePickerState();
}

class _AuthImagePickerState extends State<AuthImagePicker> {
  File? _previewImage;

  Future<void> _pickImage(void Function(String) showErrorSnackbar) async {
    try {
      final img = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 200, maxHeight: 200);
      if (img == null) return;

      setState(() {
        _previewImage = File(img.path);
      });
      widget.selectedImg(_previewImage!);
    } catch (e) {
      showErrorSnackbar("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _pickImage((errorMsg) => showSnackbar(context, errorMsg)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.onBackground,
        ),
        clipBehavior: Clip.hardEdge,
        width: 100,
        height: 100,
        child: AspectRatio(
          aspectRatio: 1,
          child: _previewImage != null
              ? Image.file(_previewImage!, fit: BoxFit.cover)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, color: colorScheme.onPrimary, size: 18),
                    const SizedBox(width: 4),
                    Text('選擇頭像', style: TextStyle(color: colorScheme.onPrimary)),
                  ],
                ),
        ),
      ),
    );
  }
}
