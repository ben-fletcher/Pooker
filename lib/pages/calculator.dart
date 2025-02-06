import 'package:flutter/material.dart';
import 'package:pooker_score/data.dart';
import 'package:pooker_score/widgets/action_buttons.dart';
import 'package:pooker_score/widgets/scoreboard.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(APP_TITLE),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Scoreboard(),
            ActionButtons()
          ],
        )
      ),
    );
  }
}
