import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:project_clean/controllers/admin_dashboard_controller.dart';
import 'package:project_clean/modules/admin_panel/officers_detail/officer_detail_screen.dart';
import 'package:provider/provider.dart';

import '../../../utils/color_constants.dart';
import '../../../widgets/custom_search_textField.dart';
import '../../../widgets/no_data_found.dart';

class OfficerListScreen extends StatefulWidget {
  const OfficerListScreen({super.key});

  @override
  State<OfficerListScreen> createState() => _OfficerListScreenState();
}

class _OfficerListScreenState extends State<OfficerListScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Provider.of<DashboardController>(context, listen: false).getOfficers(context: context);
  //   });
  // }
  final TextEditingController searchOfficer = TextEditingController();
  List<dynamic> filteredOfficerList = [];
  List<dynamic> originalOfficerList = [];
  bool _isSearching = false; // New state variable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardController>(context, listen: false).getOfficers(context: context).then((_) {
        final controller = Provider.of<DashboardController>(context, listen: false);
        originalOfficerList = controller.officersList;
        filteredOfficerList = originalOfficerList;
      });
    });
  }

  void _runFilter(String enteredKeyword) {
    List<dynamic> results;
    if (enteredKeyword.isEmpty) {
      results = originalOfficerList;
    } else {
      results = originalOfficerList.where((officer) {
        final officerName = officer.name.toLowerCase();
        final officerContact = officer.mobile.toString().toLowerCase();
        final keyword = enteredKeyword.toLowerCase();
        return officerName.contains(keyword) || officerContact.contains(keyword);
      }).toList();
    }
    setState(() {
      filteredOfficerList = results;
    });
  }

  // New method to clear search and reset state
  void _clearSearch() {
    setState(() {
      _isSearching = false;
      searchOfficer.clear();
      filteredOfficerList = originalOfficerList;
    });
  }

  @override
  void dispose() {
    searchOfficer.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        centerTitle: true,
        // title: Text('Officers', style: GoogleFonts.lato()),
        title: _isSearching
            ? SearchTextField(
          controller: searchOfficer,
          onChanged: _runFilter,
          hintText: 'Search by Name & No.',
          // You can remove the fixed dimensions and let it fill the space
        )
            : Text('Officers', style: GoogleFonts.lato()),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black),
            onPressed: () {
              if (_isSearching) {
                _clearSearch();
              }
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
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
      body: Consumer<DashboardController>(
        builder: (context, controller, child) {
          if (controller.officersList.isEmpty && !controller.isLoading) {
            return NoDataFound(
              heightFactor: 0.35,
              color: Colors.teal,
              message: 'No Officers Found',
              buildContext: context,
            );
          }

          return ModalProgressHUD(
            inAsyncCall: controller.isLoading,
            progressIndicator: CircularProgressIndicator(
              color: ColorConstants().teal,
            ),
            blur: 2,
            child: ListView.builder(
              // itemCount: controller.officersList.length,
              itemCount: filteredOfficerList.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: size.height * 0.12),
              itemBuilder: (context, index) {

                final officer = filteredOfficerList[index];
                return OfficerCard(officer: officer);
              },
            ),
          );
        },
      ),
    );
  }
}

class OfficerCard extends StatelessWidget {
  final Officer officer;


   OfficerCard({Key? key, required this.officer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/officerDetail',   arguments: OfficerDetailScreen(officerID: officer.id.toString(), officerName: officer.name, officerNo: officer.mobile,),);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Officer Name
              Row(
                children: [
                  const Icon(Icons.person_outline, color: AppColors.blueGrey, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      officer.name,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.lightBlueGrey, height: 20),

              // Designation
              _buildInfoRow(
                icon: Icons.badge_outlined,
                label: 'Designation',
                value: officer.designation,
              ),
              const SizedBox(height: 10),

              // Mobile Number
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: 'Mobile',
                value: officer.mobile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.blueGrey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 14,
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