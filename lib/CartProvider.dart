import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Model/OrderItemXrefType.dart';
import 'Model/ReturnOrderItemXrefType.dart';

class CartProvider extends ChangeNotifier {
  List<OrderItemXrefType> cartItems = [];
  List<ReturnOrderItemXrefType> retuncartItems = [];
  static const String cartKey = 'cart';
  List<String>? cartItemsJson = [];
  // Method to add items to the cart
  Future<void> addToCart(OrderItemXrefType item) async {
    cartItems.add(item);
    notifyListeners();

    // Save the cartItems to SharedPreferences
    await saveCartItemsToSharedPreferences(cartItems);
  }

  Future<void> saveToSharedPreferences(OrderItemXrefType orderItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cartItems') ?? [];

    // Convert OrderItemXrefType to JSON
    String orderItemJson = jsonEncode(orderItem.toJson());

    // Add the JSON representation to the list
    cartItemsJson.add(orderItemJson);

    // Save the updated list to SharedPreferences
    prefs.setStringList('cartItems', cartItemsJson);
  }
  // Method to save cart items to SharedPreferences
  Future<void> saveCartItemsToSharedPreferences(
      List<OrderItemXrefType> cartItems) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve existing cart items from SharedPreferences
    cartItemsJson = prefs.getStringList('cart_items') ?? [];

    // Convert the selected products to a JSON string
    List<String> selectedProductStrings =
    cartItems.map((product) => jsonEncode(product.toJson())).toList();

    // Add the selected products to the existing cart items
    cartItemsJson!.addAll(selectedProductStrings);

    // Save the updated cart items back to SharedPreferences
    prefs.setStringList('cart_items', cartItemsJson!);

    // Log the cart items
    print('Cart Items: $cartItemsJson');
    // cartitemslength = '${cartItemsJson.length}';
    print('Cart Items Length: ${cartItemsJson!.length}');

  }

  // Method to retrieve cart items from SharedPreferences
  Future<List<OrderItemXrefType>> getCartItemsFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cartItems') ?? [];
    List<OrderItemXrefType> cartItems = [];

    for (String json in cartItemsJson) {
      // Parse JSON string to Map<String, dynamic>
      Map<String, dynamic> jsonMap = jsonDecode(json);

      // Convert Map<String, dynamic> to OrderItemXrefType
      OrderItemXrefType orderItem = OrderItemXrefType.fromJson(jsonMap); // Implement a fromJson method in your OrderItemXrefType class
      cartItems.add(orderItem);
    }

    return cartItems;
  }

  // For example, a method to get the current items in the cart
  List<OrderItemXrefType> getCartItems() {
    return cartItems;
  }
  List<ReturnOrderItemXrefType> getReturnCartItems() {
    return retuncartItems;
  }
  // Method to remove an item from the cart
  Future<void> removeFromCart(OrderItemXrefType item) async {
    cartItems.remove(item);
    notifyListeners();

    // Save the updated cartItems to SharedPreferences
    await saveCartItemsToSharedPreferences(cartItems);
  }
  bool isSameItemGroup(String newItemGrpCod) {
    if (cartItems.isEmpty) {
      // If the cart is empty, there are no conflicts
      return true;
    }

    // Check if the newItemGrpCod is the same as the itemGrpCod of the first item in the cart
    return cartItems.first.itemGrpCod == newItemGrpCod;
  }
  bool isSamereturnItemGroup(String newItemGrpCod) {
    if (retuncartItems.isEmpty) {
      // If the cart is empty, there are no conflicts
      return true;
    }

    // Check if the newItemGrpCod is the same as the itemGrpCod of the first item in the cart
    return retuncartItems.first.itemGrpCod == newItemGrpCod;
  }

  bool isSameItemcode(String newItemCode) {
    if (cartItems.isEmpty) {
      // If the cart is empty, there are no conflicts
      return true;
    }

    // Check if the newItemGrpCod is the same as the itemGrpCod of the first item in the cart
    return cartItems.first.itemCode == newItemCode;
  }
// Inside CartProvider class
  bool isItemInCart(OrderItemXrefType orderItem) {
    // Implement the logic to check if the item is in the cart
    // This could involve checking the list of items in the cart.
    // Return true if the item is in the cart, false otherwise.
    // Example:
    return cartItems.contains(orderItem);
  }
  // Method to clear the cart
  void clearCart() {
    // Your logic to clear the cart
    cartItems.clear();
  }


  Future<void> addToreturnorderCart(ReturnOrderItemXrefType item) async {
    retuncartItems.add(item);
    notifyListeners();

    // Save the cartItems to SharedPreferences
    await savereturnCartItemsToSharedPreferences(retuncartItems);
  }

  Future<void> savereturnCartItemsToSharedPreferences(
      List<ReturnOrderItemXrefType> cartItems) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve existing cart items from SharedPreferences
    cartItemsJson = prefs.getStringList('cart_items') ?? [];

    // Convert the selected products to a JSON string
    List<String> selectedProductStrings =
    cartItems.map((product) => jsonEncode(product.toJson())).toList();

    // Add the selected products to the existing cart items
    cartItemsJson!.addAll(selectedProductStrings);

    // Save the updated cart items back to SharedPreferences
    prefs.setStringList('cart_items', cartItemsJson!);

    // Log the cart items
    print('Cart Items: $cartItemsJson');
    // cartitemslength = '${cartItemsJson.length}';
    print('Cart Items Length: ${cartItemsJson!.length}');

  }
  void clearreturnCart() {
    // Your logic to clear the cart
    retuncartItems.clear();
  }


}