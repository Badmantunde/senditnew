import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavIcon extends StatelessWidget {
  final String selectedAsset;
  final String unselectedAsset;
  final bool isSelected;

  const NavIcon({
    required this.selectedAsset,
    required this.unselectedAsset,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      isSelected ? selectedAsset : unselectedAsset,
      width: 24,
      height: 24,
    );
  }
}
