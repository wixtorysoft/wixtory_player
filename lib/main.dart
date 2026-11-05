import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/tiktok_feed_screen.dart';
import 'state/video_feed_provider.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoFeedProvider()),
      ],
      child: const WixtoryPlayerApp(),
    ),
  );
}

class WixtoryPlayerApp extends StatelessWidget {
  const WixtoryPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wixtory Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const TikTokFeedScreen(),
    );
  }
}
