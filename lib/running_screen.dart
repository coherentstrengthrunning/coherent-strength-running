import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'running_engine.dart';

class RunningScreen extends StatelessWidget {
  const RunningScreen({super.key});

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Running',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RUNNING',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Run with purpose.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Pace is information. Effort is the signal.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 28),

            _MetricCard(
              title: 'TODAY',
              value: 'Easy Run',
              subtitle: '30–40 min • Easy effort',
            ),

            const SizedBox(height: 16),

            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    value: '--',
                    label: 'PACE',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: '--',
                    label: 'HEART RATE',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    value: '--',
                    label: 'DISTANCE',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: '--',
                    label: 'CADENCE',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveRunScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Start Run',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'RECENT RUNS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 12),

            const _RunHistoryCard(
              date: 'No runs recorded yet',
              distance: '--',
              pace: '--',
            ),
          ],
        ),
      ),
    );
  }
}

class LiveRunScreen extends StatefulWidget {
  const LiveRunScreen({super.key});

  @override
  State<LiveRunScreen> createState() => _LiveRunScreenState();
}

class _LiveRunScreenState extends State<LiveRunScreen> {
  Timer? _timer;
  StreamSubscription<Position>? _positionSubscription;

  final _engine = RunningEngine();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _beginRun();
    });
  }

Future<void> _beginRun() async {
  final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Location is off'),
          content: const Text(
            'Location must be turned on to track your run.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();

                if (mounted) {
                  await _beginRun();
                }
              },
              child: const Text('Turn on'),
            ),
          ],
        );
      },
    );

    return;
  }

  final allowed =
      await LocationService.checkPermission();

  if (!allowed) {
    return;
  }

  // Location is ready.
  _startTimer();
  await _startLocationTracking();
}

  Future<void> _startLocationTracking() async {
    final serviceEnabled = await LocationService.checkPermission();

    if (!serviceEnabled) {
       if (!mounted)return;
    
      await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Location is off'),
          content: const Text(
            'Location must be turned on to track your run.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Turn On'),
            ),
          ],
        );
      },
    );
      return;
    }
    
    _positionSubscription =
        LocationService.getPositionStream().listen(
      (Position position) {
        if (!mounted) return;

        setState(() {
          _engine.onPositionUpdate(position);
        });
      },
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {
            _engine.onTick();
          });
        }
      },
    );
  }

  void _togglePause() {
    setState(() {
      _engine.togglePause();
    });
  }

  void _endRun() {
    _timer?.cancel();
    _positionSubscription?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RunSummaryScreen(
          elapsedSeconds: _engine.elapsedSeconds,
          totalDistance: _engine.totalDistance,
        ),
      ),
    );
  }

  String _formatTime() {
    final hours = _engine.elapsedSeconds ~/ 3600;
    final minutes = (_engine.elapsedSeconds % 3600) ~/ 60;
    final seconds = _engine.elapsedSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0B0F14),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Live Run',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              Text(
                _engine.isPaused ? 'PAUSED' : 'RUNNING',
                style: TextStyle(
                  color: _engine.isPaused ? Colors.white54 : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                _formatTime(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: _LiveStat(
                      value: _engine.formatPace(),
                      label: 'PACE',
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _LiveStat(
                      value: '--',
                      label: 'HEART RATE',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _LiveStat(
                      value:
                          '${(_engine.totalDistance / 1000).toStringAsFixed(2)} km',
                      label: 'DISTANCE',
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _LiveStat(
                      value: '--',
                      label: 'CADENCE',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _togglePause,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _engine.isPaused ? 'Resume' : 'Pause',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed: _endRun,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'End Run',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class RunSummaryScreen extends StatelessWidget {
  final int elapsedSeconds;
  final double totalDistance;

  const RunSummaryScreen({
    super.key,
    required this.elapsedSeconds,
    required this.totalDistance,
  });
    String _formatPace() {
      if (totalDistance <= 0) {
      return '--';
    }
    final paceSeconds =
    elapsedSeconds / (totalDistance / 1000); // seconds per km

    final minutes = paceSeconds ~/ 60;
    final seconds = paceSeconds . round() % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')} min/km'; 
  }

  String _formatTime() {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0B0F14),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Run Complete',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            const Text(
              'SESSION COMPLETE',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Good work.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 30),

            _SummaryCard(
              value: _formatTime(),
              label: 'DURATION',
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    value: '${(totalDistance / 1000).toStringAsFixed(2)} km',
                    label: 'DISTANCE',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    value: _formatPace(),
                    label: 'PACE',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(
                  child: _SummaryCard(
                    value: '--',
                    label: 'AVG HR',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    value: '--',
                    label: 'CADENCE',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151B23),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151B23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveStat extends StatelessWidget {
  final String value;
  final String label;

  const _LiveStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151B23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 6),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151B23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RunHistoryCard extends StatelessWidget {
  final String date;
  final String distance;
  final String pace;

  const _RunHistoryCard({
    required this.date,
    required this.distance,
    required this.pace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151B23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distance,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                pace,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}