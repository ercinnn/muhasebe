import 'package:flutter/material.dart';

import 'glass_theme.dart';

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: buildAppColorScheme(),
);
