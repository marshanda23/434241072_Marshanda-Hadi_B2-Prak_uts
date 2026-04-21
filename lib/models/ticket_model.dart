class TicketModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String status; 
  final String prioritas; 
  final String kategori;
  final String pembuatUsername;
  final String? assignedTo;
  final DateTime createdAt;
  final List<KomentarModel> komentar;

  TicketModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.prioritas,
    required this.kategori,
    required this.pembuatUsername,
    this.assignedTo,
    required this.createdAt,
    this.komentar = const [],
  });

  TicketModel copyWith({
    String? status,
    String? assignedTo,
    List<KomentarModel>? komentar,
  }) {
    return TicketModel(
      id: id,
      judul: judul,
      deskripsi: deskripsi,
      status: status ?? this.status,
      prioritas: prioritas,
      kategori: kategori,
      pembuatUsername: pembuatUsername,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt,
      komentar: komentar ?? this.komentar,
    );
  }
}

class KomentarModel {
  final String username;
  final String isi;
  final DateTime waktu;

  KomentarModel({
    required this.username,
    required this.isi,
    required this.waktu,
  });
}

class NotifikasiModel {
  final String id;
  final String judul;
  final String pesan;
  final String tipe; 
  final DateTime waktu;
  bool sudahDibaca;

  NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.waktu,
    this.sudahDibaca = false,
  });
}