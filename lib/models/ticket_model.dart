class TicketModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String status; 
  final String prioritas; 
  final String kategori;
  final String pembuatId;
  final String? assignedTo;
  final DateTime createdAt;
  final List<KomentarModel> komentar;
  final String? lampiranUrl;

  TicketModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.prioritas,
    required this.kategori,
    required this.pembuatId,
    this.assignedTo,
    required this.createdAt,
    this.komentar = const [],
    this.lampiranUrl,
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
      pembuatId: pembuatId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt,
      komentar: komentar ?? this.komentar,
      lampiranUrl: lampiranUrl,
    );
  }
}

class KomentarModel {
  final String userId;
  final String nama;
  final String isi;
  final DateTime waktu;

  KomentarModel({
    required this.userId,
    required this.nama,
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

class RiwayatTiketModel {
  final String id;
  final String ticketId;
  final String aksi;
  final String keterangan;
  final DateTime waktu;

  RiwayatTiketModel({
    required this.id,
    required this.ticketId,
    required this.aksi,
    required this.keterangan,
    required this.waktu,
  });
}