// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:shippinglist/pages/Stores.dart';
import 'pages/ShoppingList.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Stores(),
      '/ShoppingList': (context) => ShoppingList(),
    },
  ));
}
