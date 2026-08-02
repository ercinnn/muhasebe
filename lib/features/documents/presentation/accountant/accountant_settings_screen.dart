import 'package:flutter/material.dart';

import '../../../../core/theme/glass_theme.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../clients/presentation/client_contact_info_screen.dart';
import '../../../settings/presentation/account_management_section.dart';
import '../../../settings/presentation/app_info_section.dart';

/// Accountant-side Ayarlar tab, split into two sub-tabs: account
/// management + app info, and per-client contact info (phone/address/
/// notes the app itself never asks clients for). Unlike the client
/// [SettingsScreen], there's no reminder-time preference here — payment
/// reminders are a client-only concept.
class AccountantSettingsScreen extends StatelessWidget {
  const AccountantSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: GlassSurface(
              padding: const EdgeInsets.all(4),
              borderRadius: BorderRadius.circular(999),
              child: TabBar(
                tabs: const [
                  Tab(text: 'Hesap'),
                  Tab(text: 'Mükellef Bilgileri'),
                ],
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: GlassStyle.secondaryTextColor,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    AccountManagementSection(),
                    SizedBox(height: 16),
                    AppInfoSection(),
                  ],
                ),
                const ClientContactInfoScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
