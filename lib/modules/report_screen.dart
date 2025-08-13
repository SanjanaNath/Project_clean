import 'dart:io';
import 'dart:typed_data'; // Add this import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
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

          if (controller.surveyHistoryList.isEmpty && !controller.isLoading) {
            return NoDataFound(
              heightFactor: 0.35,
              color: Colors.teal,
              message: 'No Survey History',
              buildContext: context,
            );
          }
          return ModalProgressHUD(
              inAsyncCall: controller.isLoading ?? false,
              child:
              // true
              //     ?
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                    DateFormat('dd/MM/yyyy').format(DateTime.parse(survey.attendanceDate)),
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
                                    survey.hostelName, // Use your dynamic hostel name variable here
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

                                onPressed: () async {
                                  final response = await controller.reportGenerate(
                                    context: context,
                                    attendanceID: survey.attendanceID,
                                  );

                                  if (response != null && response['success'] == true) {
                                    final attendanceData = response['attendance'];
                                    final imagesData = response['images'] as List<dynamic>;

                                    // Group images by type
                                    Map<String, List<String>> groupedImages = {};
                                    for (var image in imagesData) {
                                      final imageType = image['image_type'];
                                      final imageUrl = image['image_url'];
                                      if (imageUrl != null) {
                                        // You might need to prepend the base URL for the images
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

                                    generateReport(
                                      context: context,
                                      hostelName: attendanceData['hostel_name'] ?? '',
                                      hostelId: attendanceData['hostel_id'] ?? '',
                                      date: DateFormat('dd/MM/yyyy').format(DateTime.parse(attendanceData['attendance_date'])),
                                      entranceUrls: groupedImages['Entrance'] ?? [],
                                      kitchenUrls: groupedImages['Kitchen'] ?? [],
                                      toiletUrls: groupedImages['Bathroom & Toilet'] ?? [],
                                      roomUrls: groupedImages['Room'] ?? [],
                                      remarks: remarks,
                                    );
                                  }
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
  })
  async {
    final pdf = pw.Document();

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

    final entranceImages = await _getImagesFromUrls(entranceUrls.take(4).toList());
    final kitchenImages = await _getImagesFromUrls(kitchenUrls.take(4).toList());
    final toiletImages = await _getImagesFromUrls(toiletUrls.take(4).toList());
    final roomImages = await _getImagesFromUrls(roomUrls.take(4).toList());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              'Hostel Report',
              style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.teal),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              hostelName,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.teal),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Survey Date: $date"),
              pw.Text("Hostel ID: $hostelId"),
            ],
          ),
          pw.Divider(color: PdfColors.teal),
          _buildImageSection('Entrance Images', entranceImages),
          _buildImageSection('Kitchen Images', kitchenImages),
          _buildImageSection('Toilet Images', toiletImages),
          _buildImageSection('Room Images', roomImages),
          pw.SizedBox(height: 20),
          pw.Text('Remarks:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(remarks),
        ],
      ),
    );

    // final dir = (await getApplicationDocumentsDirectory()).path;
    // final file = File('$dir/$hostelName-$date.pdf');
    // await file.writeAsBytes(await pdf.save());
    // OpenFilex.open(file.path);
    final dir = (await getApplicationDocumentsDirectory()).path;

    // Sanitize the filename to remove invalid characters
    final sanitizedDate = date.replaceAll('/', '-');

    // Also sanitize the hostel name just in case it contains invalid characters
    final sanitizedHostelName = hostelName.replaceAll(RegExp(r'[^\w\s\.-]'), '');

    final fileName = '$sanitizedHostelName-$sanitizedDate.pdf';
    final file = File('$dir/$fileName');

    await file.writeAsBytes(await pdf.save());
    OpenFilex.open(file.path);
  }

  pw.Widget _buildImageSection(String title, List<pw.Image> images) {
    if (images.isEmpty) return pw.SizedBox.shrink();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
        pw.GridView(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          children: images,
        ),
      ],
    );
  }

}
