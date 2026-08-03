import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/film_model.dart';
import '../../providers/jadwal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import 'pilih_kursi_screen.dart';
import 'search_film_delegate.dart';

class PilihJadwalScreen extends StatefulWidget {
  final FilmModel film;
  const PilihJadwalScreen({super.key, required this.film});

  @override
  State<PilihJadwalScreen> createState() => _PilihJadwalScreenState();
}

class _PilihJadwalScreenState extends State<PilihJadwalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDateIndex = 0;
  late List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getDayName(DateTime date) {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return days[date.weekday % 7];
  }

  String _getMonthName(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jadwalProvider = Provider.of<JadwalProvider>(context);
    final jadwalList = jadwalProvider.getJadwalByFilm(widget.film.id);
    final cinemas = authProvider.getCinemasForCurrentCity();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 18, color: AppTheme.primaryGold),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGold.withAlpha(80)),
              ),
              child: Text(
                authProvider.selectedCity,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== FILM DETAIL HEADER =====
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.film.posterUrl,
                      width: 80,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Container(
                        width: 80,
                        height: 110,
                        color: Colors.grey.shade900,
                        child: const Icon(Icons.movie, color: AppTheme.primaryGold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Advance badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Advance ticket sales',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.film.judul.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.film.genre,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        // Chips row
                        Row(
                          children: [
                            _buildInfoChip('${widget.film.durasi ~/ 60}h ${widget.film.durasi % 60}m'),
                            const SizedBox(width: 6),
                            _buildInfoChip(widget.film.ratingUsia, isRating: true),
                            const SizedBox(width: 6),
                            _buildInfoChip('2D'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== TABS: Jadwal / Detail =====
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryGold,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textMuted,
              tabs: const [
                Tab(text: 'Jadwal'),
                Tab(text: 'Detail'),
              ],
            ),
            const SizedBox(height: 16),

            // ===== DATE PICKER ROW =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${_getMonthName(_dates[_selectedDateIndex])}',
                        style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMuted),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_dates[_selectedDateIndex].year}',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dates.length,
                      itemBuilder: (ctx, index) {
                        final date = _dates[index];
                        final isSelected = index == _selectedDateIndex;
                        final isToday = index == 0;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedDateIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 52,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryGold : AppTheme.cardBgLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryGold : Colors.white10,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getDayName(date),
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : AppTheme.textMuted,
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}'.padLeft(2, '0'),
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== CINEMA XXI FILTER CHIP =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.tune, color: AppTheme.textMuted, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBgLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryGold),
                    ),
                    child: Text(
                      'Cinema XXI',
                      style: GoogleFonts.poppins(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== CINEMA SCHEDULE CARDS =====
            ...cinemas.map((cinema) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cinema name with expand arrow
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cinema['name']!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                  ),
                                  Text(
                                    '(${cinema['distance']})',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_up, color: AppTheme.textMuted),
                          ],
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.info_outline, size: 14),
                          label: const Text('Info bioskop', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Price row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Reguler 2D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(
                              jadwalList.isNotEmpty
                                  ? Formatters.currency(jadwalList.first.hargaTiket)
                                  : 'Rp 40.000',
                              style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Time slots
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _getTimeSlotsForCinema(cinema['name']!).map((time) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (jadwalList.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PilihKursiScreen(jadwal: jadwalList.first),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Jadwal $time - ${cinema['name']}')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<String> _getTimeSlotsForCinema(String cinemaName) {
    // Generate varied time slots per cinema
    final hash = cinemaName.hashCode.abs();
    final slots = <String>[];
    final baseSlots = ['10:00', '12:30', '13:00', '14:50', '15:30', '16:40', '18:30', '19:00', '20:20', '21:15'];
    for (int i = 0; i < baseSlots.length; i++) {
      if ((hash + i) % 3 != 0) slots.add(baseSlots[i]);
      if (slots.length >= 5) break;
    }
    if (slots.isEmpty) slots.addAll(['13:00', '16:40', '20:20']);
    return slots;
  }

  Widget _buildInfoChip(String label, {bool isRating = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRating ? AppTheme.primaryGold : AppTheme.cardBgLight,
        borderRadius: BorderRadius.circular(8),
        border: isRating ? null : Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isRating ? Colors.black : AppTheme.textMuted,
          fontSize: 12,
          fontWeight: isRating ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
