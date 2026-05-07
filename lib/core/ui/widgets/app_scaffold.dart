import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/ui/widgets/app_error_state.dart';

class AppScaffold extends StatelessWidget {
  final ObstructingPreferredSizeWidget? navigationBar;
  final List<Widget> slivers;
  final ScrollController? controller;
  final Widget? child;
  final Object? error;
  final VoidCallback? onRetry;

  const AppScaffold({
    super.key,
    this.navigationBar,
    this.slivers = const [],
    this.controller,
    this.child,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: navigationBar,
      child: error != null
          ? AppErrorState(
              error: error,
              onRetry: onRetry,
            )
          : (child ??
          CustomScrollView(
            controller: controller,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              ...slivers,
              // Global bottom padding for the floating nav bar
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ),
            ],
          )),
    );
  }
}
