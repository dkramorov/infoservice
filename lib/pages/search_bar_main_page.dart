import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infoservice/pages/new_pages/pages/catalog/item/search/src/search_choices.dart';

import 'app_asset_lib.dart';
import '../navigation/custom_app_bar_button.dart';
import 'gl.dart';
import 'themes.dart';

class SearchBarMainPageWidget extends StatelessWidget {
  const SearchBarMainPageWidget(this.dropdownItems,
      {required this.onChanged, required this.onMicrophone, super.key});

  final List<DropdownMenuItem<String>> dropdownItems;
  final Function(dynamic) onChanged;
  final VoidCallback onMicrophone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            width: 1,
            color: borderPrimary,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(AssetLib.searchButton),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SearchChoices.single(
                dropDownDialogPadding: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                items: dropdownItems,
                value: '',
                hint: inp,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: w400,
                  color: Colors.black,
                  fontFamily: 'GolosText',
                  overflow: TextOverflow.ellipsis,
                ),
                searchHint: 'Поиск компании',
                onChanged: onChanged,
                isExpanded: true,
              ),
            ),
            CustomAppBarButton(
              asset: AssetLib.microphoneButton,
              onPressed: onMicrophone,
            ),
          ],
        ),
      ),
    );
  }
}
