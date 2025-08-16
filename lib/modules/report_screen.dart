import 'dart:io';
import 'dart:typed_data'; // Add this import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:project_clean/controllers/screens_controller.dart';
import 'package:project_clean/core/api_config.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import '../utils/color_constants.dart';
import '../widgets/no_data_found.dart';


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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Call the API to fetch survey history data
      Provider.of<ScreenController>(context, listen: false).surveyHistory(context: context);
    });
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        // iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text('Survey History',style: GoogleFonts.lato(),),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<ScreenController>(
        builder: (context, controller, child) {

          if (controller.surveyHistoryList.isEmpty && !controller.isLoading) {
            return NoDataFound(
              heightFactor: 0.35,
              color: Colors.teal,
              message: 'No Survey History',
              buildContext: context,
            );
          }
          return ModalProgressHUD(
              inAsyncCall: controller.isLoading ,
              progressIndicator: CircularProgressIndicator(
                color: ColorConstants().teal,
              ),
              blur: 2,
              child:
              SingleChildScrollView(
                child: ListView.builder(
                  itemCount: controller.surveyHistoryList.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(bottom: size.height * 0.12),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final survey = controller.surveyHistoryList[index];
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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
                                   Text(
                                    "Survey Date",
                                    style: GoogleFonts.lato(
                                        color: Colors.teal,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(DateTime.parse(survey.attendanceDate)),
                                    style: GoogleFonts.lato(
                                        color: Colors.teal,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),

                            // Hostel Details Section
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                    'Hostel Name',
                                    style: GoogleFonts.lato(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    survey.hostelName, // Use your dynamic hostel name variable here
                                    style: GoogleFonts.lato(
                                      color: Colors.teal.shade800,
                                      fontSize: 16,
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

                                // onPressed: () async {
                                //   final response = await controller.reportGenerate(
                                //     context: context,
                                //     attendanceID: survey.attendanceID,
                                //   );
                                //
                                //   if (response != null && response['success'] == true) {
                                //     final attendanceData = response['attendance'];
                                //     final imagesData = response['images'] as List<dynamic>;
                                //
                                //     // Group images by type
                                //     Map<String, List<String>> groupedImages = {};
                                //     for (var image in imagesData) {
                                //       final imageType = image['image_type'];
                                //       final imageUrl = image['image_url'];
                                //       if (imageUrl != null) {
                                //         // You might need to prepend the base URL for the images
                                //         final fullUrl = '${ApiConfig.baseUrl1}$imageUrl';
                                //         if (!groupedImages.containsKey(imageType)) {
                                //           groupedImages[imageType] = [];
                                //         }
                                //         groupedImages[imageType]?.add(fullUrl);
                                //       }
                                //     }
                                //     final remarks = (imagesData.isNotEmpty && imagesData.first['remarks'] != null)
                                //         ? imagesData.first['remarks']
                                //         : '';
                                //
                                //     generateReport(
                                //       context: context,
                                //       hostelName: attendanceData['hostel_name'] ?? '',
                                //       hostelId: attendanceData['hostel_id'] ?? '',
                                //       date: DateFormat('dd/MM/yyyy').format(DateTime.parse(attendanceData['attendance_date'])),
                                //       entranceUrls: groupedImages['Entrance'] ?? [],
                                //       kitchenUrls: groupedImages['Kitchen'] ?? [],
                                //       toiletUrls: groupedImages['Bathroom & Toilet'] ?? [],
                                //       roomUrls: groupedImages['Room'] ?? [],
                                //       remarks: remarks,
                                //         controller: controller
                                //     ).whenComplete(() {
                                //       controller.isLoading =false;
                                //
                                //     },);
                                //   }
                                // },
                                onPressed: controller.isGeneratingReport
                                    ? null // Disable the button while the report is generating
                                    : () async {
                                  // 1. Show the loader.
                                  controller.setGeneratingReport(true);

                                  try {
                                    final response = await controller.reportGenerate(
                                      context: context,
                                      attendanceID: survey.attendanceID,
                                    );

                                    if (response != null && response['success'] == true) {
                                      final attendanceData = response['attendance'];
                                      final imagesData = response['images'] as List<dynamic>;

                                      Map<String, List<String>> groupedImages = {};
                                      for (var image in imagesData) {
                                        final imageType = image['image_type'];
                                        final imageUrl = image['image_url'];
                                        if (imageUrl != null) {
                                          final fullUrl = '${ApiConfig.baseUrl1}$imageUrl';
                                          if (!groupedImages.containsKey(imageType)) {
                                            groupedImages[imageType] = [];
                                          }
                                          groupedImages[imageType]?.add(fullUrl);
                                        }
                                      }
                                      final remarks = (imagesData.isNotEmpty && imagesData.first['remarks'] != null)
                                          ? imagesData.first['remarks']
                                          : '';

                                      // 2. The loader will remain visible during this entire function call.
                                      await generateReport(
                                        context: context,
                                        hostelName: attendanceData['hostel_name'] ?? '',
                                        hostelId: attendanceData['hostel_id'] ?? '',
                                        date: DateFormat('dd/MM/yyyy').format(DateTime.parse(attendanceData['attendance_date'])),
                                        entranceUrls: groupedImages['Entrance'] ?? [],
                                        kitchenUrls: groupedImages['Kitchen'] ?? [],
                                        toiletUrls: groupedImages['Bathroom & Toilet'] ?? [],
                                        roomUrls: groupedImages['Room'] ?? [],
                                        remarks: remarks,
                                        controller: controller
                                      );
                                    }
                                  } finally {
                                    // 3. Hide the loader after everything is done, or an error occurred.
                                    controller.setGeneratingReport(false);
                                  }
                                },
                                child:  Text(
                                  'Generate Report',
                                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
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
          );
        },
      ),
    );
  }

  Future<void> generateReport({
    required BuildContext context,
    required String hostelName,
    required String hostelId,
    required String date,
    required List<String> entranceUrls,
    required List<String> kitchenUrls,
    required List<String> toiletUrls,
    required List<String> roomUrls,
    required String remarks,
    required ScreenController controller,
  })
  async {
    final pdf = pw.Document();
    controller.isLoading = true;

    Future<List<pw.Image>> _getImagesFromUrls(List<String> urls) async {
      List<pw.Image> images = [];
      for (var url in urls) {
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            images.add(pw.Image(pw.MemoryImage(response.bodyBytes)));
          }
        } catch (e) {
          print("Error loading image from $url: $e");
        }
      }
      return images;
    }
    final logoImage = await _loadLogoImage();
    // Fetch images
    final entranceImages = await _getImagesFromUrls(entranceUrls);
    final kitchenImages = await _getImagesFromUrls(kitchenUrls);
    final toiletImages = await _getImagesFromUrls(toiletUrls);
    final roomImages = await _getImagesFromUrls(roomUrls);
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),

        build: (pw.Context context) {

          List<pw.Widget> content = [];
          content.add(_buildHeader(hostelName, date, hostelId , logoImage));
          content.add(pw.SizedBox(height: 20));
          // Function to add section
          void addSection(String title, List<pw.Image> images) {
            if (images.isEmpty) return;
            // content.add(_buildSectionTitle(title));
            content.add(
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal50,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Center(
                  child:  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal,
                    ),
                  ),
                )
              ),
            );

            content.add(pw.SizedBox(height: 12));
            content.add(
              pw.GridView(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: List.generate(
                  images.length,
                      (index) => _buildImageWithLabel(
                    images[index],
                    '$title Photo ${index + 1}',
                  ),
                ),
              ),
            );
            content.add(pw.SizedBox(height: 20));
          }
          if (remarks.isNotEmpty) {
            content.add(_buildRemarksSection(remarks));
          }

          content.add(pw.SizedBox(height: 20));
          // Add all sections continuously
          addSection('Entrance', entranceImages);
          addSection('Kitchen', kitchenImages);
          addSection('Toilet', toiletImages);
          addSection('Room', roomImages);

          // Remarks at the end

          return content;
        },
      ),
    );

    // Save file
    final dir = (await getApplicationDocumentsDirectory()).path;
    final sanitizedDate = date.replaceAll('/', '-');
    final sanitizedHostelName = hostelName.replaceAll(RegExp(r'[^\w\s\.-]'), '');
    final fileName = '$sanitizedHostelName-$sanitizedDate.pdf';
    final file = File('$dir/$fileName');

    await file.writeAsBytes(await pdf.save());
    controller.isLoading = false;
    OpenFilex.open(file.path);
  }


  pw.Widget _buildHeader(String hostelName, String date, String hostelId, pw.ImageProvider logoImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: pw.BoxDecoration(color: PdfColors.teal50,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.teal, width: 1),),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [  _buildLogo(logoImage),]),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              // Your app logo widget would go here

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('HOSTEL INSPECTION REPORT',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 24,
                          color: PdfColors.teal)),
                  pw.SizedBox(height: 5),
                  pw.Text(hostelName,
                      style: pw.TextStyle(fontSize: 18, color: PdfColors.teal)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.teal, width: 1.5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip('Hostel ID', hostelId),
                _buildInfoChip('Survey Date', date),
              ],
            ),
          ),
        ],
      ),
    );
  }

