import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/food_model.dart';
import '../models/category_model.dart';
import '../models/cart_item_model.dart';
import '../services/api_client.dart';
import '../services/food_service.dart';
import '../services/cart_service.dart';

class AppState {
  final UserModel? userLogin;
  final List<FoodModel> foods;
  final List<CategoryModel> categories;
  final List<CartItemModel> cart;

  const AppState({
    this.userLogin,
    this.foods = const [],
    this.categories = const [],
    this.cart = const [],
  });

  AppState copyWith({
    Object? userLogin = _sentinel,
    List<FoodModel>? foods,
    List<CategoryModel>? categories,
    List<CartItemModel>? cart,
  }) {
    return AppState(
      userLogin:
          userLogin == _sentinel ? this.userLogin : userLogin as UserModel?,
      foods: foods ?? this.foods,
      categories: categories ?? this.categories,
      cart: cart ?? this.cart,
    );
  }
}

const _sentinel = Object();

class AppProvider extends ChangeNotifier {
  AppState _state = const AppState();
  bool _isInitializing = true;
  bool _isFetchingData = false;
  String? _fetchError;

  // ── Getters ──────────────────────────────────────────────────────────────

  UserModel? get userLogin => _state.userLogin;
  List<FoodModel> get foods => _state.foods;
  List<CategoryModel> get categories => _state.categories;
  List<CartItemModel> get cart => _state.cart;
  bool get isInitializing => _isInitializing;
  bool get isFetchingData => _isFetchingData;
  String? get fetchError => _fetchError;

  int get cartCount =>
      _state.cart.fold(0, (sum, item) => sum + item.quantity);

  double get itemsTotal =>
      _state.cart.fold(0.0, (sum, item) => sum + item.subtotal);

  double get discount => itemsTotal * 0.017; // matches backend 1.7%
  double get taxes => itemsTotal * 0.08;
  double get deliveryCharges => 30.0;
  double get totalPay => itemsTotal - discount + taxes + deliveryCharges;

  // ── Session init ──────────────────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (token != null && userJson != null) {
      try {
        ApiClient.setToken(token);
        _state = _state.copyWith(
          userLogin: UserModel.fromJson(
            jsonDecode(userJson) as Map<String, dynamic>,
          ),
        );
        // Restore cart from backend on session resume
        await loadCart();
      } catch (_) {
        await prefs.remove('token');
        await prefs.remove('user');
        ApiClient.clearToken();
      }
    }
    _isInitializing = false;
    notifyListeners();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> setUserLogin(UserModel? user, {String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null && token != null) {
      ApiClient.setToken(token);
      await prefs.setString('token', token);
      await prefs.setString('user', jsonEncode(user.toMap()));
      // Load cart from backend after login
      await loadCart();
    } else {
      ApiClient.clearToken();
      await prefs.remove('token');
      await prefs.remove('user');
      _state = _state.copyWith(cart: []);
    }
    _state = _state.copyWith(userLogin: user);
    notifyListeners();
  }

  void setFoods(List<FoodModel> foods) {
    _state = _state.copyWith(foods: foods);
    notifyListeners();
  }

  void setCategories(List<CategoryModel> categories) {
    _state = _state.copyWith(categories: categories);
    notifyListeners();
  }

  // Fetch cart from backend and replace local cart
  Future<void> loadCart() async {
    try {
      final cart = await CartService.getCart();
      _state = _state.copyWith(cart: cart);
      notifyListeners();
    } catch (e) {
      debugPrint('loadCart error: $e');
    }
  }

  // Optimistic add: update UI immediately, then sync to backend
  Future<void> addToCart(FoodModel food) async {
    final existingIndex =
        _state.cart.indexWhere((item) => item.food.id == food.id);

    if (existingIndex >= 0) {
      final updated = List<CartItemModel>.from(_state.cart);
      final item = updated[existingIndex];
      updated[existingIndex] = item.copyWith(quantity: item.quantity + 1);
      _state = _state.copyWith(cart: updated);
      notifyListeners();
    } else {
      _state = _state.copyWith(
        cart: [..._state.cart, CartItemModel(food: food)],
      );
      notifyListeners();
    }

    // Backend sync — POST /api/cart handles upsert (increments if exists)
    try {
      final result = await CartService.addItem(food.id, 1);
      final cartItemId = result['id']?.toString();
      if (cartItemId != null) {
        final updated = List<CartItemModel>.from(_state.cart);
        final idx = updated.indexWhere((item) => item.food.id == food.id);
        if (idx >= 0 && updated[idx].cartItemId == null) {
          updated[idx] = updated[idx].copyWith(cartItemId: cartItemId);
          _state = _state.copyWith(cart: updated);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('addToCart sync error: $e');
    }
  }

  Future<void> incrementQuantity(String foodId) async {
    final updated = List<CartItemModel>.from(_state.cart);
    final idx = updated.indexWhere((item) => item.food.id == foodId);
    if (idx < 0) return;

    final item = updated[idx];
    final newQty = item.quantity + 1;
    updated[idx] = item.copyWith(quantity: newQty);
    _state = _state.copyWith(cart: updated);
    notifyListeners();

    try {
      if (item.cartItemId != null) {
        await CartService.updateItem(item.cartItemId!, newQty);
      } else {
        await CartService.addItem(item.food.id, 1);
      }
    } catch (e) {
      debugPrint('incrementQuantity error: $e');
    }
  }

  Future<void> decrementQuantity(String foodId) async {
    final updated = List<CartItemModel>.from(_state.cart);
    final idx = updated.indexWhere((item) => item.food.id == foodId);
    if (idx < 0) return;

    final item = updated[idx];

    if (item.quantity > 1) {
      final newQty = item.quantity - 1;
      updated[idx] = item.copyWith(quantity: newQty);
      _state = _state.copyWith(cart: updated);
      notifyListeners();

      try {
        if (item.cartItemId != null) {
          await CartService.updateItem(item.cartItemId!, newQty);
        }
      } catch (e) {
        debugPrint('decrementQuantity error: $e');
      }
    } else {
      updated.removeAt(idx);
      _state = _state.copyWith(cart: updated);
      notifyListeners();

      try {
        if (item.cartItemId != null) {
          await CartService.removeItem(item.cartItemId!);
        }
      } catch (e) {
        debugPrint('decrementQuantity error: $e');
      }
    }
  }

  void clearCart() {
    _state = _state.copyWith(cart: []);
    notifyListeners();
  }

  // Data loader — called from CategoriesScreen (via addPostFrameCallback)
  Future<void> fetchInitialData() async {
    _isFetchingData = true;
    _fetchError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        FoodService.fetchCategories(),
        FoodService.fetchFoods(),
      ]);
      // Update state in one shot to avoid three rapid notifyListeners calls
      _state = _state.copyWith(
        categories: results[0] as List<CategoryModel>,
        foods: results[1] as List<FoodModel>,
      );
    } catch (e) {
      _fetchError = e.toString();
    } finally {
      _isFetchingData = false;
      notifyListeners();
    }
  }
}
