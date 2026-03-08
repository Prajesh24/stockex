import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stockex/core/utils/snackbar_utils.dart';
import 'package:stockex/features/auth/presentation/pages/login_page.dart';
import 'package:stockex/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:stockex/features/portfolio/presentation/pages/portfolio_summary_page.dart';
import 'package:stockex/features/update/presentation/state/update_state.dart';
import 'package:stockex/features/update/presentation/view_model/update_view_model.dart';
import 'package:stockex/features/update/presentation/pages/edit_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockex/features/watchlist/presentation/pages/watchlist_page.dart';
import 'package:stockex/screen/bottom_screen/home.dart';
import 'package:stockex/screen/bottom_screen/watchlist.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImage');
    if (imagePath != null) {
      setState(() {
        _profileImage = XFile(imagePath);
      });
    }
  }

  Future<void> _saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', path);
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
                SnackbarUtils.showSuccess(context, 'Logged out successfully');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      status = await Permission.camera.request();
      return status.isGranted;
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return false;
    }
    return false;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Camera Permission Required"),
        content: const Text(
          "To take profile pictures, please grant camera permission in settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() => _profileImage = photo);
      _saveProfileImage(photo.path);

      await ref
          .read(updateViewModelProvider.notifier)
          .uploadProfilePicture(imagePath: photo.path);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _profileImage = image);
        _saveProfileImage(image.path);

        await ref
            .read(updateViewModelProvider.notifier)
            .uploadProfilePicture(imagePath: image.path);
      }
    } catch (e) {
      debugPrint("Error picking image from gallery: $e");
      if (mounted) {
        SnackbarUtils.showError(
          context,
          "Failed to pick image from gallery. Please try camera instead.",
        );
      }
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Open Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Open Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen(updateViewModelProvider, (previous, next) {
      if (previous?.status != next.status &&
          next.status == UpdateStatus.error &&
          next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with profile image
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.grey,
                        backgroundImage: _profileImage != null
                            ? FileImage(File(_profileImage!.path))
                            : null,
                        child: _profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 52,
                                color: Colors.black,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.black,
                            ),
                            onPressed: _pickMedia,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authState.authEntity?.name ?? "User Name",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authState.authEntity?.email ?? "user@email.com",
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Section - Only Edit Profile
            _sectionTitle("Account"),
            _menuItem(
              icon: Icons.edit_outlined,
              title: "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            // Portfolio Section - Portfolio Summary & Watchlist
            _sectionTitle("Portfolio"),
            _menuItem(
              icon: Icons.pie_chart_outline,
              title: "Portfolio Summary",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PortfolioSummaryPage(),
                  ),
                );
              },
            ),
            _menuItem(
              icon: Icons.star_outline,
              title: "Watchlist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WatchlistPage()),
                );
              },
            ),

            const SizedBox(height: 20),

            // Market Section - NEW
            _sectionTitle("Market"),
            _menuItem(
              icon: Icons.trending_up_outlined,
              title: "Market",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),

            const SizedBox(height: 30),

            // Logout
            _menuItem(
              icon: Icons.logout,
              title: "Logout",
              isLogout: true,
              onTap: _logout,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isLogout ? Colors.redAccent : Colors.white,
          ),
          title: Text(
            title,
            style: TextStyle(color: isLogout ? Colors.redAccent : Colors.white),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
          onTap: onTap,
        ),
      ),
    );
  }
}
