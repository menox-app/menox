import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Messages'),
        border: null,
        backgroundColor: ShadcnColors.background,
      ),
      child: SafeArea(
        child: Center(
          child: Text('Messages Page Placeholder'),
        ),
      ),
    );
  }
}
