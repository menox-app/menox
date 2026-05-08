import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/layout/safe_content_area.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: AppSpacing.navigationBarPadding,
        middle: Text('Activity'),
        border: null,
        backgroundColor: ShadcnColors.background,
      ),
      child: SafeContentArea(
        child: Center(child: Text('Activity Page Placeholder')),
      ),
    );
  }
}
