import 'package:flutter/material.dart';
import 'running_screen.dart';

void main() {
  runApp(const CoherentStrengthRunning());
}

class CoherentStrengthRunning extends StatelessWidget {
  const CoherentStrengthRunning({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coherent Strength Running',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F0E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8FA89C),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWatch = size.width < 300;

    final horizontalPadding = isWatch ? 14.0 : 24.0;
    final topPadding = isWatch ? 16.0 : 28.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            isWatch ? 24 : 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              if (isWatch)
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COHERENT',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Strength Running',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COHERENT',
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Strength Running',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white24,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

              SizedBox(height: isWatch ? 24 : 52),

              // COACHING MESSAGE
              Text(
                'Train with clarity.',
                style: TextStyle(
                  fontSize: isWatch ? 25 : 34,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),

              SizedBox(height: isWatch ? 8 : 12),

              Text(
                'Build strength. Run better. Understand your body.',
                style: TextStyle(
                  fontSize: isWatch ? 12 : 16,
                  color: Colors.white60,
                  height: 1.35,
                ),
              ),

              SizedBox(height: isWatch ? 20 : 32),

              // TODAY'S SESSION
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isWatch ? 14 : 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isWatch ? 14 : 20),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                  color: const Color(0xFF121817),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S SESSION",
                      style: TextStyle(
                        fontSize: isWatch ? 9 : 12,
                        letterSpacing: isWatch ? 1.3 : 2,
                        color: Colors.white54,
                      ),
                    ),

                    SizedBox(height: isWatch ? 8 : 14),

                    Text(
                      'Easy Run',
                      style: TextStyle(
                        fontSize: isWatch ? 20 : 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '30–40 min • Easy effort',
                      style: TextStyle(
                        fontSize: isWatch ? 11 : 14,
                        color: Colors.white60,
                      ),
                    ),

                    SizedBox(height: isWatch ? 12 : 20),

                    SizedBox(
                      width: double.infinity,
                      height: isWatch ? 42 : 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RunningScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD7E1DB),
                          foregroundColor: const Color(0xFF101513),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              isWatch ? 12 : 14,
                            ),
                          ),
                        ),
                        child: Text(
                          'Start Session',
                          style: TextStyle(
                            fontSize: isWatch ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isWatch ? 22 : 36),

              // EXPLORE
              Text(
                'EXPLORE',
                style: TextStyle(
                  fontSize: isWatch ? 9 : 12,
                  letterSpacing: isWatch ? 1.5 : 2,
                  color: Colors.white54,
                ),
              ),

              SizedBox(height: isWatch ? 10 : 16),

              // FEATURE CARDS
              if (isWatch) ...[
                FeatureCard(
                  icon: Icons.directions_run,
                  title: 'Running',
                  subtitle: 'Pace & HR',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RunningScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                FeatureCard(
                  icon: Icons.fitness_center,
                  title: 'Strength',
                  subtitle: 'Build capacity',
                  onTap: () {},
                ),

                const SizedBox(height: 8),

                FeatureCard(
                  icon: Icons.accessibility_new,
                  title: 'Mobility',
                  subtitle: 'Move better',
                  onTap: () {},
                ),

                const SizedBox(height: 8),

                FeatureCard(
                  icon: Icons.insights,
                  title: 'Analytics',
                  subtitle: 'Understand progress',
                  onTap: () {},
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.directions_run,
                        title: 'Running',
                        subtitle: 'Pace & HR',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RunningScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.fitness_center,
                        title: 'Strength',
                        subtitle: 'Build capacity',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.accessibility_new,
                        title: 'Mobility',
                        subtitle: 'Move better',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.insights,
                        title: 'Analytics',
                        subtitle: 'Understand progress',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: isWatch ? 22 : 36),

              // PHILOSOPHY
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isWatch ? 14 : 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isWatch ? 14 : 20),
                  color: const Color(0xFF101513),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.remove,
                      size: isWatch ? 18 : 24,
                      color: Colors.white38,
                    ),

                    SizedBox(height: isWatch ? 6 : 12),

                    Text(
                      'Progress is not about doing more.',
                      style: TextStyle(
                        fontSize: isWatch ? 14 : 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: isWatch ? 4 : 6),

                    Text(
                      'It is about doing what your body can adapt to.',
                      style: TextStyle(
                        fontSize: isWatch ? 11 : 14,
                        color: Colors.white54,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        height: 145,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white10,
          ),
          color: const Color(0xFF101513),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 25,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}