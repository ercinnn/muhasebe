import 'package:flutter/material.dart';

import '../theme/breakpoints.dart';

class AdaptiveDestination {
  const AdaptiveDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// NavigationRail (web/wide) vs NavigationBar (mobile/narrow), switching at
/// [Breakpoints.rail]. Mirrors the plan's "NavigationRail + çok sütunlu
/// düzen (web) / BottomNavigationBar (mobil)" requirement — NavigationBar is
/// Material 3's current equivalent of BottomNavigationBar.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.railTrailing,
    this.backgroundColor,
  });

  final List<AdaptiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? railTrailing;

  /// Left null, `Scaffold` uses its normal opaque default — pass e.g.
  /// `Colors.transparent` when [body] already paints its own background
  /// (a gradient wrapper).
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= Breakpoints.rail;

    if (isWide) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              trailing: railTrailing == null
                  ? null
                  : Expanded(
                      child: Align(alignment: Alignment.bottomCenter, child: railTrailing),
                    ),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final d in destinations) NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }
}
