import 'package:flutter/material.dart';
import 'package:pooker_score/data.dart';
import 'package:pooker_score/pages/finish.dart';
import 'package:pooker_score/widgets/action_buttons.dart';
import 'package:pooker_score/widgets/scoreboard.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/pool_table_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(APP_TITLE),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.sports_score),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FinishPage()));
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                Expanded(child: Scoreboard()),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: ActionButtons(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
