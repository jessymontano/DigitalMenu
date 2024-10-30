import 'dart:typed_data';
import 'package:digital_menu/src/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ImageUploader extends StatefulWidget {
  final Function(String?) onImageUploaded;

  const ImageUploader({super.key, required this.onImageUploaded});
  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final SupabaseClient supabase = Supabase.instance.client;
  Uint8List? _image;
  String? _fileName;

  Future<void> _pickImage(BuildContext context) async {
    FilePickerResult? pickedFile = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile.files.single.bytes!;
        _fileName = pickedFile.files.single.name;
      });
    }
    _uploadImage(context);
  }

  Future<void> _uploadImage(BuildContext context) async {
    if (_image == null) return;

    final filePath = 'images/$_fileName';
    widget.onImageUploaded(_fileName);
    try {
      await supabase.storage.from('img').uploadBinary(filePath, _image!);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Imagen subida correctamente")));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ocurrio un error al subir imagen: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Button(
        size: const Size(200, 100),
        text: "Subir imagen",
        onPressed: () => _pickImage(context));
  }
}
