import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AppErrorState extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final bool showHomeButton;
  final Object? error;

  const AppErrorState({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.showHomeButton = true,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    // Determine the error message
    String displayMessage =
        message ?? 'An unexpected error occurred. Please try again later.';
    if (error != null) {
      // In a real app, you'd have a helper to parse server errors
      displayMessage = error.toString();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with a subtle glow/background
            SizedBox(
              height: 250,
              child: SvgPicture.asset(
                'assets/illustrations/traffic.svg',
                fit: BoxFit.contain,
              ),
            ),
            // Title
            Text(
              title ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: theme.textTheme.textStyle.copyWith(
                fontSize: AppFontSizes.title,
                fontWeight: FontWeight.w700,
                color: ShadcnColors.foreground,              
              ),              
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.textStyle.copyWith(
                fontSize: AppFontSizes.bodySmall,
                color: ShadcnColors.mutedForeground,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            Column(
              spacing: 8,
              children: [
                if (onRetry != null)
                  AppButton(
                    text: 'Try Again',
                    onPressed: onRetry!,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.md,
                    width: 200,
                  ),
                if (showHomeButton)
                  AppButton(
                    text: 'Back to Home',
                    onPressed: () => context.go('/'),
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.md,
                    fullWidth: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
