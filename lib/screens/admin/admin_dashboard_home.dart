import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/film_provider.dart';
import '../../providers/studio_provider.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../providers/food_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class AdminDashboardHome extends StatelessWidget {
  final Function(int index)? onNavigateTab;

  const AdminDashboardHome({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final filmCount = Provider.of<FilmProvider>(context).films.length;
    final studioCount = Provider.of<StudioProvider>(context).studios.length;
    final jadwalCount = Provider.of<JadwalProvider>(context).jadwalList.length;
    final transaksiList = Provider.of<TransaksiProvider>(context).transaksiList;
    final foodCount = Provider.of<FoodProvider>(context).foods.length;
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
          const SizedBox(height: 6),
          const Text(
            'Klik pada kotak statistik di bawah untuk langsung menuju halaman pengelola terkait.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Stat Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 3 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.35,
                children: [
                  _buildStatCard(
                    title: 'Total Film',
                    value: filmCount.toString(),
                    icon: Icons.movie,
                    color: AppTheme.primaryGold,
                    onTap: () => onNavigateTab?.call(1),
                  ),
                  _buildStatCard(
                    title: 'Total Studio',
                    value: studioCount.toString(),
                    icon: Icons.meeting_room,
                    color: AppTheme.accentBlue,
                    onTap: () => onNavigateTab?.call(2),
                  ),
                  _buildStatCard(
                    title: 'Jadwal Aktif',
                    value: jadwalCount.toString(),
                    icon: Icons.schedule,
                    color: AppTheme.accentGreen,
                    onTap: () => onNavigateTab?.call(4),
                  ),
                  _buildStatCard(
                    title: 'Total Transaksi',
                    value: transaksiCount.toString(),
                    icon: Icons.confirmation_number,
                    color: Colors.purpleAccent,
                    onTap: () => onNavigateTab?.call(5),
                  ),
                  _buildStatCard(
                    title: 'Menu Makanan',
                    value: foodCount.toString(),
                    icon: Icons.fastfood,
                    color: Colors.orangeAccent,
                    onTap: () => onNavigateTab?.call(7),
                  ),
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
                colors: [AppTheme.primaryGold.withAlpha(50), AppTheme.cardBgLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryGold.withAlpha(100)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withAlpha(50),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
