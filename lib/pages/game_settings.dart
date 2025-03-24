import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/pages/calculator.dart';
import 'package:provider/provider.dart';

class GameSettingsPage extends StatelessWidget {
  const GameSettingsPage({super.key});

  void _setGameType(int balls, GameModel gameModel) {
    gameModel.setTotalBalls(balls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Settings'),
      ),
      body: Consumer<GameModel>(builder: (context, gameModel, _) {
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Game Type:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _setGameType(15, gameModel);
                    },
                    child: Column(
                      children: [
                        CustomPaint(
                          size: const Size(100, 100),
                          painter: TriangleRackPainter(),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          backgroundColor: gameModel.totalBalls == 15
                              ? colorScheme.primary
                              : null,
                          label: Text(
                            '15-ball',
                            style: TextStyle(
                              color: gameModel.totalBalls == 15
                                  ? colorScheme.onPrimary
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _setGameType(9, gameModel);
                    },
                    child: Column(
                      children: [
                        CustomPaint(
                          size: const Size(65, 100),
                          painter: DiamondRackPainter(),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          backgroundColor: gameModel.totalBalls == 9
                              ? colorScheme.primary
                              : null,
                          label: Text(
                            '9-ball',
                            style: TextStyle(
                              color: gameModel.totalBalls == 9
                                  ? colorScheme.onPrimary
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Column(
                  children: [
                    const Expanded(child: SizedBox()),
                    Center(
                      child: FilledButton.icon(
                        onPressed: gameModel.players.isNotEmpty
                            ? () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CalculatorPage()),
                                  (Route<dynamic> route) => false,
                                );
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          backgroundColor:
                              gameModel.players.isNotEmpty ? null : Colors.grey,
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow, size: 32),
                        label: const Text('Start',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class TriangleRackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiamondRackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
