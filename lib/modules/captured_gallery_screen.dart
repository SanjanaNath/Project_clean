import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Future<void> _pickImage() async {
  //   int maxImages = (widget.category == 'Entrance' || widget.category == 'Kitchen') ? 3 : 10;
  //
  //   if (_images.length >= maxImages) {
  //     Fluttertoast.showToast(
  //       msg: "You can only add up to $maxImages photos for ${widget.category}.",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: Colors.black54,
  //       textColor: Colors.white,
  //     );
  //     return;
  //   }
  //
  //   // Request camera permission
  //   var status = await Permission.camera.request();
  //
  //   // Check the status
  //   if (status.isDenied) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Camera permission is required to take photos."),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     // if (mounted) { // Check if the widget is still in the tree
  //     //   ScaffoldMessenger.of(context).showSnackBar(
  //     //     const SnackBar(
  //     //       content: Text("Camera permission is required to take photos."),
  //     //       backgroundColor: Colors.red,
  //     //     ),
  //     //   );
  //     // }
  //     return;
  //   }
  //
  //   if (status.isPermanentlyDenied) {
  //     // User has denied permission forever, guide them to app settings
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text("Camera permission is permanently denied. Please enable it from app settings."),
  //           backgroundColor: Colors.red,
  //           action: SnackBarAction(
  //             label: 'Settings',
  //             onPressed: () => openAppSettings(), // Opens the app settings page
  //           ),
  //         ),
  //       );
  //     }
  //     return;
  //   }
  //
  //
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(
  //     source: ImageSource.camera,
  //     imageQuality: 50,
  //   );
  //
  //   if (pickedFile != null) {
  //     setState(() {
  //       _images.add(File(pickedFile.path));
  //     });
  //     widget.onImagesUpdated(_images);
  //   }
  // }

  Future<void> _pickImage() async {
    try {
      int maxImages = (widget.category == 'Entrance' || widget.category == 'Kitchen') ? 3 : 10;

      if (_images.length >= maxImages) {
        Fluttertoast.showToast(
          msg: "You can only add up to $maxImages photos for ${widget.category}.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        return;
      }
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
        widget.onImagesUpdated(_images);
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Camera permission is required to take a photo."),
          backgroundColor: Colors.red,
        ),
      );
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
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(image, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text("${widget.category} Photos", style:  GoogleFonts.lato(fontWeight: FontWeight.bold, )),
        centerTitle: true,
      ),
      body: _images.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_camera_back, size: 80, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              "No photos taken yet.\nTap the camera button below to add.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      )
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
          return GestureDetector(
            onTap: () => _viewImageFull(image),
            child: Stack(
              children: [
                Hero(
                  tag: image.path,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(image, fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _deleteImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.camera_alt, size: 28, color: Colors.white,),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(height: 50),
      ),
    );
  }
}


class RemarksDialog extends StatefulWidget {
  final String initialRemarks;
  const RemarksDialog({super.key, required this.initialRemarks});

  @override
  State<RemarksDialog> createState() => _RemarksDialogState();
}

class _RemarksDialogState extends State<RemarksDialog> {
  late TextEditingController _remarkController;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.initialRemarks);
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Add Remarks",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
      content: SingleChildScrollView(
        child: TextFormField(
          controller: _remarkController,
          decoration: const InputDecoration(
            hintText: "Enter any observations...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.teal),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
          ),
          maxLines: 5,
          keyboardType: TextInputType.multiline,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Cancel and close the dialog without saving
            Navigator.of(context).pop(null);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            // Save the remarks and close the dialog
            Navigator.of(context).pop(_remarkController.text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
