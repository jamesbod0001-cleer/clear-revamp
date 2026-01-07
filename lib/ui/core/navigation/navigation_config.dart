import 'package:flutter/material.dart';

class NavigationConfig {
  static final List<NavigationDestination> hostDestinations = [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(
      icon: Icon(Icons.compare_arrows),
      label: 'Agreements',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_4_outlined),
      label: 'Profile',
    ),
  ];
}
