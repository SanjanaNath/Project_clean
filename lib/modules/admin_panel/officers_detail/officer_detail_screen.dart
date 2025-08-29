import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../controllers/admin_dashboard_controller.dart';
import '../../../utils/color_constants.dart';
import '../../../widgets/no_data_found.dart';

class OfficerDetailScreen extends StatefulWidget {
  final String officerID;
  final String officerName;
  final String officerNo;

  const OfficerDetailScreen({
    super.key,
    required this.officerID,
    required this.officerName,
    required this.officerNo,
  });

  @override
  State<OfficerDetailScreen> createState() => _OfficerDetailScreenState();
}

class _OfficerDetailScreenState extends State<OfficerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardController>(context, listen: false)
          .getOfficerDetails(context: context, officerID: widget.officerID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        // centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.officerName,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              widget.officerNo,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<DashboardController>(
        builder: (context, controller, child) {
          if (controller.officerDetailList.isEmpty && !controller.isLoading) {
            return  NoDataFound(
              buildContext: context ,
              heightFactor: 0.35,
              color: Colors.teal,
              message: 'No Data Found',
            );
          }

          return ModalProgressHUD(
            inAsyncCall: controller.isLoading,
            progressIndicator: CircularProgressIndicator(
              color: ColorConstants().teal,
            ),
            blur: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14 , horizontal: 20),
                  child: Text(
                    'Hostels Visited', // Clear title for the list
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.officerDetailList.length,
                    itemBuilder: (context, index) {
                      final detail = controller.officerDetailList[index];
                      final formattedDate = DateFormat('dd-MM-yyyy')
                          .format(DateTime.parse(detail.attendanceDate));

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [Colors.teal.shade50, Colors.teal.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hostel Name with Icon
                              Row(
                                children: [
                                  const Icon(Icons.home_work_outlined, color: AppColors.blueGrey, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      detail.hostelName,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.blueGrey
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20, thickness: 1, color:AppColors.lightBlueGrey),
                              // Survey Date with Icon
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: AppColors.blueGrey, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Survey Date: $formattedDate',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color:AppColors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}