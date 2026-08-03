import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class ProfilPelangganScreen extends StatelessWidget {
  const ProfilPelangganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryGold, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.cardBgLight,
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Pelanggan',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGold, width: 0.8),
            ),
            child: Text(
              'Role: ${user?.role ?? "Pelanggan"}',
              style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline, color: AppTheme.primaryGold),
                  title: const Text('Nama Lengkap'),
                  subtitle: Text(user?.name ?? '-'),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: AppTheme.primaryGold),
                  title: const Text('Email'),
                  subtitle: Text(user?.email ?? '-'),
                ),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: AppTheme.primaryGold),
                  title: const Text('Status Akun'),
                  subtitle: const Text('Aktif & Terverifikasi', style: TextStyle(color: AppTheme.accentGreen)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentRed,
                side: const BorderSide(color: AppTheme.accentRed),
              ),
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT SEKARANG'),
            ),
          ),
        ],
      ),
    );
  }
}
