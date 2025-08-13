import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CategoryGalleryScreen extends StatefulWidget {
  final String category;
  final List<File> images;
  final Function(List<File>) onImagesUpdated;

  const CategoryGalleryScreen({
    super.key,
    required this.category,
    required this.images,
    required this.onImagesUpdated,
  });

  @override
  State<CategoryGalleryScreen> createState() => _CategoryGalleryScreenState();
}

class _CategoryGalleryScreenState extends State<CategoryGalleryScreen> {
  late List<File> _images;

  @override
  void initState() {
    super.initState();
    _images = List<File>.from(widget.images);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
      widget.onImagesUpdated(_images);
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onImagesUpdated(_images);
  }

  void _viewImageFull(File image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.file(image),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.category} Photos"),
        actions: [
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
      body: _images.isEmpty
          ? const Center(child: Text("No photos taken yet."))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final image = _images[index];
          return Stack(
            children: [
              InkWell(
                onTap: () => _viewImageFull(image),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(image, fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _deleteImage(index),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
