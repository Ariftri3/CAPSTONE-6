import '../../modules/assessment/assessment_model.dart';

class AssessmentProvider {
  List<AssessmentQuestion> fetchQuestions() {
    return [
      AssessmentQuestion(
        question: 'Saya merasa cemas akhir-akhir ini',
        options: ['Tidak pernah', 'Kadang', 'Sering', 'Sangat sering'],
      ),
      AssessmentQuestion(
        question: 'Saya kesulitan tidur nyenyak',
        options: ['Tidak pernah', 'Kadang', 'Sering', 'Sangat sering'],
      ),
      AssessmentQuestion(
        question: 'Saya mudah marah atau kesal',
        options: ['Tidak pernah', 'Kadang', 'Sering', 'Sangat sering'],
      ),
      AssessmentQuestion(
        question: 'Saya merasa lelah meskipun cukup istirahat',
        options: ['Tidak pernah', 'Kadang', 'Sering', 'Sangat sering'],
      ),
      AssessmentQuestion(
        question: 'Saya sulit berkonsentrasi saat bekerja atau belajar',
        options: ['Tidak pernah', 'Kadang', 'Sering', 'Sangat sering'],
      ),
      AssessmentQuestion(
        question: 'Saya merasa cemas jika harus berinteraksi dengan orang lain',
        options: ['Tidak pernah', 'Kadang', 'Sering', 'Sangat sering'],
      ),
      AssessmentQuestion(
        question: 'Saya merasa tidak berharga atau kurang percaya diri',
        options: ['Tidak pernah', 'Kadang', 'Sering', 'Sangat sering'],
      ),
      AssessmentQuestion(
        question: 'Saya kesulitan mengendalikan pikiran negatif',
        options: ['Tidak pernah', 'Kadang', 'Sering', 'Sangat sering'],
      ),
      AssessmentQuestion(
        question: 'Saya merasa khawatir tentang banyak hal sehari-hari',
        options: ['Tidak pernah', 'Kadang', 'Sering', 'Sangat sering'],
      ),
      AssessmentQuestion(
        question: 'Saya merasa cemas saat menghadapi perubahan rutinitas',
        options: ['Tidak pernah', 'Kadang', 'Sering', 'Sangat sering'],
      ),
    ];
  }
}
