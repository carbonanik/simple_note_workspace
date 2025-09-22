import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_state/simple_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = Controller();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Subscribe(
          subscribable: controller.data,
          builder: (data) {
            return Text(data);
          },
        ),
      ),
    );
  }
}

class Controller with BaseController {
  final Subscribable<String> data = Subscribable('value');

  Controller() {
    getDate();
    listen(data, immediate: true, (value) {
      debugPrint('data changed: $value');
    });
  }

  Future<void> getDate() async {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      data.value = DateTime.now().toIso8601String();
    });
  }
}

// network calls
class Response {}

abstract class SimpleHttp {
  // return future with req data
  // throws error
  Future<Response> get();
}
