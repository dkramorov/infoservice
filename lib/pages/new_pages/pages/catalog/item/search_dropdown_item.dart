import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app_asset_lib.dart';
import '../../../../themes.dart';
import '../catalog_page.dart';

class SearchDropdownItem extends StatelessWidget {
  const SearchDropdownItem({required this.location, super.key});
  final ParkingLocation location;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location.value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: w400,
              color: black,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: SvgPicture.asset(AssetLib.close2),
          ),
        ],
      ),
    );
  }
}
