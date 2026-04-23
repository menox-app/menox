import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Activity'),
        border: null,
        backgroundColor: ShadcnColors.background,
      ),
      child: SafeArea(
        child: Center(
          child: Text('Activity Page Placeholder'),
        ),
      ),
    );
  }
}
