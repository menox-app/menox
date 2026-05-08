import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/feedback/app_error_state.dart';
import 'package:flutter_core/core/ui/layout/safe_content_area.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        padding: AppSpacing.navigationBarPadding,
        middle: Text('Messages'),
        border: null,
        backgroundColor: ShadcnColors.background,
      ),
      child: SafeContentArea(
        child: AppErrorState(
          error:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
          onRetry: () {},
          showHomeButton: false,
        ),
      ),
    );
  }
}
