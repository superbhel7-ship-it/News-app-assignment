import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  String _email = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = await Hive.openBox('profile');
    final authState = ref.read(authProvider);
    setState(() {
      _nameController.text = box.get('name', defaultValue: '') as String;
      _bioController.text = box.get('bio', defaultValue: '') as String;
      _email = authState.email ?? '';
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final box = await Hive.openBox('profile');
    await box.put('name', _nameController.text.trim());
    await box.put('bio', _bioController.text.trim());
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully'),
          backgroundColor: AppTheme.successColor.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : const Color(0xFFF2F2F7);
    final surfaceColor = isDark ? AppTheme.surface : Colors.white;
    final textColor = isDark ? AppTheme.textPrimary : const Color(0xFF1C1C1E);
    final secondaryText = isDark ? AppTheme.textSecondary : const Color(0xFF8E8E93);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primary,
                          AppTheme.primary.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        (_nameController.text.isNotEmpty
                                ? _nameController.text[0]
                                : _email.isNotEmpty
                                    ? _email[0]
                                    : 'U')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Change Photo',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name field
            _buildLabel('NAME', secondaryText),
            const SizedBox(height: 8),
            _buildGlassField(
              controller: _nameController,
              hint: 'Enter your name',
              icon: Icons.person_outline,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textColor: textColor,
              secondaryText: secondaryText,
            ),
            const SizedBox(height: 24),

            // Email field
            _buildLabel('EMAIL', secondaryText),
            const SizedBox(height: 8),
            _buildGlassField(
              controller: TextEditingController(text: _email),
              hint: 'Email',
              icon: Icons.email_outlined,
              readOnly: true,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textColor: textColor,
              secondaryText: secondaryText,
            ),
            const SizedBox(height: 24),

            // Bio field
            _buildLabel('BIO', secondaryText),
            const SizedBox(height: 8),
            _buildGlassField(
              controller: _bioController,
              hint: 'Tell us about yourself',
              icon: Icons.edit_note,
              maxLines: 4,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textColor: textColor,
              secondaryText: secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? surfaceColor.withValues(alpha: 0.6)
                : surfaceColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            style: TextStyle(color: readOnly ? secondaryText : textColor, fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: secondaryText, size: 22),
              hintText: hint,
              hintStyle: TextStyle(color: secondaryText.withValues(alpha: 0.6)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}
