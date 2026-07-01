import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
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
      ),
      backgroundColor: AppTheme.primaryLight,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadProfile,
          child: ListView(
            padding: const EdgeInsets.all(20),
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
                      backgroundImage: controller.fotoUrl.value.isNotEmpty
                          ? NetworkImage(controller.fotoUrl.value)
                          : null,
                      child: controller.fotoUrl.value.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: AppTheme.primaryBlue,
                              size: 40,
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      controller.nama.value.isNotEmpty
                          ? controller.nama.value
                          : 'Pengguna',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.email.value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5A677D),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _infoBox(
                            'MOOD',
                            '${controller.moodCount.value} catatan',
                            AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoBox(
                            'JURNAL',
                            '${controller.journalCount.value} sesi',
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoBox(
                      'TES MENTAL',
                      '${controller.assessmentCount.value} kali',
                      Colors.teal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _settingTile(
                icon: Icons.edit,
                title: 'Edit Profil',
                subtitle: 'Perbarui informasi akun Anda',
                onTap: () => _showEditDialog(context),
              ),
              const SizedBox(height: 12),
              _settingTile(
                icon: Icons.info,
                title: 'Tentang Aplikasi',
                subtitle: 'Versi MindCare v2.0 (Stabil)',
                onTap: () => _showAboutDialog(context),
              ),
              const SizedBox(height: 12),
              _settingTile(
                icon: Icons.delete_forever,
                title: 'Hapus Akun',
                subtitle: 'Hapus akun dan semua data secara permanen',
                color: Colors.red,
                onTap: () => _confirmDeleteAccount(context),
              ),
              const SizedBox(height: 12),
              _settingTile(
                icon: Icons.exit_to_app,
                title: 'Keluar',
                subtitle: 'Tutup sesi dan keluar dari aplikasi',
                color: Colors.red,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showEditDialog(BuildContext context) {
    final namaController = TextEditingController(text: controller.nama.value);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profil'),
        content: TextField(
          controller: namaController,
          decoration: const InputDecoration(labelText: 'Nama'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : () async {
                      final ok = await controller.updateProfile(
                        namaBaru: namaController.text,
                      );
                      if (ok) Get.back();
                    },
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Tentang Aplikasi'),
        content: const Text('MindCare v2.0 (Stabil)\nAplikasi pendamping kesehatan mental harian.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
          'Tindakan ini akan menghapus akun dan SEMUA data kamu secara permanen dan tidak bisa dibatalkan. Lanjutkan?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value, Color color) {
    return Container(
      width: double.infinity,
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
    required VoidCallback onTap,
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
        onTap: onTap,
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
