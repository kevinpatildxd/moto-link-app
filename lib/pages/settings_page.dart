import 'package:flutter/material.dart';
import '../theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('General'),
        _buildSettingsItem(Icons.person, 'Profile', 'Edit your rider profile'),
        
        const SizedBox(height: 30),
        
        _buildSectionHeader('Preferences'),
        _buildSettingsItem(Icons.map, 'Offline Maps', 'Manage downloaded regions'),
        _buildSettingsItem(Icons.volume_up, 'Audio Settings', 'Noise cancellation & volume'),
        
        const SizedBox(height: 30),
        
        _buildSectionHeader('Safety'),
        _buildToggleItem(Icons.notifications_active, 'Crash Detection', 'Sensitivity: Normal', true),
        _buildToggleItem(Icons.battery_std, 'Power Saving', 'OLED Black Mode', true),

        const SizedBox(height: 40),
        const Center(
          child: Text(
            'MotoLink v1.0.0 (Beta)',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primary,
          letterSpacing: 1,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: AppTheme.cardBg,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.textMuted, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF444444)),
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, String subtitle, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: AppTheme.cardBg,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.textMuted, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: (val) {},
          activeColor: AppTheme.primary,
          activeTrackColor: AppTheme.primary.withOpacity(0.3),
        ),
      ),
    );
  }
}
