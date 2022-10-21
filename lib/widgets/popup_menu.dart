import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'dart:math';
import 'dart:ui';

abstract class MenuItemProvider {
  String get menuTitle;
  Widget? get menuImage;
  TextStyle get menuTextStyle;
  TextAlign get menuTextAlign;
  Function get clickAction;
}

class ContextualMenuItem extends MenuItemProvider {
  Widget? image;
  String title;
  TextStyle textStyle;
  TextAlign textAlign;
  Function press;

  ContextualMenuItem({
    this.title = "",
    this.image,
    required this.textStyle,
    required this.textAlign,
    required this.press,
  });

  @override
  Function get clickAction => press;

  @override
  Widget? get menuImage => image;

  @override
  String get menuTitle => title;

  @override
  TextStyle get menuTextStyle => textStyle;

  @override
  TextAlign get menuTextAlign => textAlign;
}

class MenuItemWidget extends StatefulWidget {
  final MenuItemProvider item;
  final bool showLine;
  final Color lineColor;
  final Color backgroundColor;
  final Color highlightColor;
  final double itemWidth;
  final double itemHeight;

  final Function(MenuItemProvider item) clickCallback;

  const MenuItemWidget({
    Key? key,
    required this.item,
    this.showLine = false,
    required this.clickCallback,
    required this.lineColor,
    required this.backgroundColor,
    required this.highlightColor,
    required this.itemWidth,
    required this.itemHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MenuItemWidgetState();
  }
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  var highlightColor = const Color(0x55000000);
  var color = const Color(0xff232323);
  bool itemWaiting = false;
  @override
  void initState() {
    color = widget.backgroundColor;
    highlightColor = widget.highlightColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          color = highlightColor;
        });
      },
      onTapUp: (details) {
        setState(() {
          color = widget.backgroundColor;
        });
      },
      onLongPressEnd: (details) {
        setState(() {
          color = widget.backgroundColor;
        });
      },
      onTap: () {
        // widget.item.clickAction();
        setState(() {
          itemWaiting = true;
        });
        widget.clickCallback(widget.item);
      },
      child: Container(
        width: widget.itemWidth,
        height: widget.itemHeight,
        decoration: BoxDecoration(
          color: color,
          border: Border(
            right: BorderSide(
              color: widget.showLine ? widget.lineColor : Colors.transparent,
            ),
          ),
        ),
        child: _createContent(),
      ),
    );
  }

  Widget _createContent() {
    if (widget.item.menuImage != null) {
      // image and text
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 30.0,
            height: 30.0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: widget.item.menuImage,
            ),
          ),
          widget.item.menuTitle == "" ? const SizedBox() : SizedBox(
            height: 22.0,
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.item.menuTitle,
                style: widget.item.menuTextStyle,
              ),
            ),
          )
        ],
      );
    } else {
      // only text
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Text(
            widget.item.menuTitle,
            style: widget.item.menuTextStyle,
            textAlign: widget.item.menuTextAlign,
          ),
        ),
      );
    }
  }
}

typedef PopupMenuStateChanged = Function(bool isShow);

class PopupMenu {
  OverlayEntry? _entry;
  late List<MenuItemProvider> itms;

  /// row count
  int _row = 1;

  /// col count
  int _col = 1;

  /// The left top point of this menu.
  late Offset _offset;

  /// Menu will show at above or under this rect
  late Rect _showRect;

  /// The max column count, default is 4.
  int _maxColumn = 4;

  /// callback
  VoidCallback? dismissCallback;
  PopupMenuStateChanged? stateChangd;

  late Size _screenSize;

  /// Cannot be null
  static late BuildContext buildContext;

  /// style
  late Color _backgroundColor;
  late Color _highlightColor;
  late Color _lineColor;

  /// It's showing or not.
  bool _isShow = false;
  bool get isShow => _isShow;

  /// chose if dissmiss if user click away
  late bool dismissOnClickAway;

