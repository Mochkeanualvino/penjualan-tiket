import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/theme.dart';

class SewaTempatScreen extends StatefulWidget {
  const SewaTempatScreen({super.key});

  @override
  State<SewaTempatScreen> createState() => _SewaTempatScreenState();
}

class _SewaTempatScreenState extends State<SewaTempatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();
  String _tipeAcara = 'Ulang Tahun';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sewa Tempat XXI', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking & Sewa Studio XXI',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Gunakan studio bioskop eksklusif kami untuk event privat, ulang tahun, seminar, atau nonton bareng keluarga.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap / Instansi'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor Telepon / WhatsApp'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipeAcara,
                decoration: const InputDecoration(labelText: 'Tipe Event'),
                dropdownColor: AppTheme.cardBgLight,
                items: ['Ulang Tahun', 'Seminar / Corporate', 'Nonton Bareng Privat', 'Lainnya'].map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _tipeAcara = val);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: AppTheme.cardBgLight,
                title: const Text('Tanggal Rencana Event', style: TextStyle(fontSize: 12, color: AppTheme.primaryGold)),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.calendar_today, color: AppTheme.primaryGold),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().add(const Duration(days: 3)),
                    lastDate: DateTime.now().add(const Duration(days: 180)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Keterangan Tambahan (Jumlah Orang, Studio Pilihan, dll)'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _nameController.clear();
                      _phoneController.clear();
                      _descController.clear();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Persetujuan Berhasil'),
                          content: const Text('Permohonan sewa tempat Anda telah dikirim. Tim XXI Marketing akan menghubungi Anda dalam waktu 1x24 jam.'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('KIRIM PENGAJUAN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
