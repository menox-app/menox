import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_error_state.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Messages'),
        border: null,
        backgroundColor: ShadcnColors.background,
      ),
      child: SafeArea(
        child: AppErrorState(
          error: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
          onRetry: () {},
          showHomeButton: false,
        ),
      ),
    );
  }
}
