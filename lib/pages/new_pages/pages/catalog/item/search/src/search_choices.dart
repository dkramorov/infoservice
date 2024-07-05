import 'package:flutter/material.dart';
import 'dart:core';

import '../../../../../../gl.dart';
import '../../../../../../themes.dart';
import 'dropdown/dropdown_dialog.dart';
import 'helper_classes.dart';
import 'prepare_widget.dart';

class SearchChoices<T> extends FormField<T> {
  static Widget Function(Widget)? dialogBoxMenuWrapper;

  final List<DropdownMenuItem<T>>? items;

  final Function? onChanged;

  final T? value;
  final TextStyle? style;

  final dynamic searchHint;

  final dynamic hint;

  final dynamic disabledHint;

  final dynamic underline;

  final dynamic doneButton;

  final dynamic label;

  final dynamic closeButton;

  final bool displayClearIcon;

  final Color? iconEnabledColor;
  final Color? iconDisabledColor;

  final double iconSize;

  final bool isExpanded;

  final bool isCaseSensitiveSearch;

  final Function? searchFn;

  final Function? onClear;

  final Function? selectedValueWidgetFn;

  /// [keyboardType] used for the search.
  final TextInputType keyboardType;

  final String? Function(T?)? validator;

  final bool multipleSelection;

  final List<int> selectedItems;

  final Function? displayItem;

  final bool dialogBox;

  final BoxConstraints? menuConstraints;

  final bool readOnly;

  final Color? menuBackgroundColor;

  final bool? rightToLeft;

  final bool autofocus;

  final Function? selectedAggregateWidgetFn;

  final dynamic padding;

  final Function? setOpenDialog;

  final Widget Function(
    Widget titleBar,
    Widget searchBar,
    Widget list,
    Widget closeButton,
    BuildContext dropDownContext,
  )? buildDropDownDialog;

  final EdgeInsets? dropDownDialogPadding;

  final InputDecoration? searchInputDecoration;

  final int? itemsPerPage;

  final PointerThisPlease<int>? currentPage;

  final Widget Function(Widget listWidget, int totalFilteredItemsNb,
      Function updateSearchPage)? customPaginationDisplay;

  final Future<Tuple2<List<DropdownMenuItem>, int>> Function(
      String? keyword,
      String? orderBy,
      bool? orderAsc,
      List<Tuple2<String, String>>? filters,
      int? pageNb)? futureSearchFn;

  final Map<String, Map<String, dynamic>>? futureSearchOrderOptions;

  final Map<String, Map<String, Object>>? futureSearchFilterOptions;

  final List<T>? futureSelectedValues;

  final dynamic emptyListWidget;

  final Function? onTap;

  final Function? futureSearchRetryButton;

  final int? searchDelay;

  final Widget Function(Widget fieldWidget, {bool selectionIsValid})?
      fieldPresentationFn;

  final Decoration? fieldDecoration;

  final Widget? clearSearchIcon;

  final Future<void> Function(
    BuildContext context,
    Widget Function({
      String searchTerms,
    }) menuWidget,
    String searchTerms,
  )? showDialogFn;

  final FormFieldSetter<T>? onSaved;

  final String? Function(List<T?>)? listValidator;

  final AutovalidateMode autovalidateMode;

  final String? restorationId;

