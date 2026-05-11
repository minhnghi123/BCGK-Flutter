import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/food_model.dart';
import '../models/category_model.dart';
import '../models/cart_item_model.dart';
import '../services/api_client.dart';
import '../services/food_service.dart';

// Immutable state — mirrors the exam's initialState object
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

// AppProvider — ChangeNotifier mirroring useContext + useReducer from the exam
class AppProvider extends ChangeNotifier {
  AppState _state = const AppState();
  bool _isInitializing = true;

  // ── Getters ──────────────────────────────────────────────────────────────

  UserModel? get userLogin => _state.userLogin;
  List<FoodModel> get foods => _state.foods;
  List<CategoryModel> get categories => _state.categories;
  List<CartItemModel> get cart => _state.cart;
  bool get isInitializing => _isInitializing;

  int get cartCount =>
      _state.cart.fold(0, (sum, item) => sum + item.quantity);

  double get itemsTotal =>
      _state.cart.fold(0.0, (sum, item) => sum + item.subtotal);

  double get discount => itemsTotal * 0.02;
  double get taxes => itemsTotal * 0.08;
  double get deliveryCharges => 30.0;
  double get totalPay => itemsTotal - discount + taxes + deliveryCharges;

  // ── Session init — call once in main() before runApp ─────────────────────

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
      } catch (_) {
        // Corrupt stored data — clear it
        await prefs.remove('token');
        await prefs.remove('user');
        ApiClient.clearToken();
      }
    }
    _isInitializing = false;
    notifyListeners();
  }

  // ── Actions (mirror reducer cases) ───────────────────────────────────────

  // USER_LOGIN — pass token alongside user to persist session
  Future<void> setUserLogin(UserModel? user, {String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null && token != null) {
      ApiClient.setToken(token);
      await prefs.setString('token', token);
      await prefs.setString('user', jsonEncode(user.toMap()));
    } else {
      ApiClient.clearToken();
      await prefs.remove('token');
      await prefs.remove('user');
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

  void addToCart(FoodModel food) {
    final existingIndex =
        _state.cart.indexWhere((item) => item.food.id == food.id);
    if (existingIndex >= 0) {
      final updated = List<CartItemModel>.from(_state.cart);
      updated[existingIndex].quantity++;
      _state = _state.copyWith(cart: updated);
    } else {
      _state = _state.copyWith(
        cart: [..._state.cart, CartItemModel(food: food)],
      );
    }
    notifyListeners();
  }

  void incrementQuantity(String foodId) {
    final updated = List<CartItemModel>.from(_state.cart);
    final idx = updated.indexWhere((item) => item.food.id == foodId);
    if (idx >= 0) {
      updated[idx].quantity++;
      _state = _state.copyWith(cart: updated);
      notifyListeners();
    }
  }

  void decrementQuantity(String foodId) {
    final updated = List<CartItemModel>.from(_state.cart);
    final idx = updated.indexWhere((item) => item.food.id == foodId);
    if (idx >= 0) {
      if (updated[idx].quantity > 1) {
        updated[idx].quantity--;
      } else {
        updated.removeAt(idx);
      }
      _state = _state.copyWith(cart: updated);
      notifyListeners();
    }
  }

  void clearCart() {
    _state = _state.copyWith(cart: []);
    notifyListeners();
  }

  // Data loader — called from CategoriesScreen
  Future<void> fetchInitialData() async {
    final results = await Future.wait([
      FoodService.fetchCategories(),
      FoodService.fetchFoods(),
    ]);
    setCategories(results[0] as List<CategoryModel>);
    setFoods(results[1] as List<FoodModel>);
  }
}
