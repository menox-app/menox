import 'package:flutter/cupertino.dart';

class AppScaffold extends StatelessWidget {
  final ObstructingPreferredSizeWidget? navigationBar;
  final List<Widget> slivers;
  final ScrollController? controller;
  final Widget? child;

  const AppScaffold({
    super.key,
    this.navigationBar,
    this.slivers = const [],
    this.controller,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: navigationBar,
      child: child ??
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
          ),
    );
  }
}
