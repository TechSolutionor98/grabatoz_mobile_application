
import 'package:flutter/material.dart';
import 'dart:developer';

class DummyPage extends StatefulWidget {
  const DummyPage({super.key});

  @override
  State<DummyPage> createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  @override
  void initState() {
    super.initState();
    log('DummyPage initState: Successfully reached!');
  }

  @override
  Widget build(BuildContext context) {
    log('DummyPage build: Building UI.');
    return Scaffold(
      appBar: AppBar(title: const Text("Dummy Page Test")),
      body: const Center(
        child: Text(
          "Dummy Page Reached Successfully!",
          style: TextStyle(fontSize: 20, color: Colors.green),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
