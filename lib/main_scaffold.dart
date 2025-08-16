

import 'package:flutter/material.dart';
import 'package:sendit/components/nav_icon.dart';
import 'package:sendit/features/earn/earn_screen.dart';
import 'package:sendit/features/home/presentation/pages/home_page.dart';
import 'package:sendit/features/profile/presentation/profile_screen.dart';
import 'package:sendit/features/promo/promo_screen.dart';
import 'package:sendit/features/wallet/wallet_screen.dart';

class MainScaffold extends StatefulWidget {
  final int startingIndex;

  const MainScaffold({super.key, this.startingIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.startingIndex;
  }

  List<Widget> get _screens => [
    HomePage(),
    WalletScreen(), // Replace with WalletScreen()
    PromoScreen(),  // Replace with PromoScreen()
    EarnScreen(),   // Replace with EarnScreen()
    ProfileScreen(),               // Profile Page Here
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfff8f8fa),  
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xffE68A34),
        unselectedItemColor: Colors.grey,
        onTap: _onNavTapped,
        items: [
          BottomNavigationBarItem(
            icon: NavIcon(
              unselectedAsset: 'assets/images/home-line.svg',
              selectedAsset: 'assets/images/home-solid.svg',
              isSelected: _selectedIndex == 0,), label: 'Home'),
          BottomNavigationBarItem(
            icon: NavIcon(
              unselectedAsset: 'assets/images/wallet-line.svg',
              selectedAsset: 'assets/images/wallet-solid.svg',
              isSelected: _selectedIndex == 1,), label: 'Wallet'),
          BottomNavigationBarItem(
            icon: NavIcon(
              unselectedAsset: 'assets/images/promo-line.svg',
              selectedAsset: 'assets/images/promo-solid.svg',
              isSelected: _selectedIndex == 2,), label: 'Promo'),
          BottomNavigationBarItem(
            icon: NavIcon(
              unselectedAsset: 'assets/images/earn-line.svg',
              selectedAsset: 'assets/images/earn-solid.svg',
              isSelected: _selectedIndex == 3,), label: 'Earn'),
          BottomNavigationBarItem(
            icon: NavIcon(
              unselectedAsset: 'assets/images/profile-circle.svg',
              selectedAsset: 'assets/images/profile-solid.svg',
              isSelected: _selectedIndex == 4,), label: 'Profile'),
        ],
      ),
    );
  }
}
