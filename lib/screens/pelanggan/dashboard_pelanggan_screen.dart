import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/kenticket_logo.dart';
import 'home_screen.dart';
import 'riwayat_transaksi_screen.dart';
import 'promo_screen.dart';
import 'profil_pelanggan_screen.dart';
import 'search_film_delegate.dart';
import 'notifikasi_screen.dart';

class DashboardPelangganScreen extends StatefulWidget {
  const DashboardPelangganScreen({super.key});

  @override
  State<DashboardPelangganScreen> createState() => _DashboardPelangganScreenState();
}

class _DashboardPelangganScreenState extends State<DashboardPelangganScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    RiwayatTransaksiScreen(),
    PromoScreen(),
    ProfilPelangganScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const KenticketLogo(size: 28, showText: true, isCompact: true),
        actions: [
          // City Selector Chip
          InkWell(
            onTap: () => _showCityPicker(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryGold.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    authProvider.selectedCity,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Notification Bell with Dynamic Unread Badge
          AnimatedBuilder(
            animation: NotificationService(),
            builder: (context, _) {
              final unreadCount = NotificationService().getUnreadCountForUser(authProvider.currentUser?.id);

              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined, color: AppTheme.primaryGold),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentRed,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                  );
                },
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryGold),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchFilmDelegate(),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.cardBg,
        selectedItemColor: AppTheme.primaryGold,
        unselectedItemColor: AppTheme.textMuted,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Pesanan Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Promo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Akun Saya',
          ),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateSheet) {
            final query = searchController.text.toLowerCase();
            final filteredCities = AuthProvider.cities
                .where((c) => c.toLowerCase().contains(query))
                .toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              builder: (ctx, scrollController) {
                return Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.textMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      'Pilih Daerah Bioskop',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setStateSheet(() {}),
                        decoration: InputDecoration(
                          hintText: 'Cari kota...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    setStateSheet(() {});
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filteredCities.length,
                        itemBuilder: (ctx, index) {
                          final city = filteredCities[index];
                          final isSelected = city == authProvider.selectedCity;
                          final cinemaCount = AuthProvider.cinemasByCity[city]?.length ?? 0;

                          return ListTile(
                            leading: Icon(
                              Icons.location_city,
                              color: isSelected ? AppTheme.primaryGold : AppTheme.textMuted,
                            ),
                            title: Text(
                              city,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppTheme.primaryGold : Colors.white,
                              ),
                            ),
                            subtitle: Text('$cinemaCount bioskop', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryGold) : null,
                            onTap: () {
                              authProvider.setSelectedCity(city);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
