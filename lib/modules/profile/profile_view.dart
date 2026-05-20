import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      backgroundColor: AppTheme.primaryLight,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.primaryBlue,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'halo teman',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'nama@email.com',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5A677D)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _infoBox(
                          'STREAK',
                          '12 Hari',
                          AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoBox('JURNAL', '24 sesi', Colors.purple),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _settingTile(
              icon: Icons.edit,
              title: 'Edit Profil',
              subtitle: 'Perbarui informasi akun Anda',
            ),
            const SizedBox(height: 12),
            _settingTile(
              icon: Icons.notifications,
              title: 'Pengaturan Notifikasi',
              subtitle: 'Atur notifikasi yang Anda terima',
            ),
            const SizedBox(height: 12),
            _settingTile(
              icon: Icons.lock,
              title: 'Keamanan',
              subtitle: 'Kelola pengaturan keamanan akun',
            ),
            const SizedBox(height: 12),
            _settingTile(
              icon: Icons.info,
              title: 'Tentang Aplikasi',
              subtitle: 'Versi MindCare v2.0 (Stabil)',
            ),
            const SizedBox(height: 12),
            _settingTile(
              icon: Icons.exit_to_app,
              title: 'Keluar',
              subtitle: 'Tutup sesi dan keluar dari aplikasi',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = Colors.black,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color == Colors.red
                ? Colors.red.withOpacity(0.12)
                : AppTheme.primaryBlue.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: color == Colors.red ? Colors.red : AppTheme.primaryBlue,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: color == Colors.red ? Colors.red : AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF5A677D), fontSize: 13),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFFB0B7C3),
        ),
      ),
    );
  }
}
