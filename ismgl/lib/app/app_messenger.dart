import 'package:flutter/material.dart';

/// Clé globale pour afficher des SnackBars même sans `BuildContext` local (GetX, services).
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
