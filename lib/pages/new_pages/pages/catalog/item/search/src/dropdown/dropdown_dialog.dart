import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../../app_asset_lib.dart';
import '../../../../../../../back_button_custom.dart';
import '../../../../../../../themes.dart';
import '../helper_classes.dart';
import '../prepare_widget.dart';
import '../search_choices.dart';

/// Class mainly used internally to display the available choices. Cannot be
/// made private because of automated testing.
class DropdownDialog<T> extends StatefulWidget {
  /// See SearchChoices class.
  final List<DropdownMenuItem<T>>? items;

  /// See SearchChoices class.
  final Widget? hint;

  /// See SearchChoices class.
  final bool isCaseSensitiveSearch;

  /// See SearchChoices class.
  final dynamic closeButton;

  /// See SearchChoices class.
  final TextInputType? keyboardType;

  /// See SearchChoices class.
  final Function? searchFn;

  /// See SearchChoices class.
  final bool multipleSelection;

  /// See SearchChoices class.
  final List<int>? selectedItems;

  /// See SearchChoices class.
  final Function? displayItem;

  /// See SearchChoices class.
  final dynamic doneButton;

  /// See SearchChoices class.
  final Function? validator;

  /// See SearchChoices class.
  final bool dialogBox;

  /// See SearchChoices class.
  final PointerThisPlease<bool> displayMenu;

  /// See SearchChoices class.
  final BoxConstraints? menuConstraints;

  /// Function to be called whenever the dialogBox is popped or the menu gets
  /// closed.
  final Function? callOnPop;

  /// See SearchChoices class.
  final Color? menuBackgroundColor;

  /// Function called to update the parent screen when necessary. Calls
  /// setState.
  final Function? updateParent;

  /// See SearchChoices class.
  final TextStyle? style;

  /// See SearchChoices class.
  final Color? iconEnabledColor;

  /// See SearchChoices class.
  final Color? iconDisabledColor;

  /// See SearchChoices class.
  final bool rightToLeft;

  /// See SearchChoices class.
  final bool autofocus;

  /// Used for the setOpenDialog. This allows the dialogBox to be opened with
  /// search terms preset from an external button as shown in example `Single
  /// dialog open and set search terms`.
  final String initialSearchTerms;

  /// See SearchChoices class.
  final Widget Function(
    // Widget titleBar,
    Widget searchBar,
    Widget list,
    Widget closeButton,
    BuildContext dropDownContext,
  )? buildDropDownDialog;

  /// See SearchChoices class.
  final EdgeInsets? dropDownDialogPadding;

  /// See SearchChoices class.
  final InputDecoration? searchInputDecoration;

  /// See SearchChoices class.
  final int? itemsPerPage;

  /// See SearchChoices class.
  final PointerThisPlease<int>? currentPage;

  /// See SearchChoices class.
  final Widget Function(Widget listWidget, int totalFilteredItemsNb,
      Function updateSearchPage)? customPaginationDisplay;

  /// See SearchChoices class.
  final Future<Tuple2<List<DropdownMenuItem>, int>> Function(
      String? keyword,
      String? orderBy,
      bool? orderAsc,
      List<Tuple2<String, String>>? filters,
      int? pageNb)? futureSearchFn;

  /// See SearchChoices class.
  final Map<String, Map<String, dynamic>>? futureSearchOrderOptions;

  /// See SearchChoices class.
  final Map<String, Map<String, Object>>? futureSearchFilterOptions;

  /// See SearchChoices class.
  final List<T>? futureSelectedValues;

  /// See SearchChoices class.
  final dynamic emptyListWidget;

  /// See SearchChoices class.
  final Function? onTap;

  /// See SearchChoices class.
  final Function? futureSearchRetryButton;

  /// Allows to reset the scroll to the top of the list after changing the page
  final ScrollController listScrollController = ScrollController();

  /// See SearchChoices class.
  final int? searchDelay;

  /// Assigns the pop function.
  final Function giveMeThePop;

  /// See SearchChoices class.
  final Widget? clearSearchIcon;

