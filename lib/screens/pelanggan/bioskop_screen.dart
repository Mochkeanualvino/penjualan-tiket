import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class BioskopScreen extends StatelessWidget {
  const BioskopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cinemas = authProvider.getCinemasForCurrentCity();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: AppTheme.primaryGold, size: 20),
            const SizedBox(width: 6),
            Text(
              authProvider.selectedCity,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryGold),
            onPressed: () => _showCityPicker(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City Selector
            InkWell(
              onTap: () => _showCityPicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGold.withAlpha(30), AppTheme.cardBgLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGold.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined, color: AppTheme.primaryGold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pilih Daerah Bioskop', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Kota saat ini: ${authProvider.selectedCity}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: AppTheme.primaryGold, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Bioskop di ${authProvider.selectedCity}',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '${cinemas.length} bioskop tersedia',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Cinema List
            cinemas.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.location_off, color: AppTheme.textMuted, size: 48),
                            const SizedBox(height: 12),
                            const Text('Belum ada bioskop di daerah ini', style: TextStyle(color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cinemas.length,
                    itemBuilder: (ctx, index) {
                      final cinema = cinemas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.movie_creation_outlined, color: AppTheme.primaryGold),
                          ),
                          title: Text(
                            cinema['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                          ),
                          subtitle: Row(
                            children: [
                              Text(cinema['address']!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              const SizedBox(width: 8),
                              Text('(${cinema['distance']})', style: const TextStyle(color: AppTheme.primaryGold, fontSize: 11)),
                            ],
                          ),
                          iconColor: AppTheme.primaryGold,
                          collapsedIconColor: AppTheme.textMuted,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.info_outline, size: 16),
                                    label: const Text('Info bioskop', style: TextStyle(fontSize: 13)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Reguler 2D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      Text('Rp40.000', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: ['13:00', '14:50', '16:40', '18:30', '20:20'].map((time) {
                                      return SizedBox(
                                        width: 100,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Jadwal $time di ${cinema['name']}')),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                          child: Text(time, style: const TextStyle(fontSize: 13)),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Pilih Daerah',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                      ),
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
