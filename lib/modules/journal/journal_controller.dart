import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';

class JournalController extends GetxController {
  final noteController = TextEditingController();
  final titleController = TextEditingController();
  final charCount = 0.obs;
  final isLoading = false.obs;
  final entries = [].obs;

  // Rekomendasi kegiatan anti-stres dari backend, muncul setelah simpan jurnal.
  // Format: [{"kategori": "Cemas", "kegiatan": ["...", "..."]}, ...]
  final recommendations = <Map<String, dynamic>>[].obs;

  final editingId =
      RxnInt(); // ID jurnal yang sedang diedit (null jika mode tambah)

  @override
  void onInit() {
    super.onInit();
    loadJournals();
  }

  Future<void> loadJournals() async {
    isLoading.value = true;
    try {
      final result = await ApiService.getJournals();
      if (result['success'] == true) {
        entries.value = result['data'];
      }
    } catch (e) {
      // Get.snackbar('Error', 'Gagal memuat jurnal');
    } finally {
      isLoading.value = false;
    }
  }

  void selectForEdit(Map<String, dynamic> entry) {
    editingId.value = entry['id'];
    titleController.text = entry['title'] ?? '';
    noteController.text = entry['content'] ?? '';
    charCount.value = noteController.text.length;
  }

  void cancelEdit() {
    editingId.value = null;
    titleController.clear();
    noteController.clear();
    charCount.value = 0;
  }

  void clearRecommendations() {
    recommendations.value = [];
  }

  /// Tampilkan dialog konfirmasi sebelum benar-benar menghapus jurnal.
  /// Dipanggil dari tombol hapus di journal_view.dart.
  void confirmAndDelete(int id, {String? title}) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus jurnal?'),
        content: Text(
          title != null && title.isNotEmpty
              ? 'Jurnal "$title" akan dihapus permanen dan tidak bisa dikembalikan.'
              : 'Jurnal ini akan dihapus permanen dan tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Get.back(); // tutup dialog dulu
              deleteJournal(id);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteJournal(int id) async {
    isLoading.value = true;
    try {
      final result = await ApiService.deleteJournal(id);
      if (result['success'] == true) {
        Get.snackbar(
          'Berhasil',
          'Jurnal berhasil dihapus 🗑️',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE8F5E9),
        );
        // Jika sedang mengedit jurnal yang dihapus, batalkan edit
        if (editingId.value == id) {
          cancelEdit();
        }
        loadJournals();
      } else {
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Gagal menghapus jurnal',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFEBEE),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveJournal() async {
    final content = noteController.text.trim();
    final title = titleController.text.trim().isEmpty
        ? 'Jurnal Harian'
        : titleController.text.trim();

    if (content.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Isi jurnal tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    recommendations.value =
        []; // bersihkan rekomendasi lama selama proses simpan
    try {
      final isEdit = editingId.value != null;
      final result = isEdit
          ? await ApiService.updateJournal(
              editingId.value!,
              title: title,
              content: content,
              mood: 'Tenang & Positif',
            )
          : await ApiService.createJournal(
              title: title,
              content: content,
              mood: 'Tenang & Positif',
            );

      if (result['success'] == true) {
        cancelEdit();
        Get.snackbar(
          'Berhasil',
          isEdit
              ? 'Jurnal berhasil diupdate 📝'
              : 'Jurnal berhasil disimpan 📝',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE8F5E9),
        );
        // Tampilkan rekomendasi kegiatan anti-stres dari backend (jika ada)
        final recs = result['recommendations'];
        if (recs is List) {
          recommendations.value = recs
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
        loadJournals(); // Refresh list jurnal
      } else {
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Gagal menyimpan jurnal',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFEBEE),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    noteController.dispose();
    titleController.dispose();
    super.onClose();
  }
}
