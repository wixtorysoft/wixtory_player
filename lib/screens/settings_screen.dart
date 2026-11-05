import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../state/video_feed_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoFeedProvider>(
      builder: (context, provider, _) {
        final lang = provider.currentLanguage;

        return Scaffold(
          backgroundColor: const Color(0xFF0B0813),
          body: Stack(
            children: [
              // Ambient Background Glows
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00F2FE).withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                left: -80,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF2A54).withOpacity(0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content Body
              SafeArea(
                child: Column(
                  children: [
                    // Top App Bar
                    _buildAppBar(context, lang),

                    // Scrollable Sections
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        children: [
                          // Language Section
                          _buildSectionHeader(
                            title: AppStrings.get('language', lang),
                            icon: Icons.language_rounded,
                            accentColor: const Color(0xFF00F2FE),
                          ),
                          const SizedBox(height: 12),
                          _buildLanguageSelector(context, provider, lang),
                          const SizedBox(height: 28),

                          // About Section
                          _buildSectionHeader(
                            title: AppStrings.get('about', lang),
                            icon: Icons.info_outline_rounded,
                            accentColor: const Color(0xFFFF2A54),
                          ),
                          const SizedBox(height: 12),
                          _buildAboutCard(lang),
                          const SizedBox(height: 28),

                          // Storage & Cache Section
                          _buildSectionHeader(
                            title: AppStrings.get('storage_cache', lang),
                            icon: Icons.cleaning_services_rounded,
                            accentColor: const Color(0xFF9D4EDD),
                          ),
                          const SizedBox(height: 12),
                          _buildStorageCard(context, provider, lang),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TOP BAR ---
  Widget _buildAppBar(BuildContext context, String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF130E24).withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Sleek Back Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              AppStrings.get('settings', lang),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTION HEADER ---
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: accentColor.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Icon(icon, color: accentColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // --- LANGUAGE SELECTOR (5 LANGUAGES: TR, EN, DE, IT, FR) ---
  Widget _buildLanguageSelector(
    BuildContext context,
    VideoFeedProvider provider,
    String currentLang,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF130E24).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: AppStrings.supportedLanguages.asMap().entries.map((entry) {
          final index = entry.key;
          final code = entry.value;
          final isSelected = currentLang == code;
          final isLast = index == AppStrings.supportedLanguages.length - 1;

          final flag = AppStrings.languageFlags[code] ?? '🌐';
          final name = AppStrings.languageNames[code] ?? code.toUpperCase();

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.setLanguage(code);
                  },
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(20) : Radius.zero,
                    bottom: isLast ? const Radius.circular(20) : Radius.zero,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: isSelected
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF00F2FE).withOpacity(0.15),
                                const Color(0xFF4FACFE).withOpacity(0.05),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          )
                        : null,
                    child: Row(
                      children: [
                        Text(
                          flag,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF00F2FE)
                                  : Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00F2FE)
                                  : Colors.white.withOpacity(0.2),
                              width: isSelected ? 2 : 1.5,
                            ),
                            color: isSelected
                                ? const Color(0xFF00F2FE)
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Color(0xFF0B0813),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: 54,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // --- ABOUT SECTION CARD ---
  Widget _buildAboutCard(String lang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF130E24).withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00F2FE), Color(0xFFFF2A54)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F2FE).withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('app_title', lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${AppStrings.get('version', lang)} 1.0.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            AppStrings.get('about_description', lang),
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          // Privacy Highlight Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF00F2FE).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00F2FE).withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.security_rounded,
                  color: Color(0xFF00F2FE),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.get('privacy_guarantee', lang),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Developer Credit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get('developer', lang),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 12.5,
                ),
              ),
              const Text(
                'Wixtory Technologies',
                style: TextStyle(
                  color: Color(0xFF00F2FE),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- STORAGE & CACHE SECTION ---
  Widget _buildStorageCard(
    BuildContext context,
    VideoFeedProvider provider,
    String lang,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF130E24).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get('media_library', lang),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${provider.allItems.length} ${AppStrings.get('items', lang)}',
                  style: const TextStyle(
                    color: Color(0xFF00F2FE),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Clear Cache Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _confirmClearCache(context, provider, lang),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2A54).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFF2A54).withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete_sweep_rounded,
                      color: Color(0xFFFF2A54),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.get('clear_cache', lang),
                      style: const TextStyle(
                        color: Color(0xFFFF2A54),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONFIRM CLEAR CACHE DIALOG ---
  void _confirmClearCache(
    BuildContext context,
    VideoFeedProvider provider,
    String lang,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF130E24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          title: Text(
            AppStrings.get('clear_cache', lang),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            AppStrings.get('clear_cache_confirm', lang),
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                AppStrings.get('cancel', lang),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await provider.clearAllCache();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppStrings.get('cache_cleared', lang),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF130E24),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color(0xFF00F2FE).withOpacity(0.4),
                        ),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2A54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppStrings.get('delete', lang),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

