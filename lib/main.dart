import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/film_provider.dart';
import 'providers/studio_provider.dart';
import 'providers/kursi_provider.dart';
import 'providers/jadwal_provider.dart';
import 'providers/transaksi_provider.dart';
import 'providers/food_provider.dart';
import 'services/local_storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/admin/dashboard_admin_screen.dart';
import 'screens/pelanggan/dashboard_pelanggan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await LocalStorageService.init();

  runApp(const BioskopApp());
}

class BioskopApp extends StatelessWidget {
  const BioskopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FilmProvider()),
        ChangeNotifierProvider(create: (_) => StudioProvider()),
        ChangeNotifierProvider(create: (_) => KursiProvider()),
        ChangeNotifierProvider(create: (_) => JadwalProvider()),
        ChangeNotifierProvider(create: (_) => TransaksiProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
      ],
      child: MaterialApp(
        title: 'KENTICKET',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    if (authProvider.isAdmin) {
      return const DashboardAdminScreen();
    } else {
      return const DashboardPelangganScreen();
    }
  }
}
