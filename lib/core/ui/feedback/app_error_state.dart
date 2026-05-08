import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/controls/app_button.dart';
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

    String displayMessage =
        message ?? 'An unexpected error occurred. Please try again later.';
    if (error != null) {
      displayMessage = _formatErrorMessage(error!);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final isConstrained = maxHeight.isFinite;
        final isCompact = isConstrained && maxHeight < 620;
        final illustrationHeight = isConstrained
            ? (maxHeight * 0.32).clamp(140.0, 220.0)
            : 220.0;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isConstrained ? maxHeight : 0,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  40,
                  isCompact ? 24 : 32,
                  40,
                  isCompact ? 24 : 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: illustrationHeight,
                      child: SvgPicture.asset(
                        'assets/illustrations/traffic.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: isCompact ? 20 : 28),
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
                    Text(
                      displayMessage,
                      textAlign: TextAlign.center,
                      maxLines: isCompact ? 4 : 6,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.textStyle.copyWith(
                        fontSize: AppFontSizes.bodySmall,
                        color: ShadcnColors.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: isCompact ? 24 : 32),
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
                            width: 200,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'The server took too long to respond. Please try again.';
        case DioExceptionType.connectionError:
          return 'Unable to connect. Please check your connection and try again.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            return 'Request failed with status code $statusCode.';
          }
          return 'The server returned an error. Please try again.';
        case DioExceptionType.cancel:
          return 'The request was cancelled. Please try again.';
        case DioExceptionType.badCertificate:
          return 'Unable to verify the server connection.';
        case DioExceptionType.unknown:
          return 'Something went wrong. Please try again.';
      }
    }

    return error.toString();
  }
}
