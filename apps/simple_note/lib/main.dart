import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_note/app.dart';
import 'package:simple_note/dependencies.dart';

void main() {
  initializedDependencies();
  runApp(const ProviderScope(child: MyApp()));
}
