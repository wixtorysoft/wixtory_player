import 'dart:ui';
import 'package:flutter/material.dart';
import '../localization/app_strings.dart';

class MediaImportingHud extends StatefulWidget {
  final String statusMessage;
  final String language;

  const MediaImportingHud({
    Key? key,
    required this.statusMessage,
    required this.language,
  }) : super(key: key);

  @override
  State<MediaImportingHud> createState() => _MediaImportingHudState();
}

class _MediaImportingHudState extends State<MediaImportingHud>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.statusMessage.isNotEmpty
        ? widget.statusMessage
        : AppStrings.get('loading_files', widget.language);

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            color: Colors.black.withOpacity(0.68),
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final glow = _pulseAnimation.value * 12.0;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF130E24).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: const Color(0xFF00F2FE).withOpacity(0.35 + (_pulseAnimation.value * 0.35)),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F2FE).withOpacity(0.18),
                          blurRadius: 28 + glow,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: const Color(0xFFFF2A54).withOpacity(0.12),
                          blurRadius: 36,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Glowing Spinner
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 68,
                              height: 68,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.6,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF00F2FE),
                                ),
                                backgroundColor: const Color(0xFFFF2A54).withOpacity(0.2),
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00F2FE), Color(0xFFFF2A54)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00F2FE).withOpacity(0.4),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.video_library_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Title / Status Message
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          AppStrings.get('please_wait', widget.language),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

