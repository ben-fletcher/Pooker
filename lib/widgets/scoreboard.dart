import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:provider/provider.dart';

class Scoreboard extends StatelessWidget {
  const Scoreboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, gameState, child) => Column(
        children: [
          const Text("Scoreboard"),
          for (var player in gameState.players)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(player.Name),
                Text(player.Turns.fold(0, (value, element) => value + element.score).toString())
              ],
            ),
        ],
      ),
    );
  }
}

// class Scoreboard extends StatelessWidget {
//   const Scoreboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Table(
//       border: TableBorder.all(),
//       columnWidths: const <int, TableColumnWidth>{
//         0: IntrinsicColumnWidth(),
//         1: FlexColumnWidth(),
//         2: FixedColumnWidth(64),
//       },
//       defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//       children: <TableRow>[
//         TableRow(
//           children: <Widget>[
//             Container(
//               height: 32,
//               color: Colors.green,
//             ),
//             TableCell(
//               verticalAlignment: TableCellVerticalAlignment.top,
//               child: Container(
//                 height: 32,
//                 width: 32,
//                 color: Colors.red,
//               ),
//             ),
//             Container(
//               height: 64,
//               color: Colors.blue,
//             ),
//           ],
//         ),
//         TableRow(
//           decoration: const BoxDecoration(
//             color: Colors.grey,
//           ),
//           children: <Widget>[
//             Container(
//               height: 64,
//               width: 128,
//               color: Colors.purple,
//             ),
//             Container(
//               height: 32,
//               color: Colors.yellow,
//             ),
//             Center(
//               child: Container(
//                 height: 32,
//                 width: 32,
//                 color: Colors.orange,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
