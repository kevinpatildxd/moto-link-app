import 'package:flutter/material.dart';
import '../theme.dart';

class CommsPage extends StatefulWidget {
  const CommsPage({super.key});

  @override
  State<CommsPage> createState() => _CommsPageState();
}

class _CommsPageState extends State<CommsPage> with SingleTickerProviderStateMixin {
  bool isMuted = false;
  bool isPTT = false;
  double volume = 80;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.group, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Pack Channel #1',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Text(
            '4 Riders Online',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 30),
          
          Expanded(
            child: ListView(
              children: [
                _buildSpeakerCard('Alex', 'Speaking...', true),
                _buildSpeakerCard('Sarah', 'Listening', false),
              ],
            ),
          ),

          const SizedBox(height: 20),
          
          // Volume Control
          Row(
            children: [
              const Icon(Icons.volume_up, color: AppTheme.textMuted),
              Expanded(
                child: Slider(
                  value: volume,
                  min: 0,
                  max: 100,
                  activeColor: AppTheme.textMain,
                  inactiveColor: AppTheme.borderColor,
                  onChanged: (val) => setState(() => volume = val),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // PTT Button
          GestureDetector(
            onTapDown: (_) => setState(() => isPTT = true),
            onTapUp: (_) => setState(() => isPTT = false),
            onTapCancel: () => setState(() => isPTT = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
                ),
                border: Border.all(
                  color: isPTT ? AppTheme.secondary : const Color(0xFF333333),
                  width: 4,
                ),
                boxShadow: isPTT
                    ? [
                        BoxShadow(
                            color: AppTheme.secondary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5),
                        const BoxShadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 5),
                      ]
                    : [
                        const BoxShadow(
                            color: Colors.black,
                            offset: Offset(5, 5),
                            blurRadius: 10),
                        BoxShadow(
                            color: Colors.grey.shade900,
                            offset: const Offset(-5, -5),
                            blurRadius: 10),
                      ],
              ),
              child: Center(
                child: Text(
                  isPTT ? 'TRANSMITTING' : 'HOLD TO TALK',
                  style: TextStyle(
                    color: isPTT ? AppTheme.secondary : AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Mute Toggle
          GestureDetector(
            onTap: () => setState(() => isMuted = !isMuted),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isMuted ? const Color(0xFF331111) : AppTheme.cardBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isMuted ? AppTheme.alert : AppTheme.borderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMuted ? Icons.mic_off : Icons.mic,
                    color: isMuted ? AppTheme.alert : AppTheme.textMain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isMuted ? 'MUTED' : 'OPEN MIC',
                    style: TextStyle(
                      color: isMuted ? AppTheme.alert : AppTheme.textMain,
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

  Widget _buildSpeakerCard(String name, String status, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary.withOpacity(0.05) : AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppTheme.primary : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF333333),
            child: Text(name[0], style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? AppTheme.primary : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isActive) _buildVisualizer(),
        ],
      ),
    );
  }

  Widget _buildVisualizer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBar(12),
        const SizedBox(width: 2),
        _buildBar(20),
        const SizedBox(width: 2),
        _buildBar(8),
      ],
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 4,
      height: height,
      color: AppTheme.primary,
    );
  }
}
