import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/transaksi_model.dart';
import '../../models/food_model.dart';
import '../../providers/transaksi_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class RiwayatTransaksiScreen extends StatefulWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTicketDetailModal(BuildContext context, TransaksiModel trx) {
    final bookingCode = 'XXI-${trx.id.hashCode.abs().toString().padLeft(7, '8').substring(0, 7)}';
    final qrImageUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&margin=8&data=${Uri.encodeComponent("TICKET-PASS-$bookingCode-${trx.filmJudul}-${trx.daftarKursi.join(",")}")}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Cinema E-Ticket Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.primaryGold, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryGold.withAlpha(40), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.movie, color: AppTheme.primaryGold, size: 24),
                            const SizedBox(width: 8),
                            Text('CINEMA XXI E-TICKET', style: GoogleFonts.poppins(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.accentGreen),
                          ),
                          child: const Text('LUNAS', style: TextStyle(color: AppTheme.accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),

                    // QR Code Scanner Frame
                    Container(
                      width: 170,
                      height: 170,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          qrImageUrl,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, _, __) => const Center(
                            child: Icon(Icons.qr_code_2, size: 120, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'KODE BOOKING: $bookingCode',
                      style: GoogleFonts.poppins(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.5),
                    ),
                    const Text('Tunjukkan QR Code ini di scanner pintu bioskop XXI', style: TextStyle(color: Colors.white60, fontSize: 11)),

                    const Divider(color: Colors.white12, height: 24),

                    // Detail Specs Table
                    _buildTicketRow('Film', trx.filmJudul, isBold: true),
                    _buildTicketRow('Studio', trx.namaStudio),
                    _buildTicketRow('Tanggal Tayang', Formatters.formatShortDate(trx.tanggalTayang)),
                    _buildTicketRow('Jam Tayang', trx.jamTayang),
                    _buildTicketRow('Nomor Kursi', trx.daftarKursi.join(', '), isGold: true),
                    _buildTicketRow('Total Bayar', Formatters.currency(trx.totalHarga)),
                    _buildTicketRow('Metode Pembayaran', trx.pembayaran?.metode ?? 'Midtrans Snap'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                  label: const Text('SCAN DI PINTU MASUK BIOSKOP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFoodDetailModal(BuildContext context, FoodOrderModel order) {
    final voucherCode = 'FOOD-${order.id.hashCode.abs().toString().padLeft(6, '9').substring(0, 6)}';
    final qrImageUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&margin=8&data=${Uri.encodeComponent("MFOOD-VOUCHER-$voucherCode")}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.primaryGold, width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fastfood, color: AppTheme.primaryGold, size: 24),
                            const SizedBox(width: 8),
                            Text('E-VOUCHER M.FOOD', style: GoogleFonts.poppins(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.accentGreen),
                          ),
                          child: const Text('SIAP DIAMBIL', style: TextStyle(color: AppTheme.accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Container(
                      width: 150,
                      height: 150,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Image.network(qrImageUrl, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 10),
                    Text('KODE PENGAMBILAN: $voucherCode', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 14)),
                    const Text('Tunjukkan kode ini ke kasir snack bioskop XXI', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    const Divider(color: Colors.white12, height: 20),
                    ...order.items.map((i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${i['count']}x ${i['nama']}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                              Text(Formatters.currency((i['subtotal'] ?? 0).toDouble()), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        )),
                    const Divider(color: Colors.white12, height: 20),
                    _buildTicketRow('Total Pembayaran', Formatters.currency(order.totalHarga), isGold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('TUTUP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, {bool isBold = false, bool isGold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold || isGold ? FontWeight.bold : FontWeight.normal,
              color: isGold ? AppTheme.primaryGold : Colors.white,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final trxProvider = Provider.of<TransaksiProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);

    final myTicketTransactions = trxProvider.getTransaksiByUser(auth.currentUser?.id ?? '');
    final myFoodOrders = foodProvider.getOrdersByUser(auth.currentUser?.id ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('PESANAN SAYA'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGold,
          labelColor: AppTheme.primaryGold,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.confirmation_number_outlined), text: 'Tiket Bioskop'),
            Tab(icon: Icon(Icons.fastfood_outlined), text: 'Makanan m.food'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: TIKET BIOSKOP
          myTicketTransactions.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text(
                      'Belum ada riwayat pesanan tiket bioskop.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: myTicketTransactions.length,
                  itemBuilder: (ctx, index) {
                    final trx = myTicketTransactions[index];
                    Color statusColor = AppTheme.accentGreen;
                    if (trx.status == 'Dibatalkan') statusColor = AppTheme.accentRed;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showTicketDetailModal(context, trx),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    trx.id,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 13),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withAlpha(51),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: statusColor, width: 0.8),
                                    ),
                                    child: Text(
                                      trx.status == 'Pending' ? 'Berhasil' : trx.status,
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 20),
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      trx.posterUrl,
                                      width: 60,
                                      height: 85,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, _, __) => Container(
                                        width: 60,
                                        height: 85,
                                        color: Colors.grey.shade900,
                                        child: const Icon(Icons.movie, color: AppTheme.primaryGold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(trx.filmJudul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                        const SizedBox(height: 4),
                                        Text('Studio: ${trx.namaStudio}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                        Text('Jam: ${trx.jamTayang}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                        Text('Kursi: ${trx.daftarKursi.join(", ")}', style: const TextStyle(color: AppTheme.primaryGold, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.qr_code_2, color: AppTheme.primaryGold, size: 16),
                                      SizedBox(width: 4),
                                      Text('Ketuk untuk E-Ticket Scanner', style: TextStyle(color: AppTheme.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Text(
                                    Formatters.currency(trx.totalHarga),
                                    style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

          // TAB 2: MAKANAN MFOOD
          myFoodOrders.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text(
                      'Belum ada riwayat pesanan makanan m.food.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: myFoodOrders.length,
                  itemBuilder: (ctx, index) {
                    final order = myFoodOrders[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showFoodDetailModal(context, order),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ORDER #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 13),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGreen.withAlpha(51),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppTheme.accentGreen, width: 0.8),
                                    ),
                                    child: const Text(
                                      'Berhasil',
                                      style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Formatters.formatDateTime(order.tanggal),
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                              const Divider(color: Colors.white10, height: 20),
                              ...order.items.map((i) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${i['count']}x ${i['nama']}', style: const TextStyle(fontSize: 13)),
                                      Text(Formatters.currency((i['subtotal'] ?? 0).toDouble()), style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                );
                              }),
                              const Divider(color: Colors.white10, height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.qr_code, color: AppTheme.primaryGold, size: 16),
                                      SizedBox(width: 4),
                                      Text('Ketuk E-Voucher Kasir', style: TextStyle(color: AppTheme.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Text(
                                    Formatters.currency(order.totalHarga),
                                    style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
