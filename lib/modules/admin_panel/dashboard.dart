import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../../utils/color_constants.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_search_textField.dart';
import 'hostel_detail/hostel_detail_screen.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSearching = false;

  List<dynamic> filteredList = [];
  List<dynamic> originalList = [];


  final List<Map<String, dynamic>> _categoryList = [
    {'name': 'monthly surveys', 'color' : AppColors.green ,'selectedColor': const Color(0xFFD3EFD5) },
    {'name': 'least surveys', 'color' : AppColors.accentOrange ,'selectedColor': AppColors.lightAccentOrange },
    {'name': 'zero surveys',  'color' : AppColors.red , 'selectedColor': const Color(0xFFFFEBEE)},
  ];

  List<Color> lightTileColors = [
    const Color(0xFFF5F5F5), // White Smoke - a very light, clean gray
    const Color(0xFFE8F6F3), // Light Cyan - a pale, almost minty teal
  ];

  List<Color> primaryAvatarColors = [
    const Color(0xFF008080), // Classic Teal
    const Color(0xFF5F9EA0),  // Cadet Blue - a cool, dusty blue-gray
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardController>(context, listen: false).fetchHostelReportByDate(context: context, date: DateFormat('yyyy-MM-dd').format(_selectedDate), month: "", from: "", to: "").then((_) {
        final controller = Provider.of<DashboardController>(context, listen: false);
        originalList = controller.hostelReportByDate;
        filteredList = originalList;
      });
    });
  }

  void _runFilter(String enteredKeyword) {
    List<dynamic> results;
    if (enteredKeyword.isEmpty) {
      results =originalList;
    } else {
      results =originalList.where((report) {
        final officerName = report.officerNames.toLowerCase();
        final hostelName = report.hostelName.toLowerCase();
        final keyword = enteredKeyword.toLowerCase();
        return officerName.contains(keyword) || hostelName.contains(keyword);
      }).toList();
    }
    setState(() {
      filteredList = results;
    });
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      filteredList =originalList;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: const AdminDrawer(),
        backgroundColor: AppColors.backgroundLight,
        body: Consumer<DashboardController>(builder: (context, controller, child) {
          return  ModalProgressHUD(
            inAsyncCall: controller.isLoading,
            blur: 2,
            progressIndicator: CircularProgressIndicator(
              color: ColorConstants().teal,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded( // This will give the title room to breathe and not overflow
                              child: _buildSectionTitle('Survey Overview'),
                            ),
                            _buildDateSelector(controller), // This is the new widget
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDailySurveyCard(controller),
                        const SizedBox(height: 24),
                        _buildActivityHeader(controller),
                        const SizedBox(height: 12),
                        _buildCategoryList(controller),
                        _buildOfficerList(controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },)
    );
  }


  Widget _buildActivityHeader(DashboardController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Conditionally show title or search field
        _isSearching
            ? Expanded(
          child: SearchTextField(
            controller: _searchController,
            onChanged: _runFilter,
            hintText: 'Search by Officer or Hostel',
          ),
        )
            : _buildSectionTitle('Survey Activity'),

        // Conditionally show search icon or close icon
        _isSearching
            ? IconButton(
          icon: const Icon(Icons.close, color: AppColors.textMedium),
          onPressed: _clearSearch,
        )
            : Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textMedium),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
            // The new, refined Report Button
            InkWell(
              onTap: () {
                controller.isLoading = true;
                _generateReport(controller);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryTeal, AppColors.tealAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Report',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 12, right: 24, bottom: 20), // Adjust padding
      decoration:  BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryTeal, AppColors.tealAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Add the menu icon button here
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          // The rest of your header content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Survey Monitoring',
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Admin Dashboard',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/cg.png'),
          ),
        ],
      ),
    );
  }


  Widget _buildDateSelector(DashboardController controller) {
    return InkWell(
      onTap: () {
        _showDateSelectionSheet(context, controller);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryTeal, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Use this to make the button fit the content
          children: [
            Icon(Icons.calendar_today, size: 20, color: AppColors.primaryTeal),
            const SizedBox(width: 8),
            Text(
              _startDate != null && _endDate != null
                  ? '${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}'
                  : DateFormat('dd/MM/yy').format(_selectedDate),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),

            const Icon(Icons.arrow_drop_down, color: AppColors.primaryTeal),
          ],
        ),
      ),
    );
  }