  final Function(Function pop)? giveMeThePop;
  final Widget Function({
    required bool filter,
    required BuildContext context,
    required Function onPressed,
    int? nbFilters,
    bool? orderAsc,
    String? orderBy,
  })? buildFutureFilterOrOrderButton;
  final Widget Function({
    required List<Tuple3<int, DropdownMenuItem, bool>> itemsToDisplay,
    required ScrollController scrollController,
    required bool thumbVisibility,
    required Widget emptyListWidget,
    required void Function(int index, T value, bool itemSelected) itemTapped,
    required Widget Function(DropdownMenuItem item, bool isItemSelected)
        displayItem,
  })? searchResultDisplayFn;
  SearchChoices.single({
    Key? key,
    this.items,
    this.onChanged,
    this.value,
    this.style,
    this.searchHint,
    this.hint,
    this.disabledHint,
    // this.icon = const Icon(Icons.arrow_drop_down),
    this.underline,
    this.doneButton,
    this.label,
    this.closeButton = "Close",
    this.displayClearIcon = true,
    // this.clearIcon = const Icon(Icons.clear),
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.iconSize = 24.0,
    this.isExpanded = false,
    this.isCaseSensitiveSearch = false,
    this.searchFn,
    this.onClear,
    this.selectedValueWidgetFn,
    this.keyboardType = TextInputType.text,
    this.validator,
    @deprecated bool assertUniqueValue = true,
    this.displayItem,
    this.dialogBox = true,
    this.menuConstraints,
    this.readOnly = false,
    this.menuBackgroundColor,
    this.rightToLeft,
    this.autofocus = true,
    this.selectedAggregateWidgetFn,
    this.padding,
    this.setOpenDialog,
    this.buildDropDownDialog,
    this.dropDownDialogPadding,
    this.searchInputDecoration,
    this.itemsPerPage,
    this.currentPage,
    this.customPaginationDisplay,
    this.futureSearchFn,
    this.futureSearchOrderOptions,
    this.futureSearchFilterOptions,
    this.emptyListWidget,
    this.onTap,
    this.futureSearchRetryButton,
    this.searchDelay,
    this.fieldPresentationFn,
    this.fieldDecoration,
    this.clearSearchIcon,
    this.showDialogFn,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.restorationId,
    this.giveMeThePop,
    this.buildFutureFilterOrOrderButton,
    this.searchResultDisplayFn,
  })  : multipleSelection = false,
        selectedItems = const [],
        futureSelectedValues = null,
        listValidator = null,
        super(
          key: key,
          builder: (FormFieldState<dynamic> state) {
            _SearchChoicesState<T> sCState = state as _SearchChoicesState<T>;
            return (sCState.buildWidget(sCState.context));
          },
          onSaved: onSaved,
          validator: validator,
          initialValue: value,
          enabled: (items?.isNotEmpty ?? false || futureSearchFn != null) &&
              (onChanged != null || onChanged is Function),
          autovalidateMode: autovalidateMode,
          restorationId: restorationId,
        ) {
    checkPreconditions();
  }

  checkPreconditions() {
    assert(!multipleSelection || doneButton != null);
    assert(menuConstraints == null || !dialogBox);
    assert(itemsPerPage == null || currentPage != null,
        "currentPage must be given if itemsPerPage is given");
    assert(
        dropDownDialogPadding == null || buildDropDownDialog == null,
        "buildDropDownDialog and dropDownDialogPadding cannot be set at"
        " the same time");
    assert(dialogBox || dropDownDialogPadding == null,
        "dropDownDialogPadding must be null if dialogBox == false");
    assert(
        futureSearchOrderOptions == null || futureSearchFn != null,
        "futureSearchOrderOptions is of no use if futureSearchFn is not "
        "set");
    assert(
        futureSearchFilterOptions == null || futureSearchFn != null,
        "futureSearchFilterOptions is of no use if futureSearchFn is not "
        "set");
    assert(futureSearchFn == null || searchFn == null,
        "futureSearchFn and searchFn cannot work together");
    assert((futureSearchFn == null) != (items == null),
        "must either have futureSearchFn or items but not both");
    assert(
        futureSearchFn == null ||
            (multipleSelection
                ? (futureSelectedValues != null && value == null)
                : (true && futureSelectedValues == null)),
        "${multipleSelection ? "futureSelectedValues" : "value"} must be set if futureSearchFn is set in ${multipleSelection ? "multiple" : "single"} selection mode while ${multipleSelection ? "value" : "futureSelectedValues"} must not be set");
    assert(fieldDecoration == null || underline == null,
        "use either underline or fieldDecoration");
    assert(fieldPresentationFn == null || underline == null,
        "use either underline or fieldPresentationFn");
    assert(fieldDecoration == null || padding == null,
        "use either padding or fieldDecoration");
    assert(fieldPresentationFn == null || padding == null,
        "use either padding or fieldPresentationFn");
    assert(dialogBox || showDialogFn == null,
        "use showDialogFn only with dialogBox");
  }