// A new helper function for the logo
  Future<pw.ImageProvider> _loadLogoImage() async {

    final ByteData image = await rootBundle.load('assets/images/cg.png');
    return pw.MemoryImage(image.buffer.asUint8List());
  }

// Revised _buildLogo function
  pw.Widget _buildLogo(pw.ImageProvider logoImage) {
    return pw.Container(
      height: 80,
      width: 80,
      // The Container color is now optional, as the image will fill it.
      // color: PdfColors.teal200,
      child: pw.Image(logoImage),
    );
  }


// Simplified Info Chip
  pw.Widget _buildInfoChip(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label: ',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.TextSpan(
            text: value,
            style: const pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
// --- Helper Functions ---
  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
          pw.Divider(color: PdfColors.teal, thickness: 1),
        ],
      ),
    );
  }
  pw.Widget _buildRemarksSection(String remarks) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.teal50,
        borderRadius: pw.BorderRadius.circular(4),
        // borderRadius: pw.BorderRadius.circular(8),
        // border: pw.Border.all(color: PdfColors.teal, width: 1),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Observation Note:',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            remarks,
            style: pw.TextStyle(
              fontSize: 14,
              lineSpacing: 1.5,
              color: PdfColors.grey800,
            ),
          ),
        ],
      ),
    );

  }

  pw.Widget _buildImageWithLabel(pw.Image image, String label) {
    return pw.Container(
      width: 250,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                borderRadius: pw.BorderRadius.circular(5),
                boxShadow: [
                  pw.BoxShadow(
                    color: PdfColors.grey500,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: pw.ClipRRect(
                horizontalRadius: 5,
                verticalRadius: 5,
                child: image,
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: pw.BoxDecoration(
              color: PdfColors.amber,
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
