import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../controllers/screens_controller.dart';
import '../services/local_database.dart';
import '../utils/color_constants.dart';

class SchoolDrawer extends StatefulWidget {
  const SchoolDrawer({Key? key}) : super(key: key);

  @override
  State<SchoolDrawer> createState() => _SchoolDrawerState();
}

class _SchoolDrawerState extends State<SchoolDrawer> {
  String appVersion = "";
  LocalDatabase localDatabase = LocalDatabase();
  // final ScreenController screencontroller = ScreenController();

  @override
  void initState() {
    super.initState();
    _fetchAppDetails();
  }

  Future<void> _fetchAppDetails() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }
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
                final screenController = Provider.of<ScreenController>(context, listen: false);

                screenController.remarkController.clear();
                screenController.clearSelectedSite();
                screenController.capturedImages.clear();
                LocalDatabase().setLoginStatus("LoggedOut");
                LocalDatabase().setRole(0);
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

              },
              child:  Text("Logout", style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // A custom, more attractive header
          _buildHeader(context),
          // A spacer to push the items down
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Profile/Report section with a modern look
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.cloud_download,
                  title: "Generate Report",
                  onTap: () {
                    Navigator.pushNamed(context, '/report');
                  },
                ),
                // Custom divider
                _buildDrawerDivider(),
                // Logout button with a clear, warning color
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  onTap: () {
                    _logoutUser(context);
                  },
                  isLogout: true, // A flag to style the logout button differently
                ),
              ],
            ),
          ),
          // A cleaner, more subtle footer
          _buildFooter(),
        ],
      ),
    );
  }

  // Refactored header with a gradient and centered content
  Widget _buildHeader(BuildContext context) {
    final userName = LocalDatabase().userName ?? "Guest";
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.shade800,
            Colors.teal.shade400,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Larger, more prominent avatar
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 40,
            child: Icon(Icons.person_rounded, color: Colors.teal, size: 48),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style:  GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
           Text(
            "Welcome back!",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Refactored menu item with a hover effect for better user feedback
  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        bool isLogout = false, // Added a flag for special styling
      })
  {
    // Define colors based on whether it's the logout button
    final color = isLogout ? Colors.red.shade700 : ColorConstants().teal;
    final iconColor = isLogout ? Colors.red.shade700 : ColorConstants().teal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // A custom divider with better spacing
  Widget _buildDrawerDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Colors.grey, height: 1),
    );
  }

  // Refactored footer for a cleaner look
  Widget _buildFooter() {
     return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [

          const SizedBox(height: 4),
          Text("v$appVersion", style:  GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }

}




class AdminDrawer extends StatefulWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  String appVersion = "";
  LocalDatabase localDatabase = LocalDatabase();
  // final ScreenController screencontroller = ScreenController();

  @override
  void initState() {
    super.initState();
    _fetchAppDetails();
  }

  Future<void> _fetchAppDetails() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }
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
                LocalDatabase().setLoginStatus("LoggedOut");
                LocalDatabase().setRole(0);
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

              },
              child:  Text("Logout", style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          // Custom Drawer Header with a Gradient
          Container(

            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            decoration:  BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryTeal, AppColors.tealAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/cg.png'), // Your profile image
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin User', // Display the user's name
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

              ],
            ),
          ),
          // Navigation items
          ListTile(
            leading: const Icon(Icons.dashboard_rounded, color: AppColors.primaryTeal),
            title: Text(
              'Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerDivider(),
          ListTile(
            leading: const Icon(Icons.person_rounded, color: AppColors.primaryTeal),
            title: Text(
              'Officer Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/officerList');
              // Navigate to profile screen
            },
          ),
          _buildDrawerDivider(),
          ListTile(
            leading: const Icon(Icons.home_work, color: AppColors.primaryTeal),
            title: Text(
              'Hostel Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/hostelList');
            },
          ),
          _buildDrawerDivider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.redAccent,
              ),
            ),
            onTap: () {
              _logoutUser(context);

            },
          ),
          const Spacer(), // Pushes the logout button to the bottom

          _buildFooter()
        ],
      ),
    );
  }

  Widget _buildDrawerDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Colors.grey, height: 1),
    );
  }

  // Refactored footer for a cleaner look
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [

          const SizedBox(height: 4),
          Text("v$appVersion", style:  GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }


}