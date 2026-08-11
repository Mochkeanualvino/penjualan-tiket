import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import 'admin_dashboard_home.dart';
import 'kelola_film_screen.dart';
import 'kelola_studio_screen.dart';
import 'kelola_kursi_screen.dart';
import 'kelola_jadwal_screen.dart';
import 'kelola_transaksi_screen.dart';
import 'kelola_pembayaran_screen.dart';
import 'kelola_makanan_screen.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Dashboard',
    'Kelola Film',
    'Kelola Studio',
    'Kelola Kursi',
    'Kelola Jadwal',
    'Kelola Transaksi',
    'Kelola Pembayaran',
    'Kelola Makanan',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final List<Widget> pages = [
      AdminDashboardHome(
        onNavigateTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const KelolaFilmScreen(),
      const KelolaStudioScreen(),
      const KelolaKursiScreen(),
      const KelolaJadwalScreen(),
      const KelolaTransaksiScreen(),
      const KelolaPembayaranScreen(),
      const KelolaMakananScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('ADMIN - ${_titles[_selectedIndex]}'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: AppTheme.accentRed),
            onPressed: () {
              authProvider.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Berhasil logout dari sistem Admin')),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            return Row(
              children: [
                // Navigation Rail for Desktop
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() => _selectedIndex = index);
                  },
                  backgroundColor: AppTheme.cardBg,
                  indicatorColor: AppTheme.primaryGold,
                  selectedIconTheme: const IconThemeData(color: Colors.black),
                  unselectedIconTheme: const IconThemeData(color: AppTheme.textMuted),
                  selectedLabelTextStyle: GoogleFonts.poppins(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                  unselectedLabelTextStyle: GoogleFonts.poppins(color: AppTheme.textMuted),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                    NavigationRailDestination(icon: Icon(Icons.movie), label: Text('Film')),
                    NavigationRailDestination(icon: Icon(Icons.meeting_room), label: Text('Studio')),
                    NavigationRailDestination(icon: Icon(Icons.event_seat), label: Text('Kursi')),
                    NavigationRailDestination(icon: Icon(Icons.schedule), label: Text('Jadwal')),
                    NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Transaksi')),
                    NavigationRailDestination(icon: Icon(Icons.payment), label: Text('Pembayaran')),
                    NavigationRailDestination(icon: Icon(Icons.fastfood), label: Text('Makanan')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
                Expanded(child: pages[_selectedIndex]),
              ],
            );
          } else {
            return IndexedStack(
              index: _selectedIndex,
              children: pages,
            );
          }
        },
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.cardBg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.cardBgLight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 40, color: AppTheme.primaryGold),
                  const SizedBox(height: 10),
                  Text('ADMIN PANEL', style: GoogleFonts.poppins(fontSize: 18, color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                  Text(authProvider.currentUser?.email ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            _buildDrawerItem(0, 'Dashboard', Icons.dashboard),
            _buildDrawerItem(1, 'Kelola Film', Icons.movie),
            _buildDrawerItem(2, 'Kelola Studio', Icons.meeting_room),
            _buildDrawerItem(3, 'Kelola Kursi', Icons.event_seat),
            _buildDrawerItem(4, 'Kelola Jadwal', Icons.schedule),
            _buildDrawerItem(5, 'Kelola Transaksi', Icons.receipt_long),
            _buildDrawerItem(6, 'Kelola Pembayaran', Icons.payment),
            _buildDrawerItem(7, 'Kelola Makanan', Icons.fastfood),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.accentRed),
              title: const Text('Logout', style: TextStyle(color: AppTheme.accentRed)),
              onTap: () {
                Navigator.pop(context);
                authProvider.logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryGold : AppTheme.textMuted),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryGold : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
