import 'package:dcdg/dcdg.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/planpage.dart';

void main() {
  runApp(const Controller());
}

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
