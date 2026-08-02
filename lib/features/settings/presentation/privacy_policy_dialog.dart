import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const _privacyPolicyUrl = 'https://tahakkukfisi.com/privacy.html';

/// Shows the live content of [_privacyPolicyUrl] inside an in-app dialog
/// instead of handing off to an external browser.
Future<void> showPrivacyPolicyDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const _PrivacyPolicyDialog(),
  );
}

class _PrivacyPolicyDialog extends StatefulWidget {
  const _PrivacyPolicyDialog();

  @override
  State<_PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<_PrivacyPolicyDialog> {
  late final Future<List<dom.Node>> _bodyNodes = _load();

  Future<List<dom.Node>> _load() async {
    final response = await http.get(Uri.parse(_privacyPolicyUrl));
    if (response.statusCode != 200) {
      throw Exception('Beklenmeyen durum kodu: ${response.statusCode}');
    }
    final document = html_parser.parse(utf8.decode(response.bodyBytes));
    return document.body?.nodes ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gizlilik Politikası',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Kapat',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: FutureBuilder<List<dom.Node>>(
                future: _bodyNodes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off, size: 32),
                          const SizedBox(height: 12),
                          Text(
                            'Gizlilik politikası yüklenemedi. İnternet '
                            'bağlantınızı kontrol edip tekrar deneyin.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }
                  final nodes = snapshot.data!;
                  return Scrollbar(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final node in nodes) ..._buildBlock(context, node),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Converts a top-level HTML node into zero or more block-level widgets.
/// Only the small tag set used by privacy.html (h1/h2/p/ul/li) gets special
/// treatment; anything unrecognized is unwrapped so future minor markup
/// changes degrade gracefully instead of disappearing.
List<Widget> _buildBlock(BuildContext context, dom.Node node) {
  final theme = Theme.of(context);
  if (node is dom.Text) {
    final text = node.text.trim();
    if (text.isEmpty) return const [];
    return [Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text))];
  }
  if (node is! dom.Element) return const [];

  switch (node.localName) {
    case 'h1':
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(node.text.trim(), style: theme.textTheme.headlineSmall),
        ),
      ];
    case 'h2':
      return [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 6),
          child: Text(
            node.text.trim(),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ];
    case 'p':
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text.rich(_buildInline(context, node)),
        ),
      ];
    case 'ul':
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final li in node.children.where((c) => c.localName == 'li'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text.rich(_buildInline(context, li))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ];
    default:
      return [for (final child in node.nodes) ..._buildBlock(context, child)];
  }
}

/// Converts inline content (text, <strong>, <a>, ...) into a single InlineSpan.
InlineSpan _buildInline(BuildContext context, dom.Node node) {
  final baseStyle = Theme.of(context).textTheme.bodyMedium;
  if (node is dom.Text) {
    return TextSpan(text: node.text, style: baseStyle);
  }
  if (node is! dom.Element) return const TextSpan();

  switch (node.localName) {
    case 'strong':
    case 'b':
      return TextSpan(
        style: baseStyle?.copyWith(fontWeight: FontWeight.bold),
        children: [for (final c in node.nodes) _buildInline(context, c)],
      );
    case 'a':
      final href = node.attributes['href'];
      return TextSpan(
        text: node.text,
        style: baseStyle?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (href != null) launchUrl(Uri.parse(href));
          },
      );
    default:
      return TextSpan(
        style: baseStyle,
        children: [for (final c in node.nodes) _buildInline(context, c)],
      );
  }
}
