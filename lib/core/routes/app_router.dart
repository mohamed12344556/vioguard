import 'package:flutter/material.dart';
import 'routes.dart';
import '../../features/home/views/dashboard_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/detection/views/text_detection_screen.dart';
import '../../features/detection/views/text_detection_result_screen.dart';
import '../../features/detection/views/video_detection_screen.dart';
import '../../features/detection/views/video_detection_result_screen.dart';
import '../../features/history/views/detection_details_screen.dart';
import '../../features/history/models/detection_history_item.dart';
import '../../features/profile/views/edit_profile_screen.dart';
import '../../features/profile/views/change_password_screen.dart';
import '../../features/profile/views/settings_screen.dart';

/// Application Router
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return _buildRoute(const LoginPage(), settings);
      case Routes.register:
        return _buildRoute(const SignUpPage(), settings);
      case Routes.forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);
      case Routes.resetPassword:
        return _buildRoute(const ResetPasswordPage(), settings);
      case Routes.home:
      case Routes.dashboard:
        return _buildRoute(const DashboardScreen(), settings);
      case Routes.textDetection:
        return _buildRoute(const TextDetectionScreen(), settings);
      case Routes.textDetectionResult:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          TextDetectionResultScreen(
            analyzedText: args?['text'] ?? '',
            isViolent: args?['isViolent'] ?? false,
            highlightedWords: args?['highlightedWords'] as List<String>?,
          ),
          settings,
        );
      case Routes.videoDetection:
        return _buildRoute(const VideoDetectionScreen(), settings);
      case Routes.videoDetectionResult:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          VideoDetectionResultScreen(
            videoPath: args?['videoPath'],
            isViolent: args?['isViolent'] ?? false,
            thumbnailPath: args?['thumbnailPath'],
          ),
          settings,
        );
      case Routes.detectionDetails:
        final item = settings.arguments as DetectionHistoryItem;
        return _buildRoute(
          DetectionDetailsScreen(item: item),
          settings,
        );
      case Routes.editProfile:
        return _buildRoute(const EditProfileScreen(), settings);
      case Routes.changePassword:
        return _buildRoute(const ChangePasswordScreen(), settings);
      case Routes.settings:
        return _buildRoute(const SettingsScreen(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
