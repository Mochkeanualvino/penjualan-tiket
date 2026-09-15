import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../services/local_storage_service.dart';
import '../../providers/auth_provider.dart';
import 'notifikasi_screen.dart';

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
  static const String adminWhatsAppNumber = '6285872254708'; // Nomor WhatsApp Admin XXI (085872254708)

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final nama = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final tanggalStr = Formatters.formatShortDate(_selectedDate);
      final desc = _descController.text.trim();

      // 1. Simpan permohonan ke local storage
      final existing = LocalStorageService.loadList('app_sewa_tempat');
      existing.add({
        'id': 'sewa_${DateTime.now().millisecondsSinceEpoch}',
        'nama': nama,
        'phone': phone,
        'tipeAcara': _tipeAcara,
        'tanggal': _selectedDate.toIso8601String(),
        'catatan': desc,
        'status': 'Menunggu Konfirmasi Admin',
        'createdAt': DateTime.now().toIso8601String(),
      });
      await LocalStorageService.saveList('app_sewa_tempat', existing);

      // 2. Kirim notifikasi sistem
      final currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? 'all';
      NotificationService().addNotification(
        userId: currentUserId,
        title: '🏢 Permohonan Sewa Tempat Terkirim!',
        message: 'Permohonan sewa studio untuk "$_tipeAcara" pada $tanggalStr telah diterima Admin XXI.',
        icon: Icons.store_mall_directory,
        color: AppTheme.primaryGold,
      );

      // 3. Tampilkan dialog sukses
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 28),
                SizedBox(width: 10),
                Text('Permohonan Terkirim!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terima kasih, $nama! Permohonan sewa tempat XXI Anda telah tercatat di sistem.',
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
                          'Admin XXI akan segera menghubungi nomor WhatsApp Anda ($phone) dalam 1x24 jam untuk konfirmasi jadwal dan ketersediaan studio.',
                          style: const TextStyle(fontSize: 12, color: AppTheme.accentGreen),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Atau Anda juga dapat langsung menghubungi Customer Service XXI (085872254708):', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
            actions: [
              OutlinedButton.icon(
                icon: const Icon(Icons.chat, color: AppTheme.accentGreen, size: 16),
                label: const Text('Hubungi CS Admin via WA', style: TextStyle(color: AppTheme.accentGreen)),
                onPressed: () async {
                  final msg = Uri.encodeComponent(
                    'Halo Admin XXI Bioskop (085872254708)! 👋\n\n'
                    'Saya ($nama) baru saja mengajukan permohonan Sewa Tempat:\n'
                    '🎉 Event: $_tipeAcara\n'
                    '📅 Tanggal: $tanggalStr\n'
                    '📱 No. WA Saya: $phone\n'
                    '📝 Catatan: ${desc.isNotEmpty ? desc : "-"}\n\n'
                    'Mohon informasi lebih lanjut. Terima kasih!',
                  );
                  final waUrl = 'https://wa.me/$adminWhatsAppNumber?text=$msg';
                  try {
                    await launchUrl(Uri.parse(waUrl), mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _nameController.clear();
                  _phoneController.clear();
                  _descController.clear();
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('SELESAI'),
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
                  labelText: 'Nomor Telepon / WhatsApp Anda',
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send_rounded, color: Colors.black),
                  label: const Text('KIRIM PENGAJUAN SEWA KE ADMIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  onPressed: _submitRequest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
