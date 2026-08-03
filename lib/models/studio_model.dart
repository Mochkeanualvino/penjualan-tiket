class StudioModel {
  final String id;
  final String namaStudio;
  final int kapasitas;

  StudioModel({
    required this.id,
    required this.namaStudio,
    required this.kapasitas,
  });

  factory StudioModel.fromMap(Map<String, dynamic> map, String docId) {
    return StudioModel(
      id: docId,
      namaStudio: map['namaStudio'] ?? '',
      kapasitas: (map['kapasitas'] ?? 0) is int ? (map['kapasitas'] ?? 0) : int.parse(map['kapasitas'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaStudio': namaStudio,
      'kapasitas': kapasitas,
    };
  }
}