  late double itWidth;
  late double itHeight;

  PopupMenu({
    required BuildContext context,
    required List<MenuItemProvider> items,
    VoidCallback? onDismiss,
    int maxColumns = 4,
    Color? backgroundColor,
    Color? highlightColor,
    Color? lineColor,
    PopupMenuStateChanged? stateChanged,
    bool? disClickAway,
    double? itemWidth,
    double? itemHeight,
  }) {
    dismissCallback = onDismiss;
    stateChangd = stateChanged;
    itms = items;
    _maxColumn = maxColumns;
    _backgroundColor = backgroundColor ?? const Color(0xff232323);
    _lineColor = lineColor ?? const Color(0xFFF8F8F8);
    _highlightColor = highlightColor ?? const Color(0x55000000);
    buildContext = context;
    dismissOnClickAway = disClickAway ?? true;
    itWidth = itemWidth ?? 46;
    itHeight = itemHeight ?? 46;
  }

  void show({Rect? rect, GlobalKey? widgetKey, List<MenuItemProvider>? items}) {
    if (rect == null && widgetKey == null) {
      debugPrint("'rect' and 'key' can't be both null");
      return;
    }
    itms = items ?? itms;
    _showRect = rect ?? PopupMenu.getWidgetGlobalRect(widgetKey!);
    _screenSize = window.physicalSize / window.devicePixelRatio;
    dismissCallback = dismissCallback;

    _calculatePosition(PopupMenu.buildContext);

    _entry = OverlayEntry(builder: (context) {
      return buildPopupMenuLayout(_offset);
    });

    Overlay.of(PopupMenu.buildContext)!.insert(_entry!);
    _isShow = true;
    if (stateChangd != null) {
      stateChangd!(true);
    }
  }

  static Rect getWidgetGlobalRect(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
  }

  void _calculatePosition(BuildContext context) {
    _col = _calculateColCount();
    _row = _calculateRowCount();
    _offset = _calculateOffset(PopupMenu.buildContext);
  }

  Offset _calculateOffset(BuildContext context) {
    double dx = _showRect.left + _showRect.width / 2.0 - menuWidth() / 2.0;
    if (dx < 10.0) {
      dx = 10.0;
    }

    if (dx + menuWidth() > _screenSize.width && dx > 10.0) {
      double tempDx = _screenSize.width - menuWidth() - 10;
      if (tempDx > 10) dx = tempDx;
    }

    double dy = _showRect.top - menuHeight();
    return Offset(dx, dy);
  }

  double menuWidth() {
    return itWidth * _col;
  }

  // This height exclude the arrow
  double menuHeight() {
    return itHeight * _row;
  }