  /// See SearchChoices class.
  final String? Function(List<T?>)? listValidator;

  /// See SearchChoices class.
  final Widget Function({
    required bool filter,
    required BuildContext context,
    required Function onPressed,
    int? nbFilters,
    bool? orderAsc,
    String? orderBy,
  })? buildFutureFilterOrOrderButton;

  /// See SearchChoices class.
  final Widget Function({
    required List<Tuple3<int, DropdownMenuItem, bool>> itemsToDisplay,
    required ScrollController scrollController,
    required bool thumbVisibility,
    required Widget emptyListWidget,
    required void Function(int index, T value, bool itemSelected) itemTapped,
    required Widget Function(DropdownMenuItem item, bool isItemSelected)
        displayItem,
  })? searchResultDisplayFn;

  DropdownDialog({
    Key? key,
    this.items,
    this.hint,
    this.isCaseSensitiveSearch = false,
    this.closeButton,
    this.keyboardType,
    this.searchFn,
    required this.multipleSelection,
    this.selectedItems,
    this.displayItem,
    this.doneButton,
    this.validator,
    required this.dialogBox,
    required this.displayMenu,
    this.menuConstraints,
    this.callOnPop,
    this.menuBackgroundColor,
    this.updateParent,
    this.style,
    this.iconEnabledColor,
    this.iconDisabledColor,
    required this.rightToLeft,
    required this.autofocus,
    required this.initialSearchTerms,
    this.buildDropDownDialog,
    this.dropDownDialogPadding,
    this.searchInputDecoration,
    this.itemsPerPage,
    this.currentPage,
    this.customPaginationDisplay,
    this.futureSearchFn,
    this.futureSearchOrderOptions,
    this.futureSearchFilterOptions,
    this.futureSelectedValues,
    this.emptyListWidget,
    this.onTap,
    this.futureSearchRetryButton,
    this.searchDelay,
    required this.giveMeThePop,
    this.clearSearchIcon,
    this.listValidator,
    this.buildFutureFilterOrOrderButton,
    this.searchResultDisplayFn,
  }) : super(key: key);

  @override
  _DropdownDialogState<T> createState() => _DropdownDialogState<T>();
}

class _DropdownDialogState<T> extends State<DropdownDialog> {
  TextEditingController txtSearch = TextEditingController();
  final TextStyle defaultButtonStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  List<int> shownIndexes = [];
  Function? searchFn;
  String? latestKeyword;

  bool futureSearch = false;

  PointerThisPlease<String?> orderBy = PointerThisPlease(null);

  PointerThisPlease<bool?> orderAsc = PointerThisPlease(null);

  PointerThisPlease<List<Tuple2<String, String>>?> filters =
      PointerThisPlease(null);

  Future<Tuple2<List<DropdownMenuItem>, int>>? latestFutureResult;
  List<dynamic>? latestFutureSearchArgs;

  int searchCount = 0;

  _DropdownDialogState();

  dynamic get selectedResult {
    if (futureSearch) {
      if (widget.multipleSelection) {
        return (widget.futureSelectedValues);
      }
      if (widget.futureSelectedValues!.isNotEmpty) {
        return (widget.futureSelectedValues!.first);
      }
      return (null);
    }

    return (widget.multipleSelection
        ? widget.selectedItems
        : widget.selectedItems?.isNotEmpty ?? false
            ? widget.items![widget.selectedItems?.first ?? 0].value
            : null);
  }

  void _updateShownIndexes(
    String? keyword,
  ) {
    assert(
        !futureSearch,
        "cannot update shown indexes while doing a network search as all"
        "returned are displayed (potentially with pagination)");
    if (keyword != null) {
      latestKeyword = keyword;
    }
    if (latestKeyword != null) {
      shownIndexes = searchFn!(latestKeyword, widget.items);
    }
  }

