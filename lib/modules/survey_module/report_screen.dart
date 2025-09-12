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

import '../../services/local_database.dart';
import '../../utils/color_constants.dart';
import '../../widgets/no_data_found.dart';


class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  LocalDatabase localDatabase = LocalDatabase();
  @override
  void initState() {
    super.initState();
    print("localDatabase.userID==> ${localDatabase.userID}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                                      final answersData = response['answers'] as List<dynamic>;
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
                                        controller: controller,
                                        answers: answersData,
                                      );
                                    }
                                  } finally {
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
    required List<dynamic> answers,
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
    final fontData = await rootBundle.load("assets/fonts/NotoSansDevanagari-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

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

    final entranceImages = await _getImagesFromUrls(entranceUrls);
    final kitchenImages = await _getImagesFromUrls(kitchenUrls);
    final toiletImages = await _getImagesFromUrls(toiletUrls);
    final roomImages = await _getImagesFromUrls(roomUrls);

    List<pw.Widget> _buildAnswersWidgets(List<dynamic> answers) {
      if (answers.isEmpty) return [];

      // Create the table header as a separate row
      final headerRow = pw.Container(
        decoration: const pw.BoxDecoration(color: PdfColors.teal),
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Text('Question', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            ),
            pw.Expanded(
              // flex: 3,
              child: pw.Text('Answer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            ),
          ],
        ),
      );

      // Map the answers to a list of individual rows
      final answerRows = answers.map((answerData) {
        return pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  '${answerData['question_id']}. ${answerData['question_text']}',
                  style: pw.TextStyle(color: PdfColors.grey800),
                ),
              ),

              pw.Expanded(
                // flex: 2,
                child: pw.Text(
                  answerData['answer'],
                  style: const pw.TextStyle(color: PdfColors.black),
                ),
              ),
            ],
          ),
        );
      }).toList();
      return [
        _buildSectionHeading('Inspection Form'),
        pw.SizedBox(height: 12),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            headerRow,
            ...answerRows, // Use the spread operator to add all the rows
          ],
        ),
        pw.SizedBox(height: 20),
      ];
    }

    // Helper function to return a list of widgets for a photo section
    List<pw.Widget> _buildPhotoSection(String title, List<pw.Image> images) {
      if (images.isEmpty) return [];
      return [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 8),
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
        pw.SizedBox(height: 20),
      ];
    }


    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttf,
          ),
        ),

        // Add the footer here
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          );
        },

        build: (pw.Context context) {
          final List<pw.Widget> content = [
            _buildHeader(hostelName, date, hostelId, logoImage),
            pw.SizedBox(height: 20),
          ];

          if (remarks.isNotEmpty) {
            content.add(_buildRemarksSection(remarks));
            content.add(pw.SizedBox(height: 20));
          }

          // Add the answers as a list of widgets using the helper function
          content.addAll(_buildAnswersWidgets(answers));

          // Add the heading for all photo sections
          content.add(_buildSectionHeading('Inspection Photos'));
          content.add(pw.SizedBox(height: 20));

          // Add each photo section using the helper function
          content.addAll(_buildPhotoSection('Entrance', entranceImages));
          content.addAll(_buildPhotoSection('Kitchen', kitchenImages));
          content.addAll(_buildPhotoSection('Toilet', toiletImages));
          content.addAll(_buildPhotoSection('Room', roomImages));

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

  pw.Widget _buildSectionHeading(String title, {PdfColor? color}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: color ?? PdfColors.teal50,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: color ?? PdfColors.teal, width: 0.5),
      ),
      child: pw.Text(
        title,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: color != null ? PdfColors.white : PdfColors.teal800,
        ),
      ),
    );
  }

  pw.Widget _buildHeader(String hostelName, String date, String hostelId, pw.ImageProvider logoImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: pw.BoxDecoration(color: PdfColors.teal50,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.teal, width: 1),),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center, // Center the entire column
        children: [

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              _buildLogo(logoImage),
            ],
          ),
          pw.SizedBox(height: 10),

          // This column will now handle the text, and the wrapping will work correctly
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'HOSTEL INSPECTION REPORT',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 24,
                  color: PdfColors.teal,
                ),
                textAlign: pw.TextAlign.center, // Ensure text is centered within its space
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                hostelName,
                style: pw.TextStyle(fontSize: 18, color: PdfColors.teal),
                textAlign: pw.TextAlign.center, // Ensure long names wrap and stay centered
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

  Future<pw.ImageProvider> _loadLogoImage() async {
    final ByteData image = await rootBundle.load('assets/images/cg.png');
    return pw.MemoryImage(image.buffer.asUint8List());
  }

  pw.Widget _buildLogo(pw.ImageProvider logoImage) {
    return pw.Container(
      height: 80,
      width: 80,
      // The Container color is now optional, as the image will fill it.
      // color: PdfColors.teal200,
      child: pw.Image(logoImage),
    );
  }
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
  pw.Widget _buildRemarksSection(String remarks) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.teal50,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.teal, width: 1),
      ),
      child: pw.Column(
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
          pw.SizedBox(height: 8), // Add a vertical space instead of horizontal
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