  LayoutBuilder buildPopupMenuLayout(Offset offset) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (dismissOnClickAway) {
            dismiss();
          }
        },
        onVerticalDragStart: (DragStartDetails details) {
          if (dismissOnClickAway) {
            dismiss();
          }
        },
        onHorizontalDragStart: (DragStartDetails details) {
          if (dismissOnClickAway) {
            dismiss();
          }
        },
        child: Stack(
          children: [
            // menu content
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: SizedBox(
                width: menuWidth(),
                height: menuHeight(),
                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        width: menuWidth(),
                        height: menuHeight(),
                        decoration: BoxDecoration(
                          color: _backgroundColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: _createRows(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  List<Widget> _createRows() {
    List<Widget> rows = [];
    for (int i = 0; i < _row; i++) {
      Widget rowWidget = SizedBox(
        height: itHeight,
        child: Row(
          children: _createRowItems(i),
        ),
      );

      rows.add(rowWidget);
    }

    return rows;
  }

  List<Widget> _createRowItems(int row) {
    List<MenuItemProvider> subItems = itms.sublist(
      row * _col,
      min(row * _col + _col, itms.length),
    );
    List<Widget> itemWidgets = [];
    int i = 0;
    for (var item in subItems) {
      itemWidgets.add(
        _createMenuItem(
          item,
          i < (_col - 1),
        ),
      );
      i++;
    }

    return itemWidgets;
  }

  // calculate row count
  int _calculateRowCount() {
    if (itms.isEmpty) {
      debugPrint('error menu items can not be null');
      return 0;
    }

    int itemCount = itms.length;

    if (_calculateColCount() == 1) {
      return itemCount;
    }

    int row = (itemCount - 1) ~/ _calculateColCount() + 1;

    return row;
  }

  // calculate col count
  int _calculateColCount() {
    if (itms.isEmpty) {
      debugPrint('error menu items can not be null');
      return 0;
    }

    int itemCount = itms.length;
    if (_maxColumn != 4 && _maxColumn > 0) {
      return _maxColumn;
    }

    if (itemCount == 4) {
      return 2;
    }

    if (itemCount <= _maxColumn) {
      return itemCount;
    }

    if (itemCount == 5) {
      return 3;
    }

    if (itemCount == 6) {
      return 3;
    }

    return _maxColumn;
  }

  double get screenWidth {
    double width = window.physicalSize.width;
    double ratio = window.devicePixelRatio;
    return width / ratio;
  }

  Widget _createMenuItem(MenuItemProvider item, bool showLine) {
    return MenuItemWidget(
      item: item,
      showLine: showLine,
      clickCallback: itemClicked,
      lineColor: _lineColor,
      backgroundColor: _backgroundColor,
      highlightColor: _highlightColor,

      itemWidth: itWidth,
      itemHeight: itHeight,
    );
  }

  Future<void> itemClicked(MenuItemProvider item) async {
    item.clickAction();
    await Future.delayed(const Duration(milliseconds: 500));
    dismiss();
  }

  void dismiss() {
    if (!_isShow) {
      /// Remove method should only be called once
      return;
    }

    _entry?.remove();
    _isShow = false;
    if (dismissCallback != null) {
      dismissCallback!();
    }

    if (stateChangd != null) {
      stateChangd!(false);
    }
  }
}

class ContextualMenu extends StatefulWidget {
  /// the child is a [Widget]
  final Widget child;

  /// list of items
  final List<MenuItemProvider> items;

  /// background of the pop up
  final Color? backgroundColor;

  /// highlight  of the pop up selected item
  final Color? highlightColor;

  /// color  of line separator
  final Color? lineColor;

  /// context of pop up
  final BuildContext ctx;

  /// the key of the targetting pop up
  final GlobalKey targetWidgetKey;

  /// called after dismissing the popup
  final Function()? onDismiss;

  /// called after an item clicked
  final Function(bool)? stateChanged;

  /// chose if dissmiss if user click away
  final bool dismissOnClickAway;

  /// max columns
  final int maxColumns;

  final double itemWidth;
  final double itemHeight;

  const ContextualMenu({
    Key? key,
    required this.targetWidgetKey,
    required this.child,
    required this.items,
    required this.ctx,
    this.backgroundColor,
    this.highlightColor,
    this.lineColor,
    this.onDismiss,
    this.dismissOnClickAway = true,
    this.stateChanged,
    this.maxColumns = 3,
    this.itemWidth = 46,
    this.itemHeight = 46,
  }) : super(key: key);

  @override
  State<ContextualMenu> createState() => _ContextualMenuState();
}


class _ContextualMenuState extends State<ContextualMenu> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
      onTap: () {
        var popupMenu = PopupMenu(
          context: widget.ctx,
          backgroundColor: widget.backgroundColor,
          lineColor: widget.lineColor,
          maxColumns: widget.maxColumns,
          items: widget.items,
          highlightColor: widget.highlightColor,
          stateChanged: widget.stateChanged,
          onDismiss: widget.onDismiss,
          itemWidth: widget.itemWidth,
          itemHeight: widget.itemHeight,
        );
        popupMenu.show(widgetKey: widget.targetWidgetKey);
      },
    );
  }
}