import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/plan_page.dart';

class Controller extends StatelessWidget {
  const Controller({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fliesenleger",
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const PlanPage(),
    );
  }
}