  bool get isEnabled =>
      (items?.isNotEmpty ?? false || futureSearchFn != null) &&
      (onChanged != null || onChanged is Function);

  @override
  _SearchChoicesState<T> createState() => _SearchChoicesState<T>();
}

class _SearchChoicesState<T> extends FormFieldState<T> {
  List<int>? selectedItems;
  PointerThisPlease<bool> displayMenu = PointerThisPlease<bool>(false);
  Function? updateParent;

  List<T> futureSelectedValues = [];

  Function? pop;

  @override
  SearchChoices<T> get widget => super.widget as SearchChoices<T>;

  bool get rightToLeft =>
      widget.rightToLeft ??
      Directionality.maybeOf(context) == TextDirection.rtl;

  void giveMeThePop(Function pop) {
    this.pop = pop;
    if (widget.giveMeThePop != null) {
      widget.giveMeThePop!(pop);
    }
  }

  TextStyle get _textStyle =>
      widget.style ??
      (_enabled && !(widget.readOnly)
          ? Theme.of(context).textTheme.titleMedium
          : Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: _disabledIconColor)) ??
      const TextStyle();
  bool get _enabled => widget.isEnabled;
  Color? get _disabledIconColor {
    if (widget.iconDisabledColor != null) {
      return widget.iconDisabledColor;
    }
    switch (Theme.of(context).brightness) {
      case Brightness.light:
        return Colors.grey.shade400;
      case Brightness.dark:
        return Colors.white10;
    }
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

  bool get hasSelection {
    if (widget.futureSearchFn != null) {
      return (futureSelectedValues.isNotEmpty);
    }
    return (selectedItems != null && ((selectedItems?.isNotEmpty) ?? true));
  }

  dynamic get selectedResult {
    if (widget.futureSearchFn != null) {
      if (widget.multipleSelection) {
        return (futureSelectedValues);
      }
      if (futureSelectedValues.isNotEmpty) {
        return (futureSelectedValues.first);
      }
      return (null);
    }
    return (widget.multipleSelection
        ? selectedItems
        : selectedItems?.isNotEmpty ?? false
            ? widget.items![selectedItems?.first ?? 0].value
            : null);
  }

  void updateSelectedItems({dynamic sel = const NotGiven()}) {
    if (widget.futureSearchFn != null) {
      return;
    }
    List<int>? updatedSelectedItems;
    if (widget.multipleSelection) {
      if (sel is! NotGiven) {
        updatedSelectedItems = sel as List<int>;
      } else {
        updatedSelectedItems = List<int>.from(widget.selectedItems);
      }
    } else {
      T? val = sel is! NotGiven ? sel as T? : widget.value;
      if (val != null) {
        int? i = indexFromValue(val);
        if (i != null && i != -1) {
          updatedSelectedItems = [i];
        }
      } else {
        updatedSelectedItems = null;
      }
      updatedSelectedItems ??= [];
    }
    selectedItems?.retainWhere((element) =>
        updatedSelectedItems?.any((selected) => selected == element) ?? false);
    for (var selected in updatedSelectedItems) {
      if (!(selectedItems?.any((element) => selected == element) ?? true)) {
        selectedItems?.add(selected);
      }
    }
  }

  void updateSelectedValues({dynamic sel = const NotGiven()}) {
    if (widget.futureSearchFn == null) {
      return;
    }
    List<T>? updatedFutureSelectedValues;
    if (widget.multipleSelection) {
      if (sel is! NotGiven) {
        updatedFutureSelectedValues = sel as List<T>;
      } else {
        updatedFutureSelectedValues =
            List<T>.from(widget.futureSelectedValues!);
      }
    } else {
      T? val = sel is! NotGiven ? sel as T : widget.value;
      if (val != null) {
        updatedFutureSelectedValues = [val];
      }
      updatedFutureSelectedValues ??= [];
    }
    futureSelectedValues.retainWhere((element) =>
        updatedFutureSelectedValues?.any((selected) => selected == element) ??
        false);
    for (var selected in updatedFutureSelectedValues) {
      if (!(futureSelectedValues.any((element) => selected == element))) {
        futureSelectedValues.add(selected);
      }
    }
  }

  int? indexFromValue(T value) {
    assert(widget.futureSearchFn == null,
        "got a futureSearchFn with a call to indexFromValue");
    return (widget.items!.indexWhere((item) {
      return (item.value == value);
    }));
  }

  void sendSelection(dynamic selection, [BuildContext? onChangeContext]) {
    if (widget.validator != null || widget.listValidator != null) {
      try {
        didChange(selection);
      } catch (e, st) {
        if (!widget.multipleSelection) {
          debugPrint(
              "Warning: didChange call threw an error: ${e.toString()} ${st.toString()} You may want to reconsider the declared types otherwise the form validation may not consider this field properly.");
        } else {
          debugPrint(
              "Warning: SearchChoices multipleSelection doesn't fully support Form didChange call.");
        }
      }
    }
    try {
      widget.onChanged!(selection);
    } catch (e) {
      try {
        widget.onChanged!(selection, onChangeContext);
      } catch (e) {
        try {
          widget.onChanged!(selection, pop);
        } catch (e) {
          try {
            widget.onChanged!(selection, onChangeContext, pop);
          } catch (e) {}
        }
      }
    }
  }

  @override
  void initState() {
    if (widget.setOpenDialog != null) {
      widget.setOpenDialog!(showDialogOrMenu);
    }
    if (widget.futureSearchFn != null) {
      futureSelectedValues = [];
      if (widget.futureSelectedValues != null) {
        futureSelectedValues.addAll(widget.futureSelectedValues!);
      }
      updateParent = (sel) {
        if (sel is! NotGiven) {
          sendSelection(sel, context);
          updateSelectedValues(sel: sel);
        }
      };
      updateSelectedValues();
    } else {
      selectedItems = [];
      selectedItems?.addAll(widget.selectedItems);
      updateParent = (sel) {
        if (sel is! NotGiven) {
          sendSelection(sel, context);
          updateSelectedItems(sel: sel);
        }
      };
      updateSelectedItems();
    }
    super.initState();
  }

  updateParentWithOptionalPop(
    value, [
    bool pop = false,
  ]) {
    updateParent!(value);
    if (pop && this.pop != null) {
      this.pop!();
    }
  }

  @override
  void didUpdateWidget(SearchChoices<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.futureSearchFn != null) {
      updateSelectedValues();
    } else {
      updateSelectedItems();
    }
  }

  Widget menuWidget({String searchTerms = ""}) {
    return StatefulBuilder(
        builder: (BuildContext menuContext, StateSetter setStateFromBuilder) {
      return (DropdownDialog(
        items: widget.items,
        hint: prepareWidget(widget.searchHint),
        isCaseSensitiveSearch: widget.isCaseSensitiveSearch,
        closeButton: widget.closeButton,
        keyboardType: widget.keyboardType,
        searchFn: widget.searchFn,
        multipleSelection: widget.multipleSelection,
        selectedItems: selectedItems,
        doneButton: widget.doneButton,
        displayItem: widget.displayItem,
        validator: widget.validator,
        dialogBox: widget.dialogBox,
        displayMenu: displayMenu,
        menuConstraints: widget.menuConstraints,
        menuBackgroundColor: widget.menuBackgroundColor,
        style: widget.style,
        iconEnabledColor: widget.iconEnabledColor,
        iconDisabledColor: widget.iconDisabledColor,
        callOnPop: () {
          giveMeThePop(() {});
          if (!widget.dialogBox &&
              widget.onChanged != null &&
              selectedResult != null) {
            sendSelection(selectedResult, menuContext);
          }
          setState(() {});
        },
        updateParent: (value) {
          updateParent!(value);
          setStateFromBuilder(() {});
        },
        rightToLeft: rightToLeft,
        autofocus: widget.autofocus,
        initialSearchTerms: searchTerms,
        // buildDropDownDialog: widget.buildDropDownDialog,
        dropDownDialogPadding: widget.dropDownDialogPadding,
        searchInputDecoration: widget.searchInputDecoration,
        itemsPerPage: widget.itemsPerPage,
        currentPage: widget.currentPage,
        customPaginationDisplay: widget.customPaginationDisplay,
        futureSearchFn: widget.futureSearchFn,
        futureSearchOrderOptions: widget.futureSearchOrderOptions,
        futureSearchFilterOptions: widget.futureSearchFilterOptions,
        futureSelectedValues: futureSelectedValues,
        emptyListWidget: widget.emptyListWidget,
        onTap: widget.onTap,
        futureSearchRetryButton: widget.futureSearchRetryButton,
        searchDelay: widget.searchDelay,
        giveMeThePop: giveMeThePop,
        clearSearchIcon: widget.clearSearchIcon,
        listValidator: widget.listValidator,
        buildFutureFilterOrOrderButton: widget.buildFutureFilterOrOrderButton,
        searchResultDisplayFn: widget.searchResultDisplayFn,
      ));
    });
  }

  Future<void> showDialogOrMenu(String searchTerms,
      {bool closeMenu = false}) async {
    if (widget.dialogBox) {
      if (widget.showDialogFn != null) {
        await widget.showDialogFn!(
          context,
          menuWidget,
          searchTerms,
        );
      } else {
        await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext dialogContext) {
              return (menuWidget(searchTerms: searchTerms));
            });
      }
      if (widget.onChanged != null && selectedResult != null) {
        try {
          sendSelection(selectedResult, context);
        } catch (e) {
          sendSelection(selectedResult);
        }
      }
    } else {
      displayMenu.value = !closeMenu;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget buildWidget(BuildContext context) {
    // Если задана функция setOpenDialog, вызываем ее, передавая функцию showDialogOrMenu
    if (widget.setOpenDialog != null) {
      widget.setOpenDialog!(showDialogOrMenu);
    }

    // Инициализируем список виджетов items, учитывая состояние enabled

    final List<Widget> items =
        _enabled ? List<Widget>.from(widget.items ?? []) : <Widget>[];

    // Индекс для подсказки в выпадающем списке

    int? hintIndex;

    // Проверяем наличие подсказки или отключенной подсказки
    if (widget.hint != null ||
        (!_enabled &&
            prepareWidget(widget.disabledHint,
                    parameter: updateParentWithOptionalPop) !=
                null)) {
      // Создаем виджет подсказки в выпадающем списке

      final Widget positionedHint = DropdownMenuItem<T>(
        child: (_enabled
                ? prepareWidget(widget.hint)
                : prepareWidget(widget.disabledHint,
                        parameter: updateParentWithOptionalPop) ??
                    prepareWidget(widget.hint)) ??
            const SizedBox.shrink(),
      );

      // Устанавливаем индекс для подсказки

      hintIndex = items.length;
      items.add(DefaultTextStyle(
        // стиль текста элемента на основном экране
        style: _textStyle.copyWith(
          color: inp == "Поиск компании" ? gray : black,
        ),
        child: ExcludeSemantics(
          child: IgnorePointer(
            child: positionedHint,
          ),
        ),
      ));
    }

    // Подготавливаем виджет для отображения выбранных элементов
    Widget innerItemsWidget;
    List<Widget> list = [];

    // Проверяем, выбраны ли элементы из списка
    if (widget.futureSearchFn == null) {
      selectedItems?.forEach((item) {
        if (item is! NotGiven) {
          list.add(widget.selectedValueWidgetFn != null
              ? widget.selectedValueWidgetFn!(widget.items![item].value)
              : items[item]);
        }
      });
    } else {
      for (var element in futureSelectedValues) {
        if (element is! NotGiven) {
          list.add(widget.selectedValueWidgetFn != null
              ? widget.selectedValueWidgetFn!(element)
              : element is String
                  ? Text(element)
                  : element);
        }
      }
    }
    if ((list.isEmpty && hintIndex != null) ||
        (list.length == 1 && list.first is NotGiven)) {
      innerItemsWidget = items[hintIndex ?? 0];
    } else {
      innerItemsWidget = widget.selectedAggregateWidgetFn != null
          ? widget.selectedAggregateWidgetFn!(list)
          : Column(
              children: list,
            );
    }
    Widget? clickable = !_enabled &&
            prepareWidget(widget.disabledHint,
                    parameter: updateParentWithOptionalPop) !=
                null
        ? prepareWidget(widget.disabledHint,
            parameter: updateParentWithOptionalPop)
        : InkWell(
            key: const Key("clickableResultPlaceHolder"),
            //this key is used for running automated tests
            onTap: widget.readOnly || !_enabled
                ? null
                : () async {
                    if (widget.onTap != null) {
                      widget.onTap!();
                    }
                    await showDialogOrMenu("",
                        closeMenu: !widget.dialogBox && displayMenu.value);
                  },
            child: Row(
              textDirection:
                  rightToLeft ? TextDirection.rtl : TextDirection.ltr,
              children: [
                widget.isExpanded
                    ? Expanded(child: innerItemsWidget)
                    : innerItemsWidget,
              ],
            ),
          );

    // Создаем виджет DefaultTextStyle, который применяет стиль текста к дочерним виджетам
    DefaultTextStyle result = DefaultTextStyle(
      style: _textStyle,
      child: Container(
        height: 40,
        color: Colors.transparent,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.isExpanded
                ? Expanded(child: clickable ?? const SizedBox.shrink())
                : clickable ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );

    String? validatorOutput = validResult;
    Widget? labelOutput = prepareWidget(widget.label, parameter: selectedResult,
        stringToWidgetFunction: (string) {
      return (Text(string,
          textDirection: rightToLeft ? TextDirection.rtl : TextDirection.ltr,
          style: const TextStyle(color: Colors.blueAccent, fontSize: 13)));
    });
    Widget? fieldPresentation;
    EdgeInsets treatedPadding = EdgeInsets.zero;
    if (widget.fieldPresentationFn != null) {
      fieldPresentation = widget.fieldPresentationFn!(
        result,
        selectionIsValid: valid,
      );
    } else if (widget.fieldDecoration != null) {
      fieldPresentation = Padding(
        padding: treatedPadding,
        child: Container(
          decoration: widget.fieldDecoration,
          child: result,
        ),
      );
    } else {
      fieldPresentation = Stack(
        children: [
          Padding(
            padding: treatedPadding,
            child: result,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        labelOutput ?? const SizedBox.shrink(),
        fieldPresentation,
        ((validatorOutput == null)
            ? const SizedBox.shrink()
            : Text(
                validatorOutput,
                textDirection:
                    rightToLeft ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              )),
        displayMenu.value ? menuWidget() : const SizedBox.shrink(),
      ],
    );
  }

  void clearSelection() {
    if (widget.futureSearchFn == null) {
      selectedItems?.clear();
    } else {
      futureSelectedValues.clear();
    }
    if (widget.onChanged != null) {
      sendSelection(selectedResult, context);
    }
    if (widget.onClear != null) {
      widget.onClear!();
    }
    setState(() {});
  }
}
