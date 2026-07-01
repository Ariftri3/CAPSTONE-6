import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/supabase_service.dart';

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final isSaving = false.obs;

  final nama = ''.obs;
  final email = ''.obs;
  final fotoUrl = ''.obs;

  final journalCount = 0.obs;
  final moodCount = 0.obs;
  final assessmentCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Ambil data profile + statistik dari backend Flask.
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final profileResult = await ApiService.getProfile();
      if (profileResult['success'] == true) {
        final data = profileResult['data'];
        nama.value = data['nama'] ?? 'Pengguna';
        email.value = data['email'] ?? '';
        fotoUrl.value = data['foto_url'] ?? '';
      } else {
        // Fallback ke data dasar dari sesi Supabase kalau backend belum sinkron
        final user = SupabaseService.currentUser;
        nama.value =
            user?.userMetadata?['full_name'] ?? user?.email ?? 'Pengguna';
        email.value = user?.email ?? '';
      }

      final statsResult = await ApiService.getProfileStats();
      if (statsResult['success'] == true) {
        final stats = statsResult['data'];
        journalCount.value = stats['journals'] ?? 0;
        moodCount.value = stats['mood_logs'] ?? 0;
        assessmentCount.value = stats['assessments'] ?? 0;
      }
    } catch (e) {
      Get.snackbar(
        'Gagal memuat profil',
        'Periksa koneksi internet atau server, lalu coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update nama (dan opsional foto) lewat PUT /profile.
  Future<bool> updateProfile({required String namaBaru, String? fotoBaru}) async {
    if (namaBaru.trim().isEmpty) {
      Get.snackbar(
        'Nama wajib diisi',
        'Masukkan nama yang valid.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isSaving.value = true;
    try {
      final result = await ApiService.updateProfile(
        nama: namaBaru.trim(),
        fotoUrl: fotoBaru ?? fotoUrl.value,
      );
      if (result['success'] == true) {
        nama.value = namaBaru.trim();
        if (fotoBaru != null) fotoUrl.value = fotoBaru;
        Get.snackbar(
          'Berhasil',
          'Profil berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Tidak bisa memperbarui profil',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat memperbarui profil',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Logout: keluar dari sesi Supabase, lalu kembali ke layar login.
  Future<void> logout() async {
    await SupabaseService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  /// Hapus akun DELETE /profile.
  Future<void> deleteAccount() async {
    try {
      final result = await ApiService.deleteAccount();
      if (result['success'] == true) {
        await SupabaseService.logout();
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar(
          'Akun dihapus',
          'Akun dan semua data kamu sudah dihapus.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Tidak bisa menghapus akun',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat menghapus akun',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
