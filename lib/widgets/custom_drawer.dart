import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    _showLogoutDialog(context);
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Welcome back!",
            style: TextStyle(
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
      }) {
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
                  style: TextStyle(
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
          Text("v$appVersion", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}