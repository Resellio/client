import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShellScreen extends StatelessWidget {
  const AdminShellScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Główna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Organizatorzy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
