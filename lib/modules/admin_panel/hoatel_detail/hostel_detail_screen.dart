import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../controllers/admin_dashboard_controller.dart';
import '../../../utils/color_constants.dart';
import '../../../widgets/no_data_found.dart';

class HostelDetailScreen extends StatefulWidget {
  final String hostelID;
  final String hostelName;
  final String hostelTotalVisits;
  const HostelDetailScreen({
    super.key,
    required this.hostelID,
    required this.hostelName,
    required this.hostelTotalVisits,
  });

  @override
  State<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends State<HostelDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardController>(context, listen: false)
          .getHostelDetails(context: context, hostelID: widget.hostelID);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align title to the left
          children: [
            Text(
              widget.hostelName,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Total Surveys: ${widget.hostelTotalVisits}',
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
          if (controller.hostelDetailList.isEmpty && !controller.isLoading) {
            return  NoDataFound(
              buildContext: context,
              heightFactor: 0.35,
              color: Colors.teal,
              message: 'No Survey Found',
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
                    'Officer Visited', // Clear title for the list
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.hostelDetailList.length,
                    itemBuilder: (context, index) {
                      final visit = controller.hostelDetailList[index];
                      return HostelVisitCard(visit: visit);
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

class HostelVisitCard extends StatelessWidget {
  final HostelDetailList visit;
  const HostelVisitCard({Key? key, required this.visit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(visit.attendanceDate));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        // border: Border.all(color: AppColors.primaryTeal),
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.teal.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Officer Name
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blueGrey, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    visit.officerName,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                ),
              ],
            ),
             Divider(color: AppColors.lightBlueGrey, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date of Visit',
                  value: formattedDate,
                ),
                const SizedBox(height: 10),
                // Officer Contact
                _buildInfoItem(
                  icon: Icons.phone_outlined,
                  label: 'Officer Contact',
                  value: visit.officerContact,
                ),
              ],
            )

          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.blueGrey, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 11,
                color: AppColors.blueGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.blueGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}