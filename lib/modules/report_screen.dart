import 'dart:io';
import 'dart:typed_data'; // Add this import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:project_clean/controllers/screens_controller.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // String? loginType = LocalDatabase().loginType;
  // Future fetchBookingHistory() async {
  //   // Access the userId from LocalDatabase
  //   String? userId = LocalDatabase().userId;
  //
  //   print('userId======>$userId');
  //   if (userId != null && userId.isNotEmpty) {
  //     return await context.read<NyotaBhojController>().NyotaBookingHistory(
  //         context: context, userId: userId, loginType: loginType ?? '');
  //   } else {
  //     print("Error: User ID is null or empty");
  //   }
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // fetchBookingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text('Survey History',style: TextStyle(color: Colors.white),),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.teal.shade800,
              // Colors.teal.shade800,
              // Colors.blue.shade400,
              Colors.teal.shade200
            ]),
          ),
        ),
      ),
      body: Consumer<ScreenController>(
        builder: (context, controller, child) {
          // List<Data>? nyotaBookingHistoryData =
          //     controller.nyotaBookingHistoryModel?.data;

          // DateTime parsedDate = DateTime.parse(controller.nyotaBookingHistoryModel?.data?.first.date);
          // String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);

          return ModalProgressHUD(
              inAsyncCall: controller.isLoading ?? false,
              child:
              // true
              //     ?
              SingleChildScrollView(
                child: ListView.builder(
                  itemCount: 3,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(bottom: size.height * 0.12),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Handle tap on the card
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.shade100,
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Date Section
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.teal.shade700,
                                        spreadRadius: 1,
                                        blurRadius: 2)
                                  ]
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Survey Date",
                                    style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "13/08/2025", // Use your dynamic date variable here
                                    style: const TextStyle(
                                        color: Colors.teal,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),

                            // Hostel Details Section
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hostel Name',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Boys Hostel', // Use your dynamic hostel name variable here
                                    style: TextStyle(
                                      color: Colors.teal.shade800,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action Button Section
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {

                                    // Replace with your actual dynamic data for the report
                                    generateReport(
                                      hostelId: 'BK12345678', // Replace with your booking ID
                                      hostelName: 'PRE-MATRIC SC BOYS HOSTEL SHIVANI ABHANPUR', // Replace with your hostel name
                                      date: '8/13/2025', // Replace with your formatted date
                                      entranceImagePaths: ['assets/images/entranceImage1.jpg' ,'assets/images/entranceImage2.jpg' ], // Replace with actual paths
                                      kitchenImagePaths: ['assets/images/kitchen1.jpeg', 'assets/images/kitchen2.jpeg'],
                                      roomImagePaths: ['assets/images/room1.jpeg','assets/images/room2.jpeg','assets/images/room3.jpeg','assets/images/room4.jpeg','assets/images/room5.jpeg' ],
                                      toiletImagePaths: ['assets/images/toilet.jpeg'],
                                      remarks: 'All facilities were found to be in excellent condition during the inspection.', // Replace with your remarks
                                    );

                                },
                                child: const Text(
                                  'Generate Report',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
              //     : NoDataFound(
              //   heightFactor: 0.35,
              //   color: Colors.teal,
              //   message: 'No Booking History',
              //   buildContext: context,
              // )
          );
        },
      ),
    );
  }

  Future<void> generateReport({
    required String hostelId,
    required String hostelName,
    required String date,
    required List<String> entranceImagePaths,
    required List<String> kitchenImagePaths,
    required List<String> toiletImagePaths,
    required List<String> roomImagePaths,
    required String remarks,
  }) async {
    final pdf = pw.Document();

    // Correctly load images from assets
    Future<List<pw.Image>> _getImagesFromAssets(List<String> paths) async {
      final List<pw.Image> images = [];
      for (var path in paths) {
        if (path.isNotEmpty) {
          try {
            final ByteData assetData = await rootBundle.load(path);
            final Uint8List imageBytes = assetData.buffer.asUint8List();
            images.add(pw.Image(pw.MemoryImage(imageBytes)));
          } catch (e) {
            print('Error loading image from asset: $path, Error: $e');
          }
        }
      }
      return images;
    }

    // Fetch images from asset paths
    final entranceImages = await _getImagesFromAssets(entranceImagePaths.take(4).toList());
    final kitchenImages = await _getImagesFromAssets(kitchenImagePaths.take(4).toList());
    final toiletImages = await _getImagesFromAssets(toiletImagePaths.take(4).toList());
    final roomImages = await _getImagesFromAssets(roomImagePaths.take(4).toList());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Main Report Title
                pw.Center(
                  child: pw.Text(
                    'Hostel Report',
                    style: pw.TextStyle(
                      fontSize: 30,
                      fontWeight: pw.FontWeight.bold,

                      color: PdfColors.teal,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                // A divider to separate the title from the details
                pw.SizedBox(height: 10),

                // Hostel Name section with a distinct style
                pw.Center(
                  child: pw.Text(
                    '$hostelName',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal,
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                // Details section with a more professional layout
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                        children: [
                          pw.TextSpan(text: 'Survey Date: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.TextSpan(text: date),
                        ],
                      ),
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                        children: [
                          pw.TextSpan(text: 'Hostel ID: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.TextSpan(text: hostelId),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Divider(color: PdfColors.teal),
              ],
            ),
            // Images Sections
            _buildImageSection('Entrance Images', entranceImages),
            _buildImageSection('Kitchen Images', kitchenImages),
            _buildImageSection('Toilet Images', toiletImages),
            _buildImageSection('Room Images', roomImages),
            pw.SizedBox(height: 20),
            // Remarks Section
            pw.Text(
              'Remarks:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal),
            ),
            pw.SizedBox(height: 5),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.teal, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(remarks, style: const pw.TextStyle(fontSize: 12)),
            ),
          ];
        },
      ),
    );

    // Get the application documents directory
    final String dirPath = (await getApplicationDocumentsDirectory()).path;
    // Create the subdirectory for the hostel name
    final Directory hostelDir = Directory('$dirPath/$hostelName');

    // Check if the directory exists, and create it if it doesn't
    if (!await hostelDir.exists()) {
      await hostelDir.create(recursive: true);
    }
    final String filePath = '${hostelDir.path}/$hostelId.pdf';
    final File file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file
    OpenFilex.open(filePath);
  }

// Helper function to create image sections
  pw.Widget _buildImageSection(String title, List<pw.Image> images) {
    if (images.isEmpty) return pw.SizedBox.shrink();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal),
        ),
        pw.SizedBox(height: 5),
        pw.GridView(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: images,
        ),
      ],
    );
  }
}
