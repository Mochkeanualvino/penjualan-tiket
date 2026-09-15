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
    int parsedKapasitas = 0;
    if (map['kapasitas'] != null) {
      if (map['kapasitas'] is int) {
        parsedKapasitas = map['kapasitas'];
      } else if (map['kapasitas'] is num) {
        parsedKapasitas = (map['kapasitas'] as num).toInt();
      } else {
        final clean = map['kapasitas'].toString().replaceAll(RegExp(r'[^0-9]'), '');
        parsedKapasitas = int.tryParse(clean) ?? 0;
      }
    }

    return StudioModel(
      id: docId,
      namaStudio: map['namaStudio'] ?? '',
      kapasitas: parsedKapasitas,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaStudio': namaStudio,
      'kapasitas': kapasitas,
    };
  }
}
