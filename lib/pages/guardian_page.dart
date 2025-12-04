import 'package:flutter/material.dart';
import 'dart:async';
import '../theme.dart';

class GuardianPage extends StatefulWidget {
  const GuardianPage({super.key});

  @override
  State<GuardianPage> createState() => _GuardianPageState();
}

class _GuardianPageState extends State<GuardianPage> {
  double gForce = 1.0;
  String status = 'normal';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          double noise = (DateTime.now().millisecond % 20) / 100 - 0.1;
          gForce = (1.0 + noise).clamp(0.8, 1.2);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 40),
          Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.1),
                  border: Border.all(color: AppTheme.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.2),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.verified_user,
                  size: 64,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'SYSTEM ACTIVE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'Monitoring sensors...',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ],
          ),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              padding: const EdgeInsets.symmetric(vertical: 40),
              children: [
                _buildSensorCard('G-FORCE', '${gForce.toStringAsFixed(2)}g', true),
                _buildSensorCard('VELOCITY', '105 km/h', false),
                _buildSensorCard('BATTERY', '84%', false),
                _buildSensorCard('SIGNAL', '4G LTE', false),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              // Trigger SOS
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.alert.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.alert, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.phone_in_talk, color: AppTheme.alert, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'EMERGENCY SOS',
                    style: TextStyle(
                      color: AppTheme.alert,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSensorCard(String label, String value, bool showMeter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMain,
            ),
          ),
          if (showMeter) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: gForce / 4,
                backgroundColor: const Color(0xFF333333),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
