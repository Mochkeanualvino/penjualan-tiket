import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/film_provider.dart';
import '../../providers/studio_provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class AdminDashboardHome extends StatelessWidget {
  const AdminDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final filmCount = Provider.of<FilmProvider>(context).films.length;
    final studioCount = Provider.of<StudioProvider>(context).studios.length;
    final jadwalCount = Provider.of<JadwalProvider>(context).jadwalList.length;
    final transaksiList = Provider.of<TransaksiProvider>(context).transaksiList;
    final transaksiCount = transaksiList.length;

    double totalOmset = 0;
    for (var t in transaksiList) {
      if (t.status == 'Berhasil') totalOmset += t.totalHarga;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Sistem Bioskop',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
          ),
          const SizedBox(height: 20),

          // Stat Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard('Total Film', filmCount.toString(), Icons.movie, AppTheme.primaryGold),
                  _buildStatCard('Total Studio', studioCount.toString(), Icons.meeting_room, AppTheme.accentBlue),
                  _buildStatCard('Jadwal Aktif', jadwalCount.toString(), Icons.schedule, AppTheme.accentGreen),
                  _buildStatCard('Total Transaksi', transaksiCount.toString(), Icons.confirmation_number, Colors.purpleAccent),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Total Income Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGold.withOpacity(0.2), AppTheme.cardBgLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryGold.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet, size: 36, color: AppTheme.primaryGold),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pendapatan Tiket (Berhasil)', style: TextStyle(color: AppTheme.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(totalOmset),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primaryGold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
