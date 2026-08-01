import 'package:flutter/material.dart';

import 'adaptive_scaffold.dart';
import 'gradient_background.dart';

/// The shell every role home screen (`AccountantHomeScreen`,
/// `ClientHomeScreen`) wraps its tab body in: transparent `AdaptiveScaffold`
/// + `AppBar` over a [GradientScaffoldBackground], with a logout action
/// always last. [appBarActions] lets a role insert extra actions (e.g. the
/// client's unread-mail badge) before the logout button.
///
/// The gradient wraps the whole [AdaptiveScaffold] (not just `body`) so it
/// paints behind the transparent `AppBar` too — nesting it inside `body`
/// only covers the area below the app bar, leaving the app bar on the
/// opaque page background where a white `foregroundColor` title/icons
/// become invisible (found via `design-lead` live review, 2026-08-01).
class RoleShellScaffold extends StatelessWidget {
  const RoleShellScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.title,
    required this.onLogout,
    required this.body,
    this.appBarActions = const [],
  });

  final List<AdaptiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final String title;
  final VoidCallback onLogout;
  final Widget body;
  final List<Widget> appBarActions;

  @override
  Widget build(BuildContext context) {
    return GradientScaffoldBackground(
      child: AdaptiveScaffold(
        destinations: destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            ...appBarActions,
            IconButton(icon: const Icon(Icons.logout), tooltip: 'Çıkış Yap', onPressed: onLogout),
          ],
        ),
        body: body,
      ),
    );
  }
}