  @override
  void initState() {
    widget.giveMeThePop(pop);
    if (widget.futureSearchFn != null) {
      futureSearch = true;
    } else {
      if (widget.searchFn != null) {
        searchFn = widget.searchFn;
      } else {
        Function matchFn;
        if (widget.isCaseSensitiveSearch) {
          matchFn = (item, keyword) {
            return (item.value.toString().contains(keyword));
          };
        } else {
          matchFn = (item, keyword) {
            return (item.value
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()));
          };
        }
        searchFn = (keyword, items) {
          List<int> shownIndexes = [];
          int i = 0;
          for (var item in widget.items!) {
            if (matchFn(item, keyword) || (keyword?.isEmpty ?? true)) {
              shownIndexes.add(i);
            }
            i++;
          }
          return (shownIndexes);
        };
      }
      assert(searchFn != null);
    }
    widget.currentPage?.value = 1;
    if (widget.initialSearchTerms.isNotEmpty) {
      txtSearch.text = widget.initialSearchTerms;
      searchForKeyword(
        txtSearch.text,
        immediate: true,
      );
    } else {
      searchForKeyword(
        '',
        immediate: true,
      );
    }
    super.initState();
  }

  Widget wrapMenuIfDialogBox(Widget menuWidget) {
    if (!widget.dialogBox || SearchChoices.dialogBoxMenuWrapper == null) {
      return (menuWidget);
    }
    return (SearchChoices.dialogBoxMenuWrapper!(menuWidget));
  }

  @override
  Widget build(BuildContext dropdownDialogContext) {
    if (widget.buildDropDownDialog != null) {
      return (wrapMenuIfDialogBox(widget.buildDropDownDialog!(
        searchBar(),
        listWithPagination(),
        closeButtonWrapper(),
        dropdownDialogContext,
      )));
    }
    return wrapMenuIfDialogBox(AnimatedContainer(
      padding: widget.dropDownDialogPadding ??
          MediaQuery.of(dropdownDialogContext).viewInsets,
      duration: const Duration(milliseconds: 300),
      child: Card(
        // Изменение радиуса высплывающего окна
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        color: white,
        margin: EdgeInsets.zero,
        child: Container(
          color: white,
          constraints: widget.menuConstraints,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              searchBar(),
              listWithPagination(),
            ],
          ),
        ),
      ),
    ));
  }

  bool get valid {
    return (validResult == null);
  }

  String? get validResult {
    if (widget.listValidator != null) {
      return (widget.listValidator!(selectedResult));
    }
    if (widget.validator != null) {
      return (widget.validator!(selectedResult));
    }
    return (null);
  }

  /// По сути, разделяет поиск между поисковым Fn и будущим поисковым Fn
  /// случаями. Также применяется задержка поиска, если таковая имеется, если значение immediate не равно true.
  void searchForKeyword(
    String? keyword, {
    bool immediate = false,
  }) {
    doSearch() {
      if (futureSearch) {
        if (keyword != null) {
          latestKeyword = keyword;
        }
        _doFutureSearch(keyword);
      } else {
        _updateShownIndexes(keyword);
      }
      if (widget.listScrollController.hasClients) {
        widget.listScrollController.jumpTo(0);
      }
    }

    if ((widget.searchDelay ?? 0) > 0) {
      searchCount++;
      if (!immediate) {
        Future.delayed(Duration(milliseconds: widget.searchDelay ?? 0))
            .whenComplete(() {
          if (searchCount == 1) {
            doSearch();
            setState(() {});
          }
          searchCount--;
        });
      } else {
        doSearch();
        searchCount--;
      }
    } else {
      doSearch();
    }
  }

  /// Обновляет отображаемый список результатами сетевого поиска.
  Future<Tuple2<List<DropdownMenuItem>, int>>? _doFutureSearch(String? keyword,
      {bool force = false}) {
    bool filtersMatch = false;
    if (!force &&
        latestFutureSearchArgs != null &&
        (latestFutureSearchArgs![0] == (keyword ?? "") &&
            latestFutureSearchArgs![1] == (orderBy.value ?? "") &&
            latestFutureSearchArgs![2] == (orderAsc.value ?? true) &&
            latestFutureSearchArgs![4] == (widget.currentPage?.value ?? 1))) {
      if ((filters.value == null || filters.value!.isEmpty) &&
          (latestFutureSearchArgs![3] == null ||
              (latestFutureSearchArgs![3] as List<Tuple2<String, String>>)
                  .isEmpty)) {
        filtersMatch = true;
      } else {
        filtersMatch = true;
        List<dynamic> oldFiltersDyn =
            (latestFutureSearchArgs![3] ?? []) as List<dynamic>;
        List<Tuple2<String, String>> oldFilters = [];
        if (oldFiltersDyn.isNotEmpty) {
          oldFilters = oldFiltersDyn
              .map<Tuple2<String, String>>((e) => Tuple2<String, String>(
                  (e as Tuple2<String, String>).item1, (e).item2))
              .toList();
        }
        filters.value?.forEach((filter) {
          if (!oldFilters.any((element) => (element.item1 == filter.item1 &&
              element.item2 == filter.item2))) {
            filtersMatch = false;
          }
        });
        if (filtersMatch) {
          for (var filter in oldFilters) {
            if (!filters.value!.any((element) =>
                (element.item1 == filter.item1 &&
                    element.item2 == filter.item2))) {
              filtersMatch = false;
            }
          }
        }
      }
    }
    if (filtersMatch) {
      return (latestFutureResult);
    }
    latestFutureSearchArgs = [
      String.fromCharCodes(keyword?.runes ?? []),
      String.fromCharCodes(orderBy.value?.runes ?? []),
      orderAsc.value ?? true ? true : false,
      filters.value
          ?.map((e) => Tuple2<String, String>(
              String.fromCharCodes(e.item1.runes),
              String.fromCharCodes(e.item2.runes)))
          .toList(),
      widget.currentPage?.value ?? 1
    ];
    latestFutureResult = widget.futureSearchFn!(
      keyword,
      orderBy.value,
      orderAsc.value,
      filters.value,
      widget.currentPage?.value ?? 1,
    );
    return (latestFutureResult);
  }

  /// Панель поиска, в которой пользователь может ввести текст для поиска элементов для выбора.
  Widget searchBar() {
    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                width: 1,
                color: borderPrimary,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                      AssetLib.searchButton,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      textDirection: widget.rightToLeft
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      controller: txtSearch,
                      cursorColor: black,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(0),
                        hintText: "",
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: w500,
                          color: gray,
                          fontFamily: "InterTight",
                        ),
                        fillColor: transparent,
                        filled: true,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      style: widget.style,
                      autofocus: widget.autofocus,
                      onChanged: (value) {
                        widget.currentPage?.value = 1;
                        searchForKeyword(value);
                        setState(() {});
                      },
                      keyboardType: widget.keyboardType,
                    ),
                  ),
                  AppBarButtonCustom(
                    asset: AssetLib.microphoneButton,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        closeButtonWrapper(),
      ],
    );
  }

  /// Закрывает диалоговое окно или меню в зависимости от выбранного режима.
  pop() {
    if (widget.dialogBox) {
      Navigator.pop(context);
    } else {
      widget.displayMenu.value = false;
      if (widget.callOnPop != null) {
        widget.callOnPop!();
      }
    }
  }

  void deselectItem(int index, T value) {
    if (futureSearch) {
      if (value is Map) {
        widget.futureSelectedValues
            ?.removeWhere((element) => mapEquals(element, value));
      } else {
        widget.futureSelectedValues?.remove(value);
      }
    } else {
      widget.selectedItems?.remove(index);
    }
  }

  void selectItem(int index, T value) {
    if (!widget.multipleSelection) {
      if (futureSearch) {
        widget.futureSelectedValues?.clear();
      } else {
        widget.selectedItems?.clear();
      }
    }
    if (futureSearch) {
      widget.futureSelectedValues?.add(value);
    } else {
      widget.selectedItems?.add(index);
    }
  }

  void itemTapped(int index, T value, bool itemSelected) {
    if (!futureSearch) {
      if (widget.items?[index].onTap != null) {
        widget.items?[index].onTap!();
      }
    }
    if (widget.multipleSelection && itemSelected) {
      setState(() {
        deselectItem(index, value);
      });
    } else {
      selectItem(index, value);
      if (!widget.multipleSelection && widget.doneButton == null) {
        pop();
      } else {
        setState(() {});
      }
    }
  }

  /// Returns whether an item is selected. Relies on index in case of non future
  /// list of items.
  bool isItemSelected(int index, T value) {
    if (futureSearch) {
      if (value is Map) {
        return (widget.futureSelectedValues!
            .any((element) => mapEquals(element, value)));
      }
      return (widget.futureSelectedValues!.contains(value));
    }
    return (widget.selectedItems?.contains(index) ?? false);
  }

  /// Returns the Widget as displayed in the list of items from the selected or
  /// non selected DropdownMenuItem.
  Widget displayItem(
    DropdownMenuItem item,
    bool isItemSelected,
  ) {
    Widget? displayItemResult;
    if (widget.displayItem != null) {
      try {
        displayItemResult = widget.displayItem!(item, isItemSelected);
      } on NoSuchMethodError {
        displayItemResult = widget.displayItem!(item, isItemSelected, (
          value, [
          bool pop = false,
        ]) {
          updateParentWithOptionalPop(value, pop);
          widget.currentPage?.value = 1;
          searchForKeyword(
            null,
            immediate: true,
          );
        });
      }
      return (displayItemResult!);
    }
    return widget.multipleSelection
        ? (Row(
            textDirection:
                widget.rightToLeft ? TextDirection.rtl : TextDirection.ltr,
            children: [
                Icon(
                  isItemSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
                const SizedBox(
                  width: 7,
                ),
                Flexible(child: item),
              ]))
        : item;
  }

  /// Builds the list display from the given list of [DropdownMenuItem] along
  /// with the [bool] indicating whether the item is selected or not and the
  /// [int] as the index in the [selectedItems] list.
  Widget listDisplay(
      List<Tuple3<int, DropdownMenuItem<dynamic>, bool>> itemsToDisplay) {
    if (widget.searchResultDisplayFn != null) {
      return widget.searchResultDisplayFn!(
        itemsToDisplay: itemsToDisplay,
        scrollController: widget.listScrollController,
        thumbVisibility: widget.itemsPerPage == null ? false : true,
        emptyListWidget: emptyList(),
        itemTapped: itemTapped as Function(int, dynamic, bool),
        displayItem: displayItem,
      );
    }
    return Expanded(
      child: Scrollbar(
        controller: widget.listScrollController,
        thumbVisibility: widget.itemsPerPage == null ? false : true,
        child: itemsToDisplay.isEmpty
            ? emptyList()
            : ListView.builder(
                controller: widget.listScrollController,
                itemBuilder: (context, index) {
                  int itemIndex = itemsToDisplay[index].item1;
                  DropdownMenuItem item = itemsToDisplay[index].item2;
                  bool isItemSelected = itemsToDisplay[index].item3;

                  // Ваш код, который нужно добавить перед каждым элементом
                  Widget customCodeBeforeItem = Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: GestureDetector(
                      onTap: () {
                        // Ваш обработчик нажатия
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Раньше вы искали",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: w400,
                              color: black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Очистить",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: w400,
                                color: blue,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );

                  // Возвращаем Column, объединяющий ваш код и displayItem
                  return Column(
                    children: [
                      if (index == 0) customCodeBeforeItem,
                      Material(
                        child: InkWell(
                          splashColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          onTap: () {
                            itemTapped(
                              itemIndex,
                              item.value,
                              isItemSelected,
                            );
                          },
                          child: displayItem(
                            item,
                            isItemSelected,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                itemCount: itemsToDisplay.length,
              ),
      ),
    );
  }

  /// Is the current page the first page (==1)?
  bool isFirstPage() {
    return (widget.currentPage!.value == 1);
  }

  /// Is the current page the last one? The [totalNbItemsToPage] argument is the
  /// total number of items to be displayed once the filters are applied on all
  /// the pages.
  bool isLastPage(int totalNbItemsToPage) {
    return (widget.currentPage!.value >=
        (totalNbItemsToPage / widget.itemsPerPage!).ceil());
  }

  /// Provides a button to go to previous page taking into account the RTL. The
  /// button updates the search page through the given [updateSearchPage].
  Widget previousPageButton(Function updateSearchPage) {
    return (IconButton(
      icon: Icon(
        widget.rightToLeft ? Icons.chevron_right : Icons.chevron_left,
        color: isFirstPage() ? Colors.grey : Colors.blue,
      ),
      onPressed: isFirstPage()
          ? null
          : () {
              widget.currentPage!.value--;
              updateSearchPage();
            },
    ));
  }

  /// Provides a button to go to next page taking into account the RTL. The
  /// button updates the search page through the given [updateSearchPage]. The
  /// [totalNbItemsToPage] argument is the total number of items to be displayed
  /// once the filters are applied on all the pages.
  Widget nextPageButton(Function updateSearchPage, int totalNbItemsToPage) {
    return (IconButton(
      icon: Icon(
        widget.rightToLeft ? Icons.chevron_left : Icons.chevron_right,
        color: isLastPage(totalNbItemsToPage) ? Colors.grey : Colors.blue,
      ),
      onPressed: isLastPage(totalNbItemsToPage)
          ? null
          : () {
              widget.currentPage!.value++;
              updateSearchPage();
            },
    ));
  }

  /// Returns the [Widget] with the given [scrollBar] paginated either through
  /// the widget.customPaginationDisplay function or through the standard
  /// pagination function which takes into account RTL. The button updates the
  /// search page through the given [updateSearchPage]. The [totalNbItemsToPage]
  /// argument is the total number of items to be displayed once the filters are
  /// applied on all the pages.
  Widget paginatedResults(
      Widget scrollBar, Function updateSearchPage, int totalNbItemsToPage) {
    if (widget.customPaginationDisplay != null) {
      return (widget.customPaginationDisplay!(
          scrollBar, totalNbItemsToPage, updateSearchPage));
    }

    return (Expanded(
        child: Column(children: [
      const SizedBox(
        height: 10,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        widget.rightToLeft
            ? nextPageButton(updateSearchPage, totalNbItemsToPage)
            : previousPageButton(updateSearchPage),
        Text("${widget.currentPage!.value}"
            "/${(totalNbItemsToPage / widget.itemsPerPage!).ceil()}"),
        widget.rightToLeft
            ? previousPageButton(updateSearchPage)
            : nextPageButton(updateSearchPage, totalNbItemsToPage),
      ]),
      scrollBar,
    ])));
  }

  /// Returns what is displayed in case the list is empty
  Widget emptyList() {
    if (widget.emptyListWidget != null) {
      Widget? ret = prepareWidget(
        widget.emptyListWidget,
        parameter: latestKeyword,
        updateParent: () {
          setState(() {});
        },
        context: context,
        stringToWidgetFunction: (String message) => Center(
          child: Text(
            message,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
      if (ret != null) {
        return (ret);
      }
    }
    if (futureSearch) {
      return (const Text("-"));
    }
    return (const SizedBox.shrink());
  }

  /// Displays the list of items filtered based on the search terms with
  /// pagination.
  Widget listWithPagination() {
    List<int> pagedShownIndexes = [];
    bool displayPages = true;
    if (!futureSearch) {
      if (widget.itemsPerPage == null ||
          widget.itemsPerPage! >= shownIndexes.length) {
        pagedShownIndexes = shownIndexes;
        displayPages = false;
      } else {
        if (widget.currentPage!.value < 1 ||
            widget.currentPage!.value >
                (shownIndexes.length / widget.itemsPerPage!).ceil()) {
          widget.currentPage!.value = 1;
        }
        for (int i = widget.itemsPerPage! * (widget.currentPage!.value - 1);
            i < widget.itemsPerPage! * (widget.currentPage!.value) &&
                i < shownIndexes.length;
            i++) {
          pagedShownIndexes.add(shownIndexes[i]);
        }
      }
    } else {
      if (widget.itemsPerPage == null) {
        displayPages = false;
      }
    }

    List<Tuple3<int, DropdownMenuItem<dynamic>, bool>> itemsToDisplay;

    updateSearchPage() {
      searchForKeyword(
        latestKeyword,
        immediate: true,
      );
      setState(() {});
    }

    if (futureSearch) {
      Widget? errorRetryButton;
      if (widget.futureSearchRetryButton != null) {
        errorRetryButton = prepareWidget(
          widget.futureSearchRetryButton,
          parameter: () {
            _doFutureSearch(latestKeyword, force: true);
          },
        );
      } else {
        errorRetryButton = Column(children: [
          const SizedBox(height: 15),
          Center(
            child: ElevatedButton.icon(
                onPressed: () {
                  _doFutureSearch(latestKeyword, force: true);
                },
                icon: const Icon(Icons.repeat),
                label: const Text("Error - retry")),
          )
        ]);
      }
      return (FutureBuilder(
        future: _doFutureSearch(latestKeyword),
        builder: (context,
            AsyncSnapshot<Tuple2<List<DropdownMenuItem>, int>> snapshot) {
          if (snapshot.hasError) {
            return (errorRetryButton!);
          }
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return (const Column(children: [
              SizedBox(height: 15),
              Center(
                child: CircularProgressIndicator(),
              )
            ]));
          }
          if (snapshot.data == null) {
            return (const Column(children: [
              SizedBox(height: 15),
              Center(
                child: Text("-"),
              )
            ]));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Tuple2<List<DropdownMenuItem>, int> data = snapshot.data!;
            int nbResults = data.item2;
            if (data.item1.isEmpty) {
              return (Column(children: [
                const SizedBox(height: 15),
                Center(
                  child: emptyList(),
                )
              ])); //no results
            }
            itemsToDisplay = data.item1
                .map<Tuple3<int, DropdownMenuItem<dynamic>, bool>>(
                    (DropdownMenuItem item) {
              return (Tuple3<int, DropdownMenuItem<dynamic>, bool>(
                  -1, item, isItemSelected(-1, item.value!)));
            }).toList();
            Widget scrollBar = listDisplay(itemsToDisplay);
            if (widget.itemsPerPage == null ||
                nbResults <= itemsToDisplay.length) {
              return (scrollBar);
            }

            // Handle the pagination
            return (paginatedResults(
              scrollBar,
              updateSearchPage,
              nbResults,
            ));
          }
          print("connection state: ${snapshot.connectionState.toString()}");
          return (errorRetryButton!);
        },
      ));
    }

    itemsToDisplay = pagedShownIndexes
        .map<Tuple3<int, DropdownMenuItem<T>, bool>>((int index) {
      return (Tuple3<int, DropdownMenuItem<T>, bool>(
          index,
          widget.items![index] as DropdownMenuItem<T>,
          isItemSelected(index, widget.items![index].value)));
    }).toList();
    Widget scrollBar = listDisplay(itemsToDisplay);

    if (!displayPages) {
      return (scrollBar);
    }

    return (paginatedResults(
      scrollBar,
      updateSearchPage,
      shownIndexes.length,
    ));
  }

  /// Returns the close button after the list of items or its replacement.
  Widget closeButtonWrapper() {
    return (prepareWidget(widget.closeButton,
            parameter: selectedResult, context: context, updateParent: (
          sel, [
          bool pop = false,
        ]) {
          updateParentWithOptionalPop(sel, pop);
          setState(() {});
        }, stringToWidgetFunction: (string) {
          return (Row(
            textDirection:
                widget.rightToLeft ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => pop(),
                child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width / 2),
                    child: Text(
                      "Отменить",
                      textDirection: widget.rightToLeft
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: w400,
                        color: black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )),
              )
            ],
          ));
        }) ??
        const SizedBox.shrink());
  }

  updateParentWithOptionalPop(
    value, [
    bool pop = false,
  ]) {
    widget.updateParent!(value);
    if (pop) {
      this.pop();
    }
  }
}
