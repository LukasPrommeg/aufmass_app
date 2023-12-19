import 'package:flutter/material.dart';
import 'package:aufmass_app/drawing_page/drawing_page.dart';

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
