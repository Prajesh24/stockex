import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stockex/core/utils/snackbar_utils.dart';
import 'package:stockex/features/update/presentation/view_model/update_view_model.dart';
import 'package:stockex/screen/edit_profile_screen.dart';

class ProfileScreenCleanArchitecture extends ConsumerStatefulWidget {
  const ProfileScreenCleanArchitecture({super.key});

  @override
  ConsumerState<ProfileScreenCleanArchitecture> createState() =>
      _ProfileScreenCleanArchitectureState();
}

class _ProfileScreenCleanArchitectureState
    extends ConsumerState<ProfileScreenCleanArchitecture> {
  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load user profile when screen initializes
    Future.microtask(() {
      ref.read(updateViewModelProvider.notifier).getUserProfile();
    });
  }

  // Request camera permission
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

  // Pick image from camera
  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _profileImage = photo;
      });
      // Upload the picture using the view model
      if (mounted) {
        ref
            .read(updateViewModelProvider.notifier)
            .uploadProfilePicture(imagePath: photo.path);
      }
    }
  }

  // Pick image from gallery
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = image;
        });
        // Upload the picture using the view model
        if (mounted) {
          ref
              .read(updateViewModelProvider.notifier)
              .uploadProfilePicture(imagePath: image.path);
        }
      }
    } catch (e) {
      debugPrint("Error picking image from gallery: $e");
      if (mounted) {
        SnackbarUtils.showError(
          context,
          "Failed to pick image from gallery. Please use camera.",
        );
      }
    }
  }

  // Show media picker dialog
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
    // Watch the update state
    final updateState = ref.watch(updateViewModelProvider);

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
            // 🔹 HEADER
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
                  // 🔹 Profile Image with Add Button
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.grey,
                        backgroundImage: _profileImage != null
                            ? FileImage(File(_profileImage!.path))
                            : updateState.profileEntity?.profilePicture != null
                                ? NetworkImage(
                                    updateState.profileEntity!.profilePicture!)
                                : null,
                        child: (_profileImage == null &&
                                updateState.profileEntity?.profilePicture ==
                                    null)
                            ? const Icon(
                                Icons.person,
                                size: 52,
                                color: Colors.black,
                              )
                            : null,
                      ),
                      if (updateState.isLoading)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
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
                    updateState.profileEntity?.fullName ?? "User Name",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    updateState.profileEntity?.email ?? "user@email.com",
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 🔹 ACCOUNT
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
            _menuItem(
              icon: Icons.security_outlined,
              title: "Security & Privacy",
              onTap: () {},
            ),
            const SizedBox(height: 20),
            // 🔹 PORTFOLIO
            _sectionTitle("Portfolio"),
            _menuItem(
              icon: Icons.pie_chart_outline,
              title: "Portfolio Summary",
              onTap: () {},
            ),
            _menuItem(
              icon: Icons.star_outline,
              title: "Watchlist",
              onTap: () {},
            ),
            _menuItem(
              icon: Icons.trending_up_outlined,
              title: "Investment Preferences",
              onTap: () {},
            ),
            const SizedBox(height: 20),
            // 🔹 APP
            _sectionTitle("App"),
            _menuItem(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              onTap: () {},
            ),
            _menuItem(
              icon: Icons.settings_outlined,
              title: "App Settings",
              onTap: () {},
            ),
            const SizedBox(height: 30),
            // 🔹 LOGOUT
            _menuItem(
              icon: Icons.logout,
              title: "Logout",
              isLogout: true,
              onTap: () {},
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
