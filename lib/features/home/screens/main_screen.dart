import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/core/ui/layout/app_bottom_bar.dart';
import 'package:flutter_core/features/post/widgets/create_post_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int getCurrentUIIndex() {
      final branchIndex = navigationShell.currentIndex;
      if (branchIndex >= 2) return branchIndex + 1;
      return branchIndex;
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: MediaQuery.of(context).padding.copyWith(
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
            ),
            child: navigationShell,
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 10,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: AppBottomBar(
                  selectedIndex: getCurrentUIIndex(),
                  onItemSelected: (index) {
                    HapticFeedback.lightImpact();
                    int branchIndex = index;
                    if (index > 2) branchIndex = index - 1;
                    navigationShell.goBranch(branchIndex);
                  },
                  onCreatePressed: () => showCreatePostSheet(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
