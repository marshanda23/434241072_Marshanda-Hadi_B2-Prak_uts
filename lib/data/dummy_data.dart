import '../models/user_model.dart';
import '../models/ticket_model.dart';

class DummyData {
  static final Map<String, Map<String, String>> credentials = {
    'admin':    {'password': 'admin123',    'role': 'Admin'},
    'helpdesk': {'password': 'helpdesk123', 'role': 'Helpdesk'},
    'user':     {'password': 'user123',     'role': 'User'},
  };

  static final Map<String, UserModel> users = {
    'admin': UserModel(
      username: 'admin',
      role: 'Admin',
      email: 'admin@helpdesk.com',
      nama: 'Administrator',
    ),
    'helpdesk': UserModel(
      username: 'helpdesk',
      role: 'Helpdesk',
      email: 'helpdesk@helpdesk.com',
      nama: 'Petugas Helpdesk',
    ),
    'user': UserModel(
      username: 'user',
      role: 'User',
      email: 'user@helpdesk.com',
      nama: 'Marshanda',
    ),
  };

  static final List<UserModel> daftarHelpdesk = [
    UserModel(username: 'helpdesk', role: 'Helpdesk', email: 'helpdesk@helpdesk.com', nama: 'Petugas Helpdesk'),
    UserModel(username: 'helpdesk2', role: 'Helpdesk', email: 'helpdesk2@helpdesk.com', nama: 'Helpdesk 2'),
    UserModel(username: 'helpdesk3', role: 'Helpdesk', email: 'helpdesk3@helpdesk.com', nama: 'Helpdesk 3'),
  ];

  static List<TicketModel> tikets = [
    TicketModel(
      id: 'TKT-001',
      judul: 'Tidak bisa login ke cybercampus',
      deskripsi: 'Saya mencoba login ke cybercampus sejak pagi tapi selalu muncul error "invalid credentials" padahal password sudah benar.',
      status: 'on_progress',
      prioritas: 'high',
      kategori: 'Akses Sistem',
      pembuatUsername: 'user',
      assignedTo: 'helpdesk',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      komentar: [
        KomentarModel(username: 'helpdesk', isi: 'Baik, kami sedang investigasi masalah ini.', waktu: DateTime.now().subtract(const Duration(hours: 2))),
      ],
    ),
    TicketModel(
      id: 'TKT-002',
      judul: 'Proyektor kelas 304 gedung c mati',
      deskripsi: 'Proyektor di kelas 304 gedung c tidak mau nyala, padahal sudah di coba berkali-kali',
      status: 'open',
      prioritas: 'medium',
      kategori: 'Hardware',
      pembuatUsername: 'user',
      assignedTo: null,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      komentar: [],
    ),
    TicketModel(
      id: 'TKT-003',
      judul: 'Internet lambat di gedung A',
      deskripsi: 'Koneksi internet di gedung A sangat lambat sejak kemarin sore.',
      status: 'resolved',
      prioritas: 'high',
      kategori: 'Jaringan',
      pembuatUsername: 'user',
      assignedTo: 'helpdesk',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      komentar: [
        KomentarModel(username: 'helpdesk', isi: 'Sudah diperbaiki, router diganti yang baru.', waktu: DateTime.now().subtract(const Duration(days: 1))),
      ],
    ),
    TicketModel(
      id: 'TKT-004',
      judul: 'hebat e learning bertuliskan "eror"',
      deskripsi: 'saat login ke hebat e-learning muncul eror',
      status: 'open',
      prioritas: 'low',
      kategori: 'Software',
      pembuatUsername: 'user',
      assignedTo: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      komentar: [],
    ),
    TicketModel(
      id: 'TKT-005',
      judul: 'AC di ruang server mati',
      deskripsi: 'AC di ruang server lantai 3 mati sejak tadi malam.',
      status: 'on_progress',
      prioritas: 'high',
      kategori: 'Fasilitas',
      pembuatUsername: 'user',
      assignedTo: 'helpdesk2',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      komentar: [
        KomentarModel(username: 'helpdesk2', isi: 'Teknisi AC sudah dihubungi, akan datang dalam 1 jam.', waktu: DateTime.now().subtract(const Duration(hours: 7))),
      ],
    ),
  ];

  
  static List<NotifikasiModel> notifikasi = [
    NotifikasiModel(id: 'N-001', judul: 'Tiket TKT-001 diassign', pesan: 'Tiket Anda sudah diassign ke Petugas Helpdesk.', tipe: 'info', waktu: DateTime.now().subtract(const Duration(hours: 2)), sudahDibaca: false),
    NotifikasiModel(id: 'N-002', judul: 'Tiket TKT-003 selesai', pesan: 'Masalah internet lambat di gedung A telah berhasil diselesaikan.', tipe: 'success', waktu: DateTime.now().subtract(const Duration(days: 1)), sudahDibaca: false),
    NotifikasiModel(id: 'N-003', judul: 'Tiket TKT-005 urgent', pesan: 'Tiket AC ruang server ditandai sebagai prioritas tinggi.', tipe: 'warning', waktu: DateTime.now().subtract(const Duration(hours: 7)), sudahDibaca: true),
    NotifikasiModel(id: 'N-004', judul: 'Tiket TKT-001 diperbarui', pesan: 'Status tiket SIAKAD berubah menjadi On Progress.', tipe: 'info', waktu: DateTime.now().subtract(const Duration(days: 1, hours: 2)), sudahDibaca: true),
  ];
}