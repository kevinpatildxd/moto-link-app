import 'package:flutter/material.dart';
import '../theme.dart';

class RadarPage extends StatelessWidget {
  const RadarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid Background
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            image: DecorationImage(
              image: const NetworkImage('https://www.transparenttextures.com/patterns/grid-me.png'), // Placeholder or custom painter
              repeat: ImageRepeat.repeat,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.05),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        // Custom Painter for Grid Lines if needed, or just simple container
        
        // Riders
        _buildRiderMarker(context, 'You', 0.5, 0.5, AppTheme.primary),
        _buildRiderMarker(context, 'Alex', 0.4, 0.6, Colors.cyanAccent),
        _buildRiderMarker(context, 'Sarah', 0.6, 0.45, Colors.purpleAccent),

        // Telemetry Overlay
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '105',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      height: 1,
                      shadows: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'KM/H',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.navigation, color: AppTheme.secondary, size: 20),
                    SizedBox(width: 8),
                    Text('NW 315°', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Top Status
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            color: AppTheme.cardBg,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem('Pack Spread', '0.4 km'),
                _buildStatusItem('Next Waypoint', '12 km'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiderMarker(BuildContext context, String name, double x, double y, Color color) {
    // Using Align for simple positioning relative to screen size
    return Align(
      alignment: Alignment((x * 2) - 1, (y * 2) - 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              name,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color, blurRadius: 10, spreadRadius: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
