import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import '../../utils/color_constants.dart';
import '../controllers/screens_controller.dart';
import '../services/local_database.dart';
import '../widgets/custom_drawer.dart';
import 'captured_gallery_screen.dart';

// PhotoCategory class and other dependencies from your original code are assumed to exist.
// This example focuses on the Dashboard UI.

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final LocalDatabase localDatabase = LocalDatabase();
  final TextEditingController _remarkController = TextEditingController();
  Future<void> _fetchBlock() async {
    return await context.read<ScreenController>().fetchBlock(
      context: context,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchBlock();
    });
  }
  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the body to extend behind the app bar for a unified look
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove the shadow
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _logoutUser(context),
          ),
        ],
      ),
      drawer: const SchoolDrawer(), // Assuming this is the new, attractive drawer
      body: Consumer<ScreenController>(
        builder: (context, controller, child) {
          return ModalProgressHUD(
            inAsyncCall: controller.isLoading,
            progressIndicator: CircularProgressIndicator(
              color: ColorConstants().teal,
            ),
            child: Stack(
              children: [
                // Top gradient background container
                Container(
                  height: 300,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // User info section
                        _buildUserInfoSection(context),
                        const SizedBox(height: 40),

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

  /// Builds the user info section at the top of the screen
  Widget _buildUserInfoSection(BuildContext context) {
    return Row(
      children: [
        // User avatar with a subtle shadow
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
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_rounded, color: Colors.teal, size: 30),
          ),
        ),
        const SizedBox(width: 16),
        // User greeting
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${localDatabase.userName ?? 'User'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Ready for your survey?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the main card containing dropdowns and actions
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
            // Dropdown for selecting block
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

            // Dropdown for selecting site
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

            /// Conditional UI based on site selection
            if (controller.selectedSiteName != null) ...[
              _buildAttendanceSection(context, controller),
              const SizedBox(height: 24),
              if (controller.isAttendanceMarked) ...[
                _photoCategoriesGrid(context, controller),
                const SizedBox(height: 24),
                if (controller.allCategoriesHavePhotos) ...[
                  TextFormField(
                    controller: _remarkController,
                    decoration: _getDropdownDecoration(context, "Add Remarks").copyWith(
                      prefixIcon: const Icon(Icons.edit_note, color: Colors.teal),
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    onChanged: (_) => setState(() {}), // Rebuild to check if remark is filled
                  ),
                  const SizedBox(height: 24),

                  // Show submit button only if remark is not empty
                  if (_remarkController.text.trim().isNotEmpty)
                    _buildSubmitButton(context, controller),
                ],
              ] else ...[
                // Spacer for when the button is not there, to maintain layout
                const SizedBox(height: 20),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the attendance status section
  Widget _buildAttendanceSection(BuildContext context, ScreenController controller) {
    return Column(
      children: [
        Icon(
          controller.isAttendanceMarked ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: 60,
          color: controller.isAttendanceMarked ? Colors.green : ColorConstants().teal,
        ),
        const SizedBox(height: 16),
        Text(
          controller.isAttendanceMarked
              ? 'Attendance Marked!'
              : 'Site Selected: ${controller.selectedSiteName}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          controller.isAttendanceMarked
              ? 'You can now proceed with taking photos.'
              : 'Tap below to mark your attendance for ${controller.selectedSiteName}.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 24),
        if (!controller.isAttendanceMarked)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants().teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              elevation: 5,
            ),
            onPressed: () => controller.markAttendance(
              context,
              controller.selectedSite?.hostelID ?? '',
              controller.selectedSiteName ?? '',
            ),
            icon: const Icon(Icons.location_on_rounded),
            label: const Text('Mark Attendance', style: TextStyle(fontSize: 16)),
          ),
      ],
    );
  }

  /// Builds the grid of photo categories
  Widget _photoCategoriesGrid(BuildContext context, ScreenController controller) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: controller.photoCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemBuilder: (context, index) {
        final category = controller.photoCategories[index];
        final images = controller.capturedImages[category.name] ?? [];
        return InkWell(
          onTap: () {
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
          },
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                images.isNotEmpty
                    ? Image.file(images.last,
                    width: 80, height: 80, fit: BoxFit.cover)
                    : Icon(category.icon, size: 48, color: ColorConstants().teal),
                const SizedBox(height: 8),
                Text(category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (images.isNotEmpty)
                  Text("${images.length} photo(s)",
                      style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the submit button
  Widget _buildSubmitButton(BuildContext context, ScreenController controller) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 5,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      icon: const Icon(Icons.cloud_upload),
      label: const Text("Submit Photos"),
      onPressed: () async {
        if (controller.capturedImages.isEmpty ||
            controller.capturedImages.values.every((list) => list.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please capture at least one photo.")),
          );
          return;


        }
        await controller.submitPhotos(context,  _remarkController.text.trim());

      },
    );
  }

  /// Helper function for consistent dropdown decoration
  InputDecoration _getDropdownDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: ColorConstants().teal),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: ColorConstants().teal, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  /// Shows the logout confirmation dialog
  void _logoutUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Logout"),
          content: const Text("Do you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                LocalDatabase().setLoginStatus("LoggedOut");
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
