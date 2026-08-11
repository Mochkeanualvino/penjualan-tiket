import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

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

  Future<void> _submitAndOpenWhatsApp() async {
    if (_formKey.currentState!.validate()) {
      final nama = _nameController.text.trim();
      String phone = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (phone.startsWith('0')) {
        phone = '62${phone.substring(1)}';
      }

      final tanggalStr = Formatters.formatShortDate(_selectedDate);
      final desc = _descController.text.trim();

      final message = 'Halo Admin XXI Bioskop! 👋\n\n'
          'Saya mengajukan permohonan Sewa Tempat / Studio XXI:\n'
          '👤 Nama: $nama\n'
          '📱 No. WA: ${_phoneController.text.trim()}\n'
          '🎉 Tipe Event: $_tipeAcara\n'
          '📅 Tanggal Rencana: $tanggalStr\n'
          '📝 Catatan: ${desc.isNotEmpty ? desc : "-"}\n\n'
          'Mohon konfirmasi jadwal sewa studio 1x24 jam. Terima kasih!';

      final encodedMessage = Uri.encodeComponent(message);
      final waUrl = 'https://wa.me/$phone?text=$encodedMessage';
      final fallbackUrl = 'https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage';

      try {
        final uri = Uri.parse(waUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Error launch WhatsApp: $e');
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 28),
                SizedBox(width: 10),
                Text('Persetujuan Berhasil!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terima kasih, $nama! Permohonan sewa tempat XXI Anda telah tercatat.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.accentGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_chat_read, color: AppTheme.accentGreen),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pesan WA berhasil dikirim ke ${_phoneController.text.trim()}.\nTim XXI Marketing akan mengonfirmasi permintaan Anda dalam 1x24 jam.',
                          style: const TextStyle(fontSize: 12, color: AppTheme.accentGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  _nameController.clear();
                  _phoneController.clear();
                  _descController.clear();
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
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
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon / WhatsApp',
                  hintText: 'e.g. 08123456789',
                  prefixIcon: Icon(Icons.phone_android, color: AppTheme.primaryGold),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nomor WA wajib diisi' : null,
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
                subtitle: Text(Formatters.formatShortDate(_selectedDate), style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.calendar_today, color: AppTheme.primaryGold),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().add(const Duration(days: 1)),
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
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('KIRIM PENGAJUAN & BUKA WA'),
                  onPressed: _submitAndOpenWhatsApp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
