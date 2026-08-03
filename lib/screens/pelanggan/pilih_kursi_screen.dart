import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/jadwal_model.dart';
import '../../models/kursi_model.dart';
import '../../providers/kursi_provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import 'pembayaran_screen.dart';

class PilihKursiScreen extends StatefulWidget {
  final JadwalModel jadwal;
  const PilihKursiScreen({super.key, required this.jadwal});

  @override
  State<PilihKursiScreen> createState() => _PilihKursiScreenState();
}

class _PilihKursiScreenState extends State<PilihKursiScreen> {
  final Set<String> _selectedKursiIds = {};
  final Set<String> _selectedNomorKursi = {};

  @override
  Widget build(BuildContext context) {
    final kursiProvider = Provider.of<KursiProvider>(context);
    final kursiList = kursiProvider.getKursiByStudio(widget.jadwal.studioId);
    final double totalHarga = _selectedKursiIds.length * widget.jadwal.hargaTiket;

    return Scaffold(
      appBar: AppBar(
        title: Text('PILIH KURSI - ${widget.jadwal.namaStudio}'),
      ),
      body: Column(
        children: [
          // Screen Indicator Card (Layar Bioskop)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.cardBgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'LAYAR BIOSKOP',
                style: TextStyle(
                  color: AppTheme.primaryGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // Seat Status Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(AppTheme.cardBgLight, Colors.white, 'Tersedia'),
                _buildLegendItem(AppTheme.primaryGold, Colors.black, 'Dipilih'),
                _buildLegendItem(Colors.red.shade900, Colors.white54, 'Dipesan'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Seat Layout Grid
          Expanded(
            child: kursiList.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada kursi yang terdaftar untuk studio ini.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: kursiList.length,
                    itemBuilder: (ctx, index) {
                      final kursi = kursiList[index];
                      final isSelected = _selectedKursiIds.contains(kursi.id);
                      final isAvailable = kursi.isTersedia;

                      Color bgColor = AppTheme.cardBgLight;
                      Color textColor = Colors.white;

                      if (!isAvailable) {
                        bgColor = Colors.red.shade900.withOpacity(0.6);
                        textColor = Colors.white38;
                      } else if (isSelected) {
                        bgColor = AppTheme.primaryGold;
                        textColor = Colors.black;
                      }

                      return InkWell(
                        onTap: isAvailable
                            ? () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedKursiIds.remove(kursi.id);
                                    _selectedNomorKursi.remove(kursi.nomorKursi);
                                  } else {
                                    _selectedKursiIds.add(kursi.id);
                                    _selectedNomorKursi.add(kursi.nomorKursi);
                                  }
                                });
                              }
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.white : AppTheme.primaryGold.withOpacity(0.3),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              kursi.nomorKursi,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Purchase Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kursi: ${_selectedNomorKursi.isEmpty ? "-" : _selectedNomorKursi.join(", ")}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.currency(totalHarga),
                        style: const TextStyle(
                          color: AppTheme.primaryGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _selectedKursiIds.isEmpty
                        ? null
                        : () async {
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            final trxProvider = Provider.of<TransaksiProvider>(context, listen: false);

                            final newTrx = await trxProvider.createTransaksi(
                              userId: auth.currentUser?.id ?? 'user_anon',
                              userEmail: auth.currentUser?.email ?? 'user@bioskop.com',
                              jadwal: widget.jadwal,
                              daftarKursi: _selectedNomorKursi.toList(),
                              totalHarga: totalHarga,
                            );

                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PembayaranScreen(
                                    transaksi: newTrx,
                                    kursiIdsToReserve: _selectedKursiIds.toList(),
                                  ),
                                ),
                              );
                            }
                          },
                    child: const Text('LANJUT PEMBAYARAN'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color bg, Color text, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ],
    );
  }
}
