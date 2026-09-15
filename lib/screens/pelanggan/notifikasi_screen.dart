import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../services/local_storage_service.dart';
import '../../providers/auth_provider.dart';

class NotificationItem {
  final String id;
  final String userId; // 'all' untuk broadcast promo, atau ID pengguna spesifik
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final Color color;
  bool isRead;

  NotificationItem({
    required this.id,
    this.userId = 'all',
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'time': time.toIso8601String(),
      'iconCode': icon.codePoint,
      'colorValue': color.toARGB32(),
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    final int? code = map['iconCode'] as int?;
    IconData resolvedIcon = Icons.notifications;
    if (code == Icons.confirmation_number.codePoint) {
      resolvedIcon = Icons.confirmation_number;
    } else if (code == Icons.fastfood.codePoint) {
      resolvedIcon = Icons.fastfood;
    } else if (code == Icons.meeting_room.codePoint) {
      resolvedIcon = Icons.meeting_room;
    } else if (code == Icons.cancel.codePoint) {
      resolvedIcon = Icons.cancel;
    } else if (code == Icons.local_activity.codePoint) {
      resolvedIcon = Icons.local_activity;
    } else if (code == Icons.movie.codePoint) {
      resolvedIcon = Icons.movie;
    }

    return NotificationItem(
      id: map['id'] ?? '',
      userId: map['userId'] ?? 'all',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      time: map['time'] != null ? DateTime.parse(map['time']) : DateTime.now(),
      icon: resolvedIcon,
      color: Color(map['colorValue'] ?? AppTheme.primaryGold.toARGB32()),
      isRead: map['isRead'] == true,
    );
  }
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _loadFromStorage();
  }

  static const String _keyNotif = 'app_notifications_data_v3';
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  /// Ambil notifikasi khusus untuk user tertentu (termasuk broadcast 'all')
  List<NotificationItem> getNotificationsForUser(String? userId) {
    if (userId == null || userId.isEmpty) {
      return _notifications.where((n) => n.userId == 'all').toList();
    }
    return _notifications.where((n) => n.userId == 'all' || n.userId == userId).toList();
  }

  /// Hitung jumlah notifikasi belum dibaca untuk user tertentu
  int getUnreadCountForUser(String? userId) {
    return getNotificationsForUser(userId).where((n) => !n.isRead).length;
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _loadFromStorage() {
    final saved = LocalStorageService.loadList(_keyNotif);
    if (saved.isNotEmpty) {
      _notifications.clear();
      _notifications.addAll(saved.map((m) => NotificationItem.fromMap(m)));
    } else {
      _seedNotifications();
      _saveToStorage();
    }
  }

  void _saveToStorage() {
    LocalStorageService.saveList(
      _keyNotif,
      _notifications.map((n) => n.toMap()).toList(),
    );
  }

  void _seedNotifications() {
    _notifications.addAll([
      NotificationItem(
        id: 'notif_promo_1',
        userId: 'all',
        title: '🎉 Diskon Spesial KENTICKET20!',
        message: 'Gunakan voucher KENTICKET20 untuk potongan harga 20% tanpa batas minimal pembelian tiket bioskop.',
        time: DateTime.now().subtract(const Duration(minutes: 30)),
        icon: Icons.local_offer,
        color: AppTheme.primaryGold,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_promo_2',
        userId: 'all',
        title: '🎬 Film Baru Ditambahkan oleh Admin!',
        message: 'Film "Mission: Impossible - The Final Reckoning" dan "Lilo & Stitch" kini telah tayang di bioskop XXI.',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.movie,
        color: AppTheme.accentBlue,
        isRead: false,
      ),
      NotificationItem(
        id: 'notif_promo_3',
        userId: 'all',
        title: '⚡ Midtrans Snap QRIS Aktif',
        message: 'Pembayaran tiket bioskop & m.food kini lebih praktis dan aman dengan Midtrans Snap QRIS & E-Wallet.',
        time: DateTime.now().subtract(const Duration(hours: 5)),
        icon: Icons.flash_on,
        color: Colors.orangeAccent,
        isRead: false,
      ),
    ]);
  }

  void addNotification({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    String? userId = 'all',
    BuildContext? context,
  }) {
    final newItem = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? 'all',
      title: title,
      message: message,
      time: DateTime.now(),
      icon: icon,
      color: color,
      isRead: false,
    );

    _notifications.insert(0, newItem);
    _saveToStorage();
    notifyListeners();

    // Tampilkan notifikasi mengambang (In-App Heads-Up Banner) jika context tersedia
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color, width: 1.5),
          ),
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(message, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void markAsRead(String id) {
    for (var n in _notifications) {
      if (n.id == id) {
        if (!n.isRead) {
          n.isRead = true;
          _saveToStorage();
          notifyListeners();
        }
        break;
      }
    }
  }

  void markAllAsReadForUser(String? userId) {
    final userItems = getNotificationsForUser(userId);
    for (var n in userItems) {
      n.isRead = true;
    }
    _saveToStorage();
    notifyListeners();
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _saveToStorage();
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _saveToStorage();
    notifyListeners();
  }
}

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final notifService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.id;

    return AnimatedBuilder(
      animation: notifService,
      builder: (context, _) {
        final list = notifService.getNotificationsForUser(currentUserId);
        final unread = notifService.getUnreadCountForUser(currentUserId);

        return Scaffold(
          appBar: AppBar(
            title: Text('Pusat Notifikasi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            actions: [
              if (unread > 0)
                TextButton.icon(
                  onPressed: () {
                    notifService.markAllAsReadForUser(currentUserId);
                  },
                  icon: const Icon(Icons.done_all, color: AppTheme.primaryGold, size: 18),
                  label: const Text('Tandai Semua Dibaca', style: TextStyle(color: AppTheme.primaryGold, fontSize: 12)),
                ),
            ],
          ),
          body: list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.notifications_off_outlined, size: 64, color: AppTheme.textMuted),
                      SizedBox(height: 12),
                      Text('Belum ada notifikasi baru.', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (ctx, index) {
                    final item = list[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: item.isRead ? Colors.white10 : item.color.withAlpha(150),
                          width: item.isRead ? 1 : 1.5,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          notifService.markAsRead(item.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: item.color.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(item.icon, color: item.color, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w900,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        if (!item.isRead)
                                          Container(
                                            margin: const EdgeInsets.only(left: 6),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.accentRed,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'BARU',
                                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.message,
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      Formatters.formatDateTime(item.time),
                                      style: TextStyle(color: AppTheme.textMuted.withAlpha(150), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
