import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/core/apis/app/index.dart';
import 'package:flutter_core/core/apis/app/interfaces/user.dart';
import 'package:flutter_core/core/hooks/use_auth.dart';
import 'package:flutter_core/core/ui/widgets/app_bottom_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainScreen extends HookConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = useAuth(ref);
    final apiClient = ref.watch(apiClientProvider);

    // Bootstrapper: This query runs globally in the shell to keep the Store in sync
    final query = useQuery<User, dynamic>(const ['auth', 'me'], (
      context,
    ) async {
      final response = await apiClient.auth.getMe();
      final user = response.data;

      // Enrich with high-fidelity mock data if fields are missing
      return User(
        id: user.id,
        email: user.email,
        username: user.username,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl ?? 'https://i.pravatar.cc/300?u=${user.id}',
        bannerUrl:
            user.bannerUrl ??
            'https://images.unsplash.com/photo-1614850523296-d8c1af93d400?q=80&w=2070&auto=format&fit=crop',
        bio:
            user.bio ??
            'Designer → Product Thinker\nI love clean lines and clear ideas\nMoscow → Berlin',
        bioQuote: user.bioQuote ?? 'I create. I think. I develop.',
        followersCount: user.followersCount > 0 ? user.followersCount : 1200,
        followingCount: user.followingCount > 0 ? user.followingCount : 287,
        postsCount: user.postsCount > 0 ? user.postsCount : 47,
        activityLevel: user.activityLevel != 'Normal'
            ? user.activityLevel
            : 'High',
        tags: user.tags.isNotEmpty
            ? user.tags
            : ['#Minimalism', '#DesignThinking', '#Photography'],
      );
    });

    // Sync Query data to our custom Auth Hook / Store
    useEffect(() {
      if (query.data != null) {
        // We wrap this in microtask to avoid "modifying provider while building" error
        Future.microtask(() => auth.setUser(query.data));
      }
      return null;
    }, [query.data]);

    int getCurrentUIIndex() {
      final branchIndex = navigationShell.currentIndex;
      if (branchIndex >= 2) return branchIndex + 1;
      return branchIndex;
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Global Padding Configuration via MediaQuery override
          // This tells all child pages that the "Safe Area" at the bottom is extended
          // to account for our floating bar, while still allowing content to scroll behind it.
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
                    // Map UI index back to Branch index
                    int branchIndex = index;
                    if (index > 2) branchIndex = index - 1;
                    navigationShell.goBranch(branchIndex);
                  },
                  onCreatePressed: () => _showCreatePostMenu(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostMenu(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Create New'),
        message: const Text('Choose what you want to share with the world.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo_on_rectangle),
                SizedBox(width: 10),
                Text('Image Post'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.text_quote),
                SizedBox(width: 10),
                Text('Text/Meme Post'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
