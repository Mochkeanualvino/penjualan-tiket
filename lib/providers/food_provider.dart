import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/food_model.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

class FoodProvider extends ChangeNotifier {
  final List<FoodModel> _foods = [];
  final List<FoodOrderModel> _foodOrders = [];
  bool _isLoading = false;

  static const String keyFoods = 'app_foods';
  static const String keyFoodOrders = 'app_food_orders';

  List<FoodModel> get foods => _foods;
  List<FoodOrderModel> get foodOrders => _foodOrders;
  bool get isLoading => _isLoading;

  FoodProvider() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final savedFoods = LocalStorageService.loadList(keyFoods);
    final savedOrders = LocalStorageService.loadList(keyFoodOrders);

    if (savedFoods.isNotEmpty) {
      _foods.addAll(savedFoods.map((m) => FoodModel.fromMap(m, m['id'] ?? '')));
    } else {
      _seedFoods();
    }

    if (savedOrders.isNotEmpty) {
      _foodOrders.addAll(savedOrders.map((m) => FoodOrderModel.fromMap(m, m['id'] ?? '')));
    } else {
      _seedOrders();
    }
  }

  Future<void> _autoSave() async {
    await LocalStorageService.saveList(
      keyFoods,
      _foods.map((f) => {'id': f.id, ...f.toMap()}).toList(),
    );
    await LocalStorageService.saveList(
      keyFoodOrders,
      _foodOrders.map((o) => {'id': o.id, ...o.toMap()}).toList(),
    );
  }

  void _seedFoods() {
    _foods.addAll([
      FoodModel(
        id: 'food_1',
        nama: 'Popcorn Salt Medium',
        harga: 35000,
        kategori: 'Popcorn',
        imageUrl: 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=600&auto=format&fit=crop',
      ),
      FoodModel(
        id: 'food_2',
        nama: 'Popcorn Caramel Large (Diskon Jumat)',
        harga: 55000,
        kategori: 'Popcorn',
        imageUrl: 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=600&auto=format&fit=crop',
        diskonHari: 'Jumat',
        diskonPersen: 20,
      ),
      FoodModel(
        id: 'food_3',
        nama: 'Coca Cola / Fanta / Sprite',
        harga: 25000,
        kategori: 'Minuman',
        imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=600&auto=format&fit=crop',
      ),
      FoodModel(
        id: 'food_4',
        nama: 'Hotdog Beef Signature',
        harga: 40000,
        kategori: 'Makanan',
        imageUrl: 'https://images.unsplash.com/photo-1619740455993-9e612b1af08a?q=80&w=600&auto=format&fit=crop',
      ),
      FoodModel(
        id: 'food_5',
        nama: 'French Fries Crispy',
        harga: 30000,
        kategori: 'Camilan',
        imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?q=80&w=600&auto=format&fit=crop',
      ),
      FoodModel(
        id: 'food_6',
        nama: 'Combopack (Popcorn + Drink)',
        harga: 70000,
        kategori: 'Paket',
        imageUrl: 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=600&auto=format&fit=crop',
        diskonHari: 'Jumat',
        diskonPersen: 15,
      ),
    ]);
  }

  void _seedOrders() {
    _foodOrders.add(
      FoodOrderModel(
        id: 'order_101',
        userId: 'user_1',
        userEmail: 'pelanggan@bioskop.com',
        items: [
          {'nama': 'Popcorn Caramel Large', 'count': 1, 'harga': 55000, 'subtotal': 55000},
          {'nama': 'Coca Cola', 'count': 2, 'harga': 25000, 'subtotal': 50000},
        ],
        totalHarga: 105000,
        status: 'Siap Diambil',
        tanggal: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    );
  }

  // === CRUD FOOD FOR ADMIN ===

  Future<void> addFood({
    required String nama,
    required double harga,
    required String kategori,
    required String imageUrl,
    String diskonHari = '',
    int diskonPersen = 0,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final newFood = FoodModel(
      id: const Uuid().v4(),
      nama: nama,
      harga: harga,
      kategori: kategori,
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=600&auto=format&fit=crop',
      diskonHari: diskonHari,
      diskonPersen: diskonPersen,
    );

    _foods.add(newFood);
    _isLoading = false;
    notifyListeners();
    _autoSave();

    // Sync ke API Laravel jika tersedia
    ApiService.post('/foods', newFood.toMap());
  }

  Future<void> updateFood({
    required String id,
    required String nama,
    required double harga,
    required String kategori,
    required String imageUrl,
    String diskonHari = '',
    int diskonPersen = 0,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _foods.indexWhere((f) => f.id == id);
    if (index != -1) {
      _foods[index] = FoodModel(
        id: id,
        nama: nama,
        harga: harga,
        kategori: kategori,
        imageUrl: imageUrl,
        diskonHari: diskonHari,
        diskonPersen: diskonPersen,
      );
    }

    _isLoading = false;
    notifyListeners();
    _autoSave();

    ApiService.put('/foods/$id', _foods.firstWhere((f) => f.id == id).toMap());
  }

  Future<void> deleteFood(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _foods.removeWhere((f) => f.id == id);
    _isLoading = false;
    notifyListeners();
    _autoSave();

    ApiService.delete('/foods/$id');
  }

  // === FOOD ORDER FOR CUSTOMER ===

  Future<FoodOrderModel> createFoodOrder({
    required String userId,
    required String userEmail,
    required List<Map<String, dynamic>> items,
    required double totalHarga,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));

    final newOrder = FoodOrderModel(
      id: 'mfood_${const Uuid().v4().substring(0, 8)}',
      userId: userId,
      userEmail: userEmail,
      items: items,
      totalHarga: totalHarga,
      status: 'Diproses',
      tanggal: DateTime.now(),
    );

    _foodOrders.insert(0, newOrder);
    _isLoading = false;
    notifyListeners();
    _autoSave();

    return newOrder;
  }

  List<FoodOrderModel> getOrdersByUser(String userId) {
    return _foodOrders.where((o) => o.userId == userId).toList();
  }
}
