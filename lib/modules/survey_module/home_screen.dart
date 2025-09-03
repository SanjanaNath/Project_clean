import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:project_clean/modules/survey_module/survey_form.dart';
import 'package:provider/provider.dart';
import '../../../utils/color_constants.dart';
import '../../controllers/screens_controller.dart';
import '../../services/local_database.dart';
import '../../widgets/custom_drawer.dart';
import 'captured_gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalDatabase localDatabase = LocalDatabase();
   final ScreenController screencontroller = ScreenController();
  Future<void> _fetchBlock() async {
    return await context.read<ScreenController>().fetchBlock(
      context: context,
    );
  }

  Future<void> _fetchQuestions() async {
    return await context.read<ScreenController>().fetchQuestions(
      context: context,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchBlock();
      _fetchQuestions();
    });
  }
  @override
  void dispose() {
    screencontroller.remarkController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const SchoolDrawer(),
      body: Consumer<ScreenController>(
        builder: (context, controller, child) {
          return ModalProgressHUD(
            inAsyncCall: controller.isLoading,
            blur: 2,
            progressIndicator: CircularProgressIndicator(
              color: ColorConstants().teal,
            ),
            child: Stack(
              children: [
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal.shade800,
                        Colors.teal.shade400,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        // User info section
                        _buildUserInfoSection(context),
                        const SizedBox(height: 20),

                        // Main action card
                        _buildMainActionCard(context, controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/cg.png')
              ),
            ),
            const SizedBox(height: 10),
            // User greeting
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${localDatabase.userName ?? 'User'}!',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                Text(
                  'Ready for your survey?',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMainActionCard(BuildContext context, ScreenController controller) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 10,
      shadowColor: Colors.teal.shade100,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownSearch<String>(
              items: controller.blocks.map((e) => e.blockName).toList(),
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(hintText: "Search block..."),
                ),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: _getDropdownDecoration(context, "Select Block"),
              ),
              onChanged: (value) {
                controller.sites.clear();
                controller.clearSelectedSite();
                if (value != null) {
                  controller.selectedBlockName = value;
                  final selectedBlock = controller.blocks.firstWhere((block) => block.blockName == value);
                  controller.fetchHostelList(
                    context: context,
                    blockCode: selectedBlock.blockCode,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            DropdownSearch<String>(
              items: controller.sites.map((e) => e.hostelName).toList(),
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(hintText: "Search site..."),
                ),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: _getDropdownDecoration(context, "Select Site"),
              ),
              onChanged: (value) {
                if (value != null) {
                  controller.selectSite(value);
                }
              },
            ),
            const SizedBox(height: 20),
            if (controller.selectedSiteName != null) ...[
              _buildAttendanceSection(context, controller),
              const SizedBox(height: 24),
              if (controller.isAttendanceMarked) ...[
                _photoCategoriesGrid(context, controller),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurveyFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description, color: Colors.white),
                  label: const Text(
                    'Survey Form',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal, // A new color to differentiate
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 15),
                // if (controller.allCategoriesHavePhotos) ...[
                //   ElevatedButton.icon(
                //     onPressed: () async {
                //       final result = await showDialog<String>(
                //         context: context,
                //         builder: (context) => RemarksDialog(
                //           initialRemarks: controller.remarkController.text,
                //         ),
                //       );
                //       if (result != null) {
                //         setState(() {
                //           controller.remarkController.text = result;
                //         });
                //       }
                //     },
                //     icon: const Icon(Icons.edit_note, color: Colors.white),
                //     label: const Text(
                //       'Add Remarks',
                //       style: TextStyle(fontSize: 16, color: Colors.white),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.primaryTeal,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //     ),
                //   ),
                //   const SizedBox(height: 24),
                //   if (controller.remarkController.text.isNotEmpty) ...[
                //     Text(
                //       'Remarks:',
                //       style: GoogleFonts.lato(
                //         fontSize: 16,
                //         fontWeight: FontWeight.bold,
                //         color: AppColors.deepBlue,
                //       ),
                //     ),
                //     const SizedBox(height: 8),
                //     Text(
                //       controller.remarkController.text,
                //       style: GoogleFonts.lato(fontSize: 14, color: AppColors.textDark),
                //     ),
                //     // const SizedBox(height: 24),
                //     // _buildSubmitButton(context, controller),
                //   ],
                //
                // ],
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) => RemarksDialog(
                        initialRemarks: controller.remarkController.text,
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        controller.remarkController.text = result;
                      });
                    }
                  },
                  icon: const Icon(Icons.edit_note, color: Colors.white),
                  label: const Text(
                    'Add Remarks',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 15),
                if (controller.remarkController.text.isNotEmpty) ...[
                  Text(
                    'Remarks:',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.remarkController.text,
                    style: GoogleFonts.lato(fontSize: 14, color: AppColors.textDark),
                  ),
                  // const SizedBox(height: 24),
                  // _buildSubmitButton(context, controller),
                ],
                const SizedBox(height: 24),
                _buildSubmitButton(context, controller),
              ]
              else ...[
                const SizedBox(height: 20),
              ],

            ],
          ],

        ),
      ),
    );
  }

  Widget _buildAttendanceSection(BuildContext context, ScreenController controller) {
    return Column(
      children: [
        Icon(
          controller.isAttendanceMarked ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: 60,
          color: controller.isAttendanceMarked ? AppColors.primaryTeal : AppColors.accentOrange,
        ),
        const SizedBox(height: 16),
        Text(
          controller.isAttendanceMarked
              ? 'Attendance Marked!'
              : 'Site Selected: ${controller.selectedSiteName}',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.deepBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          controller.isAttendanceMarked
              ? 'You can now proceed with taking photos.'
              : 'Tap below to mark your attendance for ${controller.selectedSiteName}.',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 16,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 24),
        if (!controller.isAttendanceMarked)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              elevation: 5,
            ),
            onPressed: () => controller.markAttendance(
              context,
              controller.selectedSite?.hostelID_id ?? 0,
              controller.selectedSiteName ?? '',
            ),
            icon: const Icon(Icons.location_on_rounded),
            label: Text('Mark Attendance', style: GoogleFonts.lato(fontSize: 16)),
          ),
      ],
    );
  }

  Widget _photoCategoriesGrid(BuildContext context, ScreenController controller) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: controller.photoCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemBuilder: (context, index) {
        final category = controller.photoCategories[index];
        final images = controller.capturedImages[category.name] ?? [];
        final hasImage = images.isNotEmpty;

        return InkWell(
          // onTap: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => CategoryGalleryScreen(
          //         category: category.name,
          //         images: images,
          //         onImagesUpdated: (imgs) => controller.updateImages(category.name, imgs),
          //       ),
          //     ),
          //   );
          // },


          onTap: () async {
            if (controller.selectedSite == null) {
              controller.showSnackBar(context, "Please select a site first.", Colors.red);
              return;
            }

            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.denied) {
                controller.showSnackBar(context, "Location permission is required to take photos.", Colors.red);
                return;
              }
            }
            if (permission == LocationPermission.deniedForever) {
              controller.showSnackBar(context, "Enable location from settings to take photos.", Colors.red);
              return;
            }

            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);

            double distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              controller.selectedSite!.lat,
              controller.selectedSite!.lng,
            );

            if (distance <= 100) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryGalleryScreen(
                    category: category.name,
                    images: images,
                    onImagesUpdated: (imgs) => controller.updateImages(category.name, imgs),
                  ),
                ),
              );
            } else {
              controller.showSnackBar(
                  context,
                  "You are too far from ${controller.selectedSiteName}.",
                  Colors.red);
              controller.isLoading = false;
            }
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: hasImage ? 8 : 4,
            shadowColor: hasImage ? AppColors.accentOrange.withOpacity(0.4) : AppColors.lightGrey,
            child: Container(
              decoration: BoxDecoration(
                color: hasImage ? Colors.white : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: hasImage ? Border.all(color: AppColors.accentOrange, width: 2) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  hasImage
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(images.last,
                        width: 80, height: 80, fit: BoxFit.cover),
                  )
                      : Icon(category.icon, size: 48, color: AppColors.deepBlue),
                  const SizedBox(height: 8),
                  Text(category.name,
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold, color: AppColors.deepBlue)),
                  if (hasImage)
                    Text("${images.length} photo(s)",
                        style: GoogleFonts.lato(
                            fontSize: 12, color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, ScreenController controller) {
    final bool canSubmit = controller.isAttendanceMarked &&
        controller.allCategoriesHavePhotos &&
        controller.remarkController.text.isNotEmpty &&
        controller.isSurveyComplete;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: canSubmit ? AppColors.primaryTeal : AppColors.lightGrey,
        foregroundColor: canSubmit ? Colors.white : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 5,
        textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      icon:  Icon(Icons.cloud_upload, color: canSubmit ? Colors.white : Colors.grey),
      label: const Text("Submit Photos & Form"),
      onPressed: () async {
        // if (controller.capturedImages.isEmpty ||
        //     controller.capturedImages.values.every((list) => list.isEmpty)) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text("Please capture all the photos.")),
        //   );
        //   return;
        // }

        // bool formIsComplete = true;
        //
        // // Check if every question has a non-empty answer
        // for (var question in controller.questionList) {
        //   final answer = controller.answers[question.questionId];
        //
        //   // Check for null or empty string answers
        //   if (answer == null || (answer is String && answer.trim().isEmpty)) {
        //     formIsComplete = false;
        //     break;
        //   }
        // }
        //
        //
        // if (!formIsComplete) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text("Please fill out the entire survey form."), backgroundColor: Colors.red,),
        //   );
        //   return;
        // }
        // await controller.submitSurveyAnswers(context);
        // await controller.submitPhotos(context,  controller.remarkController.text.trim());

        if (canSubmit) {
          await controller.submitSurveyAnswers(context);
          await controller.submitPhotos(context, controller.remarkController.text.trim());
        } else {

          String message = "Please complete all steps before submitting.";

          if (!controller.isAttendanceMarked) {
            message = "Please mark your attendance.";
          } else if (!controller.allCategoriesHavePhotos) {
            message = "Please capture photos for all categories.";
          } else if (!controller.isSurveyComplete) {
            message = "Please fill out the entire survey form.";
          }
          else if (controller.remarkController.text.isEmpty) {
            message = "Please add a remark.";
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  InputDecoration _getDropdownDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.lato(color: AppColors.deepBlue),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }



}
