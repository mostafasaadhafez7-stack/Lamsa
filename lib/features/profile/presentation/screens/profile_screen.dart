import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:final_project/core/Token/token.dart';
import 'package:final_project/core/theme/app_colors.dart';
import 'package:final_project/core/theme/app_styles.dart';
import 'package:final_project/core/theme/theme_cubit.dart';
import 'package:final_project/features/auth/presentation/auth_cubit/auth_cubit.dart';
import 'package:final_project/features/auth/presentation/auth_cubit/auth_states.dart';
import 'package:final_project/features/auth/presentation/screens/login_screen.dart';
import 'package:final_project/features/home/presentation/screens/manage_product_screen.dart';
import 'package:final_project/features/profile/presentation/widgets/custom_profile_item.dart';
import 'package:final_project/features/profile/presentation/widgets/custom_profile_item_model.dart';
import 'package:final_project/features/settings/presentation/screens/settings_screen.dart';
import 'package:final_project/features/wishlist/presentation/screens/wishlist_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'LAMSA';
  String userEmail = 'lamsa@gmail.com';
  String? userPicture;
  File? _localImageFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedProfileData();
  }

  Future<void> _loadSavedProfileData() async {
    try {
      final savedPath = await storage.read(key: 'profile_image_path');
      if (savedPath != null && savedPath.isNotEmpty) {
        final file = File(savedPath);
        if (await file.exists()) {
          if (mounted) {
            setState(() {
              _localImageFile = file;
            });
          }
        }
      }

      final savedName = await storage.read(key: 'custom_user_name');
      if (savedName != null && savedName.trim().isNotEmpty) {
        if (mounted) {
          setState(() {
            userName = savedName.trim();
          });
        }
      }
    } catch (_) {}
  }

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(text: userName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bottomBackgroundClr,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.person_outline_rounded, color: AppColors.primaryClr),
              const SizedBox(width: 10),
              Text(
                'Edit Name',
                style: AppStyles.style18ExtraBold.copyWith(color: AppColors.textClr),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your username / display name:',
                  style: AppStyles.style14Regular.copyWith(color: AppColors.grayClr),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  style: TextStyle(color: AppColors.textClr),
                  decoration: InputDecoration(
                    hintText: 'Enter name',
                    hintStyle: TextStyle(color: AppColors.grayClr.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: AppColors.backgroundClr,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderSideClr),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryClr, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.grayClr),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryClr,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final newName = nameController.text.trim();
                  Navigator.pop(dialogContext);
                  setState(() {
                    userName = newName;
                  });
                  await storage.write(key: 'custom_user_name', value: newName);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Name updated successfully!'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF2E7D32),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ── Pick image from Camera or Gallery ────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close bottom sheet
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked == null) return;

      final file = File(picked.path);
      setState(() {
        _localImageFile = file;
      });

      await storage.write(key: 'profile_image_path', value: picked.path);
    } catch (e) {
      if (mounted) {
        final errorText = e.toString().contains('MissingPluginException')
            ? 'يرجى إيقاف التطبيق بالكامل وإعادة تشغيله (Full Restart / Rebuild) لتثبيت كود الكاميرا والمعرض.'
            : 'تعذر اختيار الصورة: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorText),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // ── Show source chooser bottom sheet ─────────────────────────────────────
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.bottomBackgroundClr,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.grayClr.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text(
              'Change Profile Photo',
              style: AppStyles.style16SemiBold.copyWith(color: AppColors.textClr),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Camera
                Expanded(
                  child: _SourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                // Gallery
                Expanded(
                  child: _SourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            if (_localImageFile != null || (userPicture != null && userPicture!.isNotEmpty)) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    _localImageFile = null;
                    userPicture = null;
                  });
                  await storage.delete(key: 'profile_image_path');
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  'Remove Photo',
                  style: AppStyles.style14SemiBold.copyWith(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<ProfileItemModel1> mylist1 = [
    ProfileItemModel1(
      title: 'My Orders',
      icon: Icons.shopping_bag_outlined,
      rightIcon: Icons.arrow_forward_ios,
    ),
    ProfileItemModel1(
      title: 'Wishlist',
      icon: Icons.favorite_border_rounded,
      rightIcon: Icons.arrow_forward_ios,
    ),
    ProfileItemModel1(
      title: 'Shipping Addresses',
      icon: Icons.location_on_outlined,
      rightIcon: Icons.arrow_forward_ios,
    ),
    ProfileItemModel1(
      title: 'Payment Methods',
      icon: Icons.credit_card,
      rightIcon: Icons.arrow_forward_ios,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit()..getCurrentUser(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          List<ProfileItemModel2> mylist2 = [
            ProfileItemModel2(
              title: 'Settings',
              icon: Icons.settings_outlined,
              rightIcon: Icons.arrow_forward_ios,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
                if (mounted) setState(() {});
              },
            ),
            ProfileItemModel2(
              title: 'Manage Products',
              icon: Icons.inventory_2,
              rightIcon: Icons.arrow_forward_ios,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageProductScreen(),
                  ),
                );
                if (mounted) setState(() {});
              },
            ),
            ProfileItemModel2(
              title: 'Help and Support',
              icon: Icons.help_outline_rounded,
              rightIcon: Icons.arrow_forward_ios,
            ),
          ];

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.backgroundClr,
              elevation: 0,
              title: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'MY PROFILE',
                  style: AppStyles.style20ExtraBold.copyWith(
                    color: AppColors.textClr,
                  ),
                ),
              ),
            ),
            backgroundColor: AppColors.backgroundClr,
            body: SafeArea(
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) async {
                  if (state is GetProfileSuccessState) {
                    final savedCustomName = await storage.read(key: 'custom_user_name');
                    if (mounted) {
                      setState(() {
                        if (savedCustomName != null && savedCustomName.trim().isNotEmpty) {
                          userName = savedCustomName.trim();
                        } else {
                          userName = state.user['fullName'] ?? 'LAMSA';
                        }
                        userEmail = state.user['email'] ?? 'lamsa@gmail.com';
                        userPicture = state.user['profilePicture'];
                      });
                    }
                  } else if (state is LogoutSuccessState) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => AuthCubit(),
                          child: const LoginScreen(),
                        ),
                      ),
                      (route) => false,
                    );
                  }
                },
                builder: (context, state) {
                  return RefreshIndicator(
                    color: AppColors.primaryClr,
                    onRefresh: () async {
                      await context.read<AuthCubit>().getCurrentUser();
                      await _loadSavedProfileData();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: _showImageSourceSheet,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 60.5,
                                      backgroundColor: AppColors.primaryClr.withValues(alpha: 0.1),
                                      backgroundImage: _localImageFile != null
                                          ? FileImage(_localImageFile!) as ImageProvider
                                          : (userPicture != null && userPicture!.isNotEmpty
                                              ? NetworkImage(userPicture!) as ImageProvider
                                              : const AssetImage('assets/images/logo.png')),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryClr,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.backgroundClr,
                                            width: 3,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.photo_camera,
                                          color: AppColors.bottomBackgroundClr,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: _showEditNameDialog,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          userName,
                                          style: AppStyles.style20ExtraBold.copyWith(
                                            color: AppColors.textClr,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryClr.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.edit_rounded,
                                          size: 16,
                                          color: AppColors.primaryClr,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: AppStyles.style14Regular.copyWith(
                                  color: AppColors.grayClr,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Card(
                            color: AppColors.profileCard,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: mylist1.length,
                              itemBuilder: (context, index) {
                                return CustomProfileItems(
                                  title: mylist1[index].title,
                                  icon: mylist1[index].icon,
                                  rightIcon: mylist1[index].rightIcon,
                                  onTap: () {
                                    if (mylist1[index].title == 'Wishlist') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const WishlistScreen(),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) {
                                return Divider(color: AppColors.borderSideClr);
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(),
                            child: Card(
                              color: AppColors.profileCard,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: mylist2.length,
                                itemBuilder: (context, index) {
                                  return CustomProfileItems(
                                    title: mylist2[index].title,
                                    icon: mylist2[index].icon,
                                    rightIcon: mylist2[index].rightIcon,
                                    color: AppColors.primaryClr,
                                    onTap: () {
                                      (mylist2[index].onTap ?? () {})();
                                    },
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) {
                                  return Divider(color: AppColors.borderSideClr);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Card(
                            color: AppColors.profileCard,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomProfileItems(
                                title: 'Log Out',
                                icon: Icons.logout,
                                color: AppColors.redClr,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Logout?'),
                                      content: const Text('Are you sure you want to logout?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dialogContext),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext);
                                            context.read<AuthCubit>().logout();
                                          },
                                          child: const Text(
                                            'Logout',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                );
              },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.backgroundClr,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSideClr),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.primaryClr),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppStyles.style14SemiBold.copyWith(color: AppColors.textClr),
            ),
          ],
        ),
      ),
    );
  }
}
