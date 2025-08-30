import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import '../../../controllers/admin_dashboard_controller.dart';
import '../../../utils/color_constants.dart';
import '../../../widgets/custom_search_textField.dart';
import '../../../widgets/no_data_found.dart';
import 'hostel_detail_screen.dart';

class HostelListScreen extends StatefulWidget {
  const HostelListScreen({super.key});

  @override
  State<HostelListScreen> createState() => _HostelListScreenState();
}

class _HostelListScreenState extends State<HostelListScreen> {
  final TextEditingController searchHostel = TextEditingController();
  List<dynamic> filteredHostelList = [];
  List<dynamic> originalHostelList = [];
  bool _isSearching = false; // New state variable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardController>(context, listen: false).getHostel(context: context).then((_) {
        final controller = Provider.of<DashboardController>(context, listen: false);
        originalHostelList = controller.hostelList;
        filteredHostelList = originalHostelList;
      });
    });
  }

  void _runFilter(String enteredKeyword) {
    List<dynamic> results;
    if (enteredKeyword.isEmpty) {
      results = originalHostelList;
    } else {
      results = originalHostelList.where((hostel) {
        final hostelName = hostel.hostel_name.toLowerCase();
        final hostelId = hostel.hostel_id.toString().toLowerCase();
        final keyword = enteredKeyword.toLowerCase();
        return hostelName.contains(keyword) || hostelId.contains(keyword);
      }).toList();
    }
    setState(() {
      filteredHostelList = results;
    });
  }

  // New method to clear search and reset state
  void _clearSearch() {
    setState(() {
      _isSearching = false;
      searchHostel.clear();
      filteredHostelList = originalHostelList;
    });
  }

  @override
  void dispose() {
    searchHostel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        centerTitle: true,
        title: _isSearching
            ? SearchTextField(
          controller: searchHostel,
          onChanged: _runFilter,
          hintText: 'Search by Name',
          // You can remove the fixed dimensions and let it fill the space
        )
            : Text('Hostels', style: GoogleFonts.lato()),
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

          if (controller.hostelList.isNotEmpty && filteredHostelList.isEmpty && !_isSearching) {
            originalHostelList = controller.hostelList;
            filteredHostelList = originalHostelList;
          }

          if (filteredHostelList.isEmpty && !controller.isLoading) {
            return NoDataFound(
              heightFactor: 0.35,
              color: Colors.teal,
              message: 'No Data Found',
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
              itemCount: filteredHostelList.length,
              itemBuilder: (context, index) {
                final detail = filteredHostelList[index];
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/hostelDetail', arguments: HostelDetailScreen(hostelID: detail.hostel_id.toString(), hostelName: detail.hostel_name, hostelTotalVisits: detail.officers_visited));
                  },
                  child: Container(
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
                          Row(
                            children: [
                              const Icon(Icons.home_work_outlined, color: AppColors.blueGrey, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  detail.hostel_name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blueGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, thickness: 1, color: AppColors.lightBlueGrey),
                          Row(
                            children: [
                              const Icon(Icons.numbers_sharp, color: AppColors.blueGrey, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Total Surveys: ${detail.officers_visited}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}