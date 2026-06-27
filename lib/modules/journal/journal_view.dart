import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'journal_controller.dart';

class JournalView extends StatelessWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final controller = Get.put(JournalController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: const Text('Jurnal Harian'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      backgroundColor: AppTheme.primaryLight,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container Form Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Obx(() => Text(
                        '${controller.charCount.value}/1000',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Input Judul
                  TextField(
                    controller: controller.titleController,
                    decoration: InputDecoration(
                      hintText: 'Judul Jurnal (Opsional)',
                      filled: true,
                      fillColor: AppTheme.primaryLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Input Konten
                  TextField(
                    controller: controller.noteController,
                    minLines: 5,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Tulis di sini...',
                      filled: true,
                      fillColor: AppTheme.primaryLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                    ),
                    onChanged: (val) {
                      controller.charCount.value = val.length;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Emosi terdeteksi',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.mood,
                              color: AppTheme.primaryBlue,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Tenang & Positif',
                              style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Tombol Simpan / Update
                  Obx(() {
                    final isEdit = controller.editingId.value != null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: controller.isLoading.value 
                              ? null 
                              : controller.saveJournal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white),
                                )
                              : Text(isEdit ? 'Update Jurnal' : 'Simpan'),
                        ),
                        if (isEdit) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: controller.cancelEdit,
                            child: const Text('Batal Edit', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ]
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Jurnal',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18),
                ),
                TextButton(
                  onPressed: controller.loadJournals, 
                  child: const Text('REFRESH'),
                ),
              ],
            ),
            // Daftar Jurnal dari Database
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.entries.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.entries.isEmpty) {
                  return const Center(
                    child: Text('Belum ada jurnal. Mulai tulis jurnal pertamamu!'),
                  );
                }

                return ListView.separated(
                  itemCount: controller.entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final entry = controller.entries[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry['title'] ?? 'Tanpa Judul',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryBlue),
                                      onPressed: () => controller.selectForEdit(entry),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                      onPressed: () => controller.deleteJournal(entry['id']),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry['created_at'] != null 
                                  ? entry['created_at'].toString().split(' ')[0] 
                                  : '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              entry['content'] ?? '',
                              style: const TextStyle(fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
