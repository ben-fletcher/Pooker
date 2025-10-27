import 'package:flutter/material.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play Pooker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            _buildSection(
              context,
              title: 'What is Pooker?',
              content: 'Pooker is a snooker-style game played on a pool table. It combines the strategy and scoring of snooker with the accessibility of pool equipment.',
            ),
            
            // Equipment
            _buildSection(
              context,
              title: 'Equipment Needed',
              content: '• A pool table\n• At least one black ball (8-ball)\n• Multiple colored balls to act as "reds"\n• Pool cues for each player',
            ),
            
            // Basic Rules
            _buildSection(
              context,
              title: 'Basic Rules',
              content: 'All balls except the black ball are treated as "red balls" worth 1 point each. The black ball is the only "color ball" worth 3 points.\n\nPlayers take turns attempting to pot balls and score points.',
            ),
            
            // Ball Values
            _buildHighlightCard(
              context,
              title: 'Ball Values',
              content: '🔴 Red Balls: 1 point each\n⚫ Black Ball: 3 points',
            ),
            
            // Turn Structure
            _buildSection(
              context,
              title: 'Turn Structure',
              content: '1. Players must first pot a red ball\n2. After potting a red, they can attempt the black ball\n3. Continue alternating red-black until no reds remain\n4. Once all reds are gone, only the black ball remains\n5. The game ends when the black ball is potted with no reds left',
            ),
            
            // Fouls
            _buildSection(
              context,
              title: 'Fouls (-1 point)',
              content: '• Missing your target ball\n• Potting the wrong ball first\n• Potting the black ball when reds remain (unless after a red)\n• Scratching (cue ball in pocket)\n• Other standard pool fouls',
            ),
            
            // Game Types
            _buildSection(
              context,
              title: 'Game Types',
              content: 'You can play with different numbers of balls:\n• 9-Ball: Quick games\n• 15-Ball: Full rack games\n\nChoose your game type in the setup screen.',
            ),
            
            // Skill Shots
            _buildSection(
              context,
              title: 'Skill Shot Bonus (+1 point)',
              content: 'When enabled in settings, players can award bonus points for impressive shots or entertaining mistakes. Tap the "Skill Shot" button after any turn to award a bonus point.',
            ),
            
            // Winning
            _buildSection(
              context,
              title: 'Winning the Game',
              content: 'The player with the most points when all balls are potted wins! Points are calculated from successful pots minus any fouls committed.',
            ),
            
            // Strategy Tips
            _buildSection(
              context,
              title: 'Strategy Tips',
              content: '• Plan your shots to leave good position for the next ball\n• Consider safety play if you can\'t make a shot\n• Watch your opponent\'s patterns and weaknesses\n• Practice controlling the cue ball for better position\n• Remember: consistency beats risky shots',
            ),
            
            const SizedBox(height: 24),
            
            // Fun fact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Fun Fact',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pooker can be played with any number of players! Unlike traditional pool games, everyone can participate by taking turns, making it perfect for parties and large groups.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(BuildContext context, {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
