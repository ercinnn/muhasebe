import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_card.dart';
import 'privacy_policy_dialog.dart';

/// Shown at the bottom of every role's Ayarlar screen: app version and
/// developer contact — required for Play Store account-deletion discovery
/// and generally useful for support requests.
class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              final version =
                  info == null ? '—' : '${info.version} (${info.buildNumber})';
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Uygulama sürümü'),
                subtitle: Text(version),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Destek / iletişim'),
            subtitle: Text(
              'cakalogluer@gmail.com',
              style: TextStyle(color: GlassStyle.secondaryTextColor),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Gizlilik Politikası'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showPrivacyPolicyDialog(context),
          ),
        ],
      ),
    );
  }
}
