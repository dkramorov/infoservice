import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../models/companies/search.dart';
import '../../pages/app_asset_lib.dart';
import '../../pages/themes.dart';
import '../../services/jabber_manager.dart';

class CompaniesFloatingSearchWidget extends StatefulWidget {
  final JabberManager? _helper;
  const CompaniesFloatingSearchWidget(this._helper, {Key? key})
      : super(key: key);

  @override
  _CompaniesFloatingSearchWidgetState createState() =>
      _CompaniesFloatingSearchWidgetState();
}

class _CompaniesFloatingSearchWidgetState
    extends State<CompaniesFloatingSearchWidget> {
  late SearchModel searchModel;
  bool searchProcessing = false;
  List<Widget> searchResult = [];

  List<DropdownMenuItem<String>> dropdownItems = [];

  JabberManager? get helper => widget._helper;

  @override
  void initState() {
    searchModel =
        SearchModel(setStateCallback: setStateCallback, xmppHelper: helper);
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {
      if (state['searchResult'] != null) {
        searchResult = state['searchResult'];
      }
      if (state['searchProcessing'] != null) {
        searchProcessing = state['searchProcessing'];
      }
    });
  }

  List<Widget> buildEmptyResult() {
    return [
      const Padding(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: Text('Ничего не найдено'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      margins: const EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 20.0,
      ),
      padding: const EdgeInsets.only(
        left: 15.0,
        right: 10.0,
      ),
      hint: 'Поиск...',
      backgroundColor: white,
      clearQueryOnClose: true,
      automaticallyImplyBackButton: false,
      iconColor: Colors.grey,
      progress: searchProcessing,
      onQueryChanged: (query) async {
        setState(() {
          searchProcessing = true;
        });
        await searchModel.onQueryChanged(query);
        setState(() {
          searchProcessing = false;
        });
      },
      //controller: controller,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 36),
      //transitionDuration: const Duration(milliseconds: 800),
      //transitionCurve: Curves.easeInOut,
      //transition: CircularFloatingSearchBarTransition(),
      isScrollControlled: true,
      backdropColor: Colors.black12,

      //physics: const BouncingScrollPhysics(),
      //axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      // не надо максималить - пусть на весь экран будет
      //maxWidth: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),

      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          showIfClosed: true,
          child: CircularButton(
            icon: SvgPicture.asset(AssetLib.searchButton),
            onPressed: () {},
          ),
        ),
        /*
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
        */
        FloatingSearchBarAction.closeAction(
          showIfClosed: false,
          icon: SvgPicture.asset(AssetLib.close2),
        ),
      ],
      builder: (context, transition) {
        int searchResultCount = searchResult.length;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: ListView(
              /*
              children: Colors.accents.map((color) {
                return Container(
                  height: 112,
                  width: double.infinity,
                  color: color,
                  child: const Text(
                    '---',
                  ),
                );
              }).toList(),
              */
              children:
                  searchResultCount > 0 ? searchResult : buildEmptyResult(),
            ),
          ),
        );
      },
    );
  }
}

/* Подложка для поиска */
Widget buildPanelForSearch() {
  return ClipRRect(
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(12.0),
      bottomRight: Radius.circular(12.0),
    ),
    child: Container(
      height: 90.0,
      //color: tealColor,
      color: white,
    ),
  );
}