// New method to show the date selection options
  void _showDateSelectionSheet(BuildContext context, DashboardController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Select Date",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  _selectSingleDate(controller);
                },
                icon: const Icon(Icons.calendar_today, color: Colors.white,),
                label: const Text("Select a Single Date"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  _selectDateRange(controller);
                },
                icon: const Icon(Icons.date_range, color: Colors.white,),
                label: const Text("Select a Date Range", ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.primaryTeal,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.primaryTeal),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// New methods for a cleaner structure
  void _selectSingleDate(DashboardController controller)
  async {
    setState(() {
      _selectedCategory = null;
    });
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryTeal),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _startDate = null;
        _endDate = null;
      });
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      controller.fetchHostelReportByDate(
        context: context,
        date: formattedDate,
        month: "",
        from: "",
        to: "",
      );
    }
  }

  void _selectDateRange(DashboardController controller) async {
    setState(() {
      _selectedCategory = null;
    });
    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryTeal),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
        // _selectedDate = DateTime.now();
      });
      final formattedFromDate = DateFormat('yyyy-MM-dd').format(_startDate!);
      final formattedToDate = DateFormat('yyyy-MM-dd').format(_endDate!);
      controller.fetchHostelReportByDate(
        context: context,
        date: "",
        month: "",
        from: formattedFromDate,
        to: formattedToDate,
      );
    }
  }
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildDailySurveyCard(DashboardController controller) {
    int totalSurveys = controller.totalReportsCount;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryTeal, AppColors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.assignment_turned_in, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // _selectedDate.day == DateTime.now().day &&
                  //     _selectedDate.month == DateTime.now().month &&
                  //     _selectedDate.year == DateTime.now().year
                  //     ?'Total Surveys Today'
                  //     : 'Total Surveys',
                  'Total Surveys',

                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  totalSurveys.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerList(DashboardController controller) {
    if (controller.hostelReportByDate.isEmpty) {
      return  Column(
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 80)),
          Center(child:   Text(
            'No Data Found',
            style: GoogleFonts.poppins(
              color: Colors.teal,
            ),
          ),),
        ],
      );

    }
    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        // itemCount: controller.hostelReportByDate.length,
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          // final report = controller.hostelReportByDate[index];
          final report = filteredList[index];
          final tileColor = _selectedCategory != null
              ? _categoryList.firstWhere((c) => c['name'] == _selectedCategory)['selectedColor'] as Color
              : lightTileColors[index % lightTileColors.length];
          final primaryColor = _selectedCategory != null
              ? (_categoryList.firstWhere((c) => c['name'] == _selectedCategory)['color'] as Color)
              : primaryAvatarColors[index % primaryAvatarColors.length];
          String formattedDate = '';
          try {
            if (report.attendanceDate != null && report.attendanceDate.isNotEmpty) {
              final attendanceDateTime = DateFormat("yyyy-MM-dd").parse(report.attendanceDate);
              formattedDate = DateFormat('dd-MM-yyyy').format(attendanceDateTime);
            }
          } catch (e) {
            print("Date parse error: $e, value: ${report.attendanceDate}");
          }

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              horizontalOffset: 50,
              child: FadeInAnimation(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/hostelDetail', arguments: HostelDetailScreen(hostelID: report.hostelId.toString(), hostelName: report.hostelName, hostelTotalVisits: report.officersVisited));
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: tileColor,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.4),
                        child: const Icon(Icons.home_work, color: Colors.white),
                      ),
                      title: _selectedCategory == null ?Text(
                        report.officerNames,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ): null,
                      subtitle: Text(
                        report.hostelName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Surveys: ${report.officersVisited}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          if(formattedDate != '' && _selectedCategory == null)
                            Text(
                              "Date: $formattedDate",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(DashboardController controller) {
    final dateTime = _selectedDate;
    final formattedMonth = DateFormat('yyyy-MM').format(dateTime);
    final formattedYear = DateFormat('yyyy').format(dateTime);

    return SizedBox(
      height: 30,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categoryList.length,
          itemBuilder: (context, index) {
            final category = _categoryList[index];
            final categoryColor = category['color'] as Color;
            final isSelected = _selectedCategory == category['name'];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          // Check if a date range is selected. If so, clear it.
                          if (_startDate != null) {
                            _startDate = null;
                            _endDate = null;
                          }

                          _selectedCategory = isSelected ? null : category['name'];
                          if (_selectedCategory == 'monthly surveys') {
                            controller.fetchHostelReportByDate(context: context, date: '', month: formattedMonth, from: '', to: '');
                          } else if (_selectedCategory == 'least surveys') {
                            controller.zeroLeastHostel(context: context, year: formattedYear, flag: 'least');
                          } else if (_selectedCategory == 'zero surveys') {
                            controller.zeroLeastHostel(context: context, year: formattedYear, flag: 'zero');
                          } else {
                            final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
                            controller.fetchHostelReportByDate(context: context, date: formattedDate, month: '', from: '', to: '');
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color:  isSelected ? categoryColor :AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border:Border.all(color:categoryColor ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: (category['color'] as Color).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(1, 4),
                            ),
                          ]
                              : null,
                        ),
                        child: Text(
                          category['name'] as String,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: isSelected ? Colors.white : categoryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _generateReport(DashboardController controller) async {
    if (filteredList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to generate a report.')),
      );
      return;
    }

    // Load fonts
    final fontData = await rootBundle.load("assets/fonts/NotoSansDevanagari-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final ByteData imageData = await rootBundle.load('assets/images/cg.png');
    final Uint8List bytes = imageData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(bytes);

    String reportTitle;
    if (_selectedCategory != null) {
      String categoryName = _selectedCategory!.replaceAll('surveys', 'Surveys');
      if (_selectedCategory == 'monthly surveys') {
        reportTitle = '$categoryName Summary ${DateFormat.yMMMM().format(_selectedDate)}';
      } else {
        reportTitle = '${categoryName.toUpperCase()} Analysis ${DateFormat.y().format(_selectedDate)}';
      }
    } else if (_startDate != null && _endDate != null) {
      reportTitle =
      'Survey Overview from ${DateFormat('dd-MM-yy').format(_startDate!)} to ${DateFormat('dd-MM-yy').format(_endDate!)}';
    } else {
      reportTitle = 'Surveys on ${DateFormat('dd-MM-yy').format(_selectedDate)}';
    }

    final pdf = pw.Document();

// --- Dynamic Headers and Data based on selection ---
    List<String> headers;
    List<List<String>> data;

    if (_selectedCategory != null) {
      // When a category is selected, show only Hostel Name and Total Surveys
      headers = ['Hostel Name', 'Total Surveys'];
      data = filteredList.map((report) {
        final totalSurveys = report.officersVisited?.toString() ?? '0';
        return <String>[ // Explicitly define the type of the inner list
          report.hostelName?.toString() ?? 'N/A',
          totalSurveys,
        ];
      }).toList(); // No need for .cast() here
    }
    else {
      // Otherwise, show all columns
      headers = ['Hostel Name', 'Officer Name', 'Survey Date', 'Total Surveys'];
      data = filteredList.map((report) {
        final officerName = (report.officerNames != null && report.officerNames!.trim().isNotEmpty)
            ? report.officerNames!
            : 'N/A';
        String formattedDate = 'N/A';
        try {
          if (report.attendanceDate != null && report.attendanceDate.trim().isNotEmpty) {
            final attendanceDateTime = DateFormat("yyyy-MM-dd").parse(report.attendanceDate);
            formattedDate = DateFormat('dd-MM-yyyy').format(attendanceDateTime);
          }
        } catch (e) {
          formattedDate = 'N/A';
        }
        final totalSurveys = report.officersVisited?.toString() ?? '0';
        return <String>[ // Explicitly define the type of the inner list
          report.hostelName?.toString() ?? 'N/A',
          officerName,
          formattedDate,
          totalSurveys,
        ];
      }).toList(); // No need for .cast() here
    }

    print("PDF Data $data");

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttf,
          ),
          buildBackground: (pw.Context context) {
            return pw.Center(
              child: pw.Transform.rotate(
                angle: 0,
                child: pw.Opacity(
                  opacity: 0.08,
                  child: pw.Image(logoImage, width: 300, height: 300),
                ),
              ),
            );
          },
        ),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Hostel Inspection Report',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        reportTitle,
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Image(logoImage, width: 80, height: 80),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColors.grey300, thickness: 1.5),
              pw.SizedBox(height: 10),
            ],
          );
        },
        build: (pw.Context context) {
          final List<pw.TableRow> tableRows = List.generate(
            data.length,
                (index) {
              final backgroundColor =
              index % 2 == 0 ? PdfColors.white : PdfColor.fromHex('F5F5F5');
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: backgroundColor),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text((index + 1).toString(), style: pw.TextStyle(fontSize: 9)),
                  ),
                  ...data[index].map((cell) =>
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(cell.toString(), style: pw.TextStyle(fontSize: 9)),
                      ),
                  ).toList(),
                ],
              );
            },
          );

          return [
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              // Dynamic column widths based on headers
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(3),
                if (_selectedCategory == null) ...{
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                _selectedCategory == null ? 4: 2: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.teal),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('S.N.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                    ...headers.map((header) =>
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(header, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                        ),
                    ).toList(),
                  ],
                ),
                ...tableRows,
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated on: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Text(
                "Page ${context.pageNumber} of ${context.pagesCount}",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    final String path = (await getTemporaryDirectory()).path;
    final String fileName = 'survey_report.pdf';
    final File file = File('$path/$fileName');
    await file.writeAsBytes(await pdf.save());

    final result = await OpenFilex.open(file.path);
    if (result.type == ResultType.done) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Report generated and opened successfully!')),
      // );
      controller.isLoading = false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open the report.')),
      );
    }
  }



}