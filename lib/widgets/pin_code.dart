import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoTextField;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pages/themes.dart';

typedef OnDone = void Function(String text);
typedef PinBoxDecoration = BoxDecoration Function(
  Color borderColor,
  Color pinBoxColor, {
  double borderWidth,
  double radius,
});

/// class to provide some standard PinBoxDecoration such as standard box or underlined
class ProvidedPinBoxDecoration {
  /// Default BoxDecoration
  static PinBoxDecoration defaultPinBoxDecoration = (
    Color borderColor,
    Color pinBoxColor, {
    double borderWidth = 2.0,
    double radius = 5.0,
  }) {
    return BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        color: pinBoxColor,
        borderRadius: BorderRadius.circular(radius));
  };

  /// Underlined BoxDecoration
  static PinBoxDecoration underlinedPinBoxDecoration = (
    Color borderColor,
    Color pinBoxColor, {
    double borderWidth = 2.0,
    double radius = 0,
  }) {
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      ),
    );
  };

  static PinBoxDecoration roundedPinBoxDecoration = (
    Color borderColor,
    Color pinBoxColor, {
    double borderWidth = 2.0,
    double radius = 0,
  }) {
    return BoxDecoration(
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      shape: BoxShape.circle,
      color: pinBoxColor,
    );
  };
}

AnimationController? _cursorAnimationController;
Animation<double>? _cursorAnimation;

class ProvidedPinBoxTextAnimation {
  /// A combination of RotationTransition, DefaultTextStyleTransition, ScaleTransition
  static AnimatedSwitcherTransitionBuilder awesomeTransition =
      (Widget child, Animation<double> animation) {
    return RotationTransition(
        turns: animation,
        child: DefaultTextStyleTransition(
          style: TextStyleTween(
                  begin: const TextStyle(color: Colors.pink),
                  end: const TextStyle(color: Colors.blue))
              .animate(animation),
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        ));
  };

  /// Simple Scaling Transition
  static AnimatedSwitcherTransitionBuilder scalingTransition =
      (child, animation) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  };

  /// No transition
  static AnimatedSwitcherTransitionBuilder defaultNoTransition =
      (Widget child, Animation<double> animation) {
    return child;
  };

  /// Rotate Transition
  static AnimatedSwitcherTransitionBuilder rotateTransition =
      (Widget child, Animation<double> animation) {
    return RotationTransition(turns: animation, child: child);
  };
}

class PinCodeTextField extends StatefulWidget {
  final bool isCupertino;
  final int maxLength;
  final TextEditingController? controller;
  final bool hideCharacter;
  final bool highlight;
  final bool highlightAnimation;
  final Color highlightAnimationBeginColor;
  final Color highlightAnimationEndColor;
  final Duration? highlightAnimationDuration;
  final Color highlightColor;
  final Color defaultBorderColor;
  final Color pinBoxColor;
  final Color? highlightPinBoxColor;
  final double pinBoxBorderWidth;
  final double pinBoxRadius;
  final bool hideDefaultKeyboard;
  final PinBoxDecoration? pinBoxDecoration;
  final String maskCharacter;
  final TextStyle? pinTextStyle;
  final double pinBoxHeight;
  final double pinBoxWidth;
  final OnDone? onDone;
  final bool hasError;
  final Color errorBorderColor;
  final Color hasTextBorderColor;
  final Function(String)? onTextChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final AnimatedSwitcherTransitionBuilder? pinTextAnimatedSwitcherTransition;
  final Duration pinTextAnimatedSwitcherDuration;
  final WrapAlignment wrapAlignment;
  final TextDirection textDirection;
  final TextInputType keyboardType;
  final EdgeInsets pinBoxOuterPadding;
  final bool hasUnderline;

  const PinCodeTextField({
    super.key,
    this.isCupertino = false,
    this.maxLength = 4,
    this.controller,
    this.hideCharacter = false,
    this.highlight = false,
    this.highlightAnimation = false,
    this.highlightAnimationBeginColor = Colors.white,
    this.highlightAnimationEndColor = Colors.black,
    this.highlightAnimationDuration,
    this.highlightColor = Colors.black,
    this.pinBoxDecoration,
    this.maskCharacter = "\u25CF",
    this.pinBoxWidth = 48,
    this.pinBoxHeight = 56,
    this.pinTextStyle,
    this.onDone,
    this.defaultBorderColor = Colors.black,
    this.hasTextBorderColor = Colors.black,
    this.pinTextAnimatedSwitcherTransition,
    this.pinTextAnimatedSwitcherDuration = const Duration(),
    this.hasError = false,
    this.errorBorderColor = Colors.red,
    this.onTextChanged,
    this.autofocus = false,
    this.focusNode,
    this.wrapAlignment = WrapAlignment.start,
    this.textDirection = TextDirection.ltr,
    this.keyboardType = TextInputType.number,
    this.pinBoxOuterPadding = const EdgeInsets.symmetric(horizontal: 2),
    this.pinBoxColor = Colors.white,
    this.highlightPinBoxColor,
    this.pinBoxBorderWidth = 0,
    this.pinBoxRadius = 5,
    this.hideDefaultKeyboard = false,
    this.hasUnderline = false,
  });

  @override
  State<StatefulWidget> createState() {
    return PinCodeTextFieldState();
  }
}

class PinCodeTextFieldState extends State<PinCodeTextField>
    with SingleTickerProviderStateMixin {
  AnimationController? _highlightAnimationController;
  // Animation? _highlightAnimationColorTween;
  FocusNode? focusNode;
  String text = "";
  int currentIndex = 0;
  List<String> strList = [];
  bool hasFocus = false;

  @override
  void didUpdateWidget(PinCodeTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    focusNode = widget.focusNode ?? focusNode;

    if (oldWidget.maxLength < widget.maxLength) {
      setState(() {
        currentIndex = text.length;
      });
      widget.controller?.text = text;
      widget.controller?.selection =
          TextSelection.collapsed(offset: text.length);
    } else if (oldWidget.maxLength > widget.maxLength &&
        widget.maxLength > 0 &&
        text.isNotEmpty &&
        text.length > widget.maxLength) {
      setState(() {
        text = text.substring(0, widget.maxLength);
        currentIndex = text.length;
      });
      widget.controller?.text = text;
      widget.controller?.selection =
          TextSelection.collapsed(offset: text.length);
    }
  }

  _calculateStrList() async {
    if (strList.length > widget.maxLength) {
      strList.length = widget.maxLength;
    }
    while (strList.length < widget.maxLength) {
      strList.add("");
    }
  }

  void _initializeStrList() {
    strList = List.generate(widget.maxLength, (index) => "");
  }

  @override
  void initState() {
    super.initState();
    _initializeStrList();
    if (widget.highlightAnimation) {
      var highlightAnimationController = AnimationController(
          vsync: this,
          duration: widget.highlightAnimationDuration ??
              const Duration(milliseconds: 500));
      // var animationController = highlightAnimationController;

      highlightAnimationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          highlightAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          highlightAnimationController.forward();
        }
      });
      // _highlightAnimationColorTween = ColorTween(
      //         begin: widget.highlightAnimationBeginColor,
      //         end: widget.highlightAnimationEndColor)
      //     .animate(animationController);
      highlightAnimationController.forward();
      _highlightAnimationController = highlightAnimationController;
    }
    focusNode = widget.focusNode ?? FocusNode();

    _initTextController();
    _calculateStrList();
    widget.controller?.addListener(_controllerListener);
    focusNode?.addListener(_focusListener);

    focusNode?.addListener(() {
      if (focusNode!.hasFocus) {
        _cursorAnimationController!.repeat(reverse: true);
      } else {
        _cursorAnimationController!.stop();
      }
    });

    _cursorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _cursorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_cursorAnimationController!);

    _cursorAnimationController!.repeat(reverse: true);

    focusNode?.addListener(() {
      if (focusNode!.hasFocus) {
        _cursorAnimationController!.repeat(reverse: true);
      } else {
        _cursorAnimationController!.stop();
      }
    });
  }

  void _controllerListener() {
    if (mounted == true) {
      setState(() {
        _initTextController();
      });
      var onTextChanged = widget.onTextChanged;
      if (onTextChanged != null) {
        onTextChanged(widget.controller?.text ?? "");
      }
    }
  }

  void _focusListener() {
    if (mounted == true) {
      setState(() {
        hasFocus = focusNode?.hasFocus ?? false;
      });
    }
  }

  void _initTextController() {
    if (widget.controller == null) {
      return;
    }
    strList.clear();
    var text = widget.controller?.text ?? "";
    if (text.isNotEmpty) {
      if (text.length > widget.maxLength) {
        throw Exception("TextEditingController length exceeded maxLength!");
      }
    }
    for (var i = 0; i < text.length; i++) {
      strList.add(widget.hideCharacter ? widget.maskCharacter : text[i]);
    }
  }

  double get _width {
    var width = 0.0;
    for (var i = 0; i < widget.maxLength; i++) {
      width += widget.pinBoxWidth;
      if (i == 0) {
        width += widget.pinBoxOuterPadding.left;
      } else if (i + 1 == widget.maxLength) {
        width += widget.pinBoxOuterPadding.right;
      } else {
        width += widget.pinBoxOuterPadding.left;
      }
    }
    return width;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      // Only dispose the focus node if it's internal.  Don't dispose the passed
      // in focus node as it's owned by the parent not this child widget.
      focusNode?.dispose();
    } else {
      focusNode?.removeListener(_focusListener);
    }
    _highlightAnimationController?.dispose();
    widget.controller?.removeListener(_controllerListener);
    _cursorAnimationController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        !widget.isCupertino ? _fakeTextInput() : _fakeTextInputCupertino(),
        _touchPinBoxRow(),
        _buildVerticalLine(),
      ],
    );
  }

  Widget _buildVerticalLine() {
    // Определяем, должна ли линия отображаться (если есть фокус и строка пуста)
    bool shouldShowLine = hasFocus && text.length != widget.maxLength;

    return shouldShowLine
        ? Positioned(
            top: 20,
            left: 22.5 +
                currentIndex *
                    (widget.pinBoxWidth + widget.pinBoxOuterPadding.horizontal),
            child: AnimatedBuilder(
                animation: _cursorAnimationController!,
                builder: (context, child) {
                  return Opacity(
                    opacity: hasFocus ? _cursorAnimation?.value ?? 0.0 : 0.0,
                    child: Container(
                      width: 1.5,
                      height: 16,
                      color: Colors.black,
                    ),
                  );
                }))
        : Container();
  }

  Widget _touchPinBoxRow() {
    return widget.hideDefaultKeyboard
        ? _pinBoxRow(context)
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (hasFocus) {
                FocusScope.of(context).requestFocus(FocusNode());
                Future.delayed(const Duration(milliseconds: 100), () {
                  FocusScope.of(context).requestFocus(focusNode);
                });
              } else {
                FocusScope.of(context).requestFocus(focusNode);
              }
            },
            child: _pinBoxRow(context),
          );
  }

  Widget _fakeTextInput() {
    var transparentBorder = const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 0.0,
      ),
    );
    return SizedBox(
      width: _width,
      height: widget.pinBoxHeight,
      child: TextField(
        autofocus: !kIsWeb ? widget.autofocus : false,
        enableInteractiveSelection: false,
        focusNode: focusNode,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.keyboardType == TextInputType.number
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
            : null,
        style: const TextStyle(
          height: 0.1, color: Colors.transparent,
//          color: Colors.transparent,
        ),
        decoration: InputDecoration(
          focusedErrorBorder: transparentBorder,
          errorBorder: transparentBorder,
          disabledBorder: transparentBorder,
          enabledBorder: transparentBorder,
          focusedBorder: transparentBorder,
          counterText: null,
          counterStyle: null,
          helperStyle: const TextStyle(
            height: 0.0,
            color: Colors.transparent,
          ),
          labelStyle: const TextStyle(height: 0.1),
          fillColor: Colors.transparent,
          border: InputBorder.none,
        ),
        cursorColor: Colors.transparent,
        showCursor: false,
        maxLength: widget.maxLength,
        onChanged: _onTextChanged,
      ),
    );
  }

  Widget _fakeTextInputCupertino() {
    return SizedBox(
      width: _width,
      height: widget.pinBoxHeight,
      child: CupertinoTextField(
        autofocus: !kIsWeb ? widget.autofocus : false,
        focusNode: focusNode,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.keyboardType == TextInputType.number
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
            : null,
        style: TextStyle(
          color: transparent,
        ),
        decoration: BoxDecoration(
          color: transparent,
          border: null,
        ),
        cursorColor: transparent,
        showCursor: false,
        maxLength: widget.maxLength,
        onChanged: _onTextChanged,
      ),
    );
  }

  void _onTextChanged(text) {
    var onTextChanged = widget.onTextChanged;
    if (onTextChanged != null) {
      onTextChanged(text);
    }
    setState(() {
      this.text = text;
      currentIndex = text.length;
    });

    for (int i = 0; i < strList.length; i++) {
      if (i < text.length) {
        strList[i] = widget.hideCharacter ? widget.maskCharacter : text[i];
      } else {
        strList[i] = ""; // Здесь устанавливаем "" для пустых ячеек
      }
    }

    if (text.length == widget.maxLength) {
      FocusScope.of(context).requestFocus(FocusNode());
      var onDone = widget.onDone;
      if (onDone != null) {
        onDone(text);
      }
    }
  }

  // void _updateStrList() {
  //   strList.clear();
  //   for (var i = 0; i < text.length; i++) {
  //     strList.add(widget.hideCharacter ? widget.maskCharacter : text[i]);
  //   }
  //   for (var i = text.length; i < widget.maxLength; i++) {
  //     strList.add("");
  //   }
  // }

  Widget _pinBoxRow(BuildContext context) {
    _calculateStrList();
    List<Widget> pinCodes = List.generate(widget.maxLength, (int i) {
      return _buildPinCode(i, context);
    });
    return Wrap(
      direction: Axis.horizontal,
      alignment: widget.wrapAlignment,
      verticalDirection: VerticalDirection.down,
      textDirection: widget.textDirection,
      children: pinCodes,
    );
  }

  Widget _buildPinCode(int i, BuildContext context) {
    BoxDecoration? boxDecoration;

    if (widget.hasError) {
      // Handle error state if needed
    } else {
      // Determine the boxDecoration based on focus and highlight conditions
      if (hasFocus && _shouldHighlight(i)) {
        boxDecoration = BoxDecoration(
          color: blue,
          borderRadius: BorderRadius.circular(8),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Color.fromRGBO(0, 0, 0, 0.03),
          //     offset: Offset(0, 3),
          //     blurRadius: 15.0,
          //     spreadRadius: 0.0,
          //   ),
          // ],
        );
      } else {
        boxDecoration = BoxDecoration(
          color: borderPrimary,
          borderRadius: BorderRadius.circular(8),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Color.fromRGBO(0, 0, 0, 0.03),
          //     offset: Offset(0, 3),
          //     blurRadius: 15.0,
          //     spreadRadius: 0.0,
          //   ),
          // ],
        );
      }
    }

    EdgeInsets insets;
    if (i == 0) {
      insets = EdgeInsets.only(
        left: 0,
        top: widget.pinBoxOuterPadding.top,
        right: widget.pinBoxOuterPadding.right,
        bottom: widget.pinBoxOuterPadding.bottom,
      );
    } else if (i == strList.length - 1) {
      insets = EdgeInsets.only(
        left: widget.pinBoxOuterPadding.left,
        top: widget.pinBoxOuterPadding.top,
        right: 0,
        bottom: widget.pinBoxOuterPadding.bottom,
      );
    } else {
      insets = widget.pinBoxOuterPadding;
    }

    return Padding(
      padding: insets,
      child: Container(
        key: ValueKey<String>("container$i"),
        width: widget.pinBoxWidth,
        height: widget.pinBoxHeight,
        padding: const EdgeInsets.all(1),
        decoration: boxDecoration,
        child: Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: _animatedTextBox(strList[i], i),
          ),
        ),
      ),
    );
  }

  bool _shouldHighlight(int i) {
    return hasFocus &&
        (i == text.length ||
            (i == text.length - 1 && text.length == widget.maxLength));
  }

  Widget _animatedTextBox(String text, int i) {
    if (widget.pinTextAnimatedSwitcherTransition != null) {
      return AnimatedSwitcher(
        duration: widget.pinTextAnimatedSwitcherDuration,
        transitionBuilder: widget.pinTextAnimatedSwitcherTransition ??
            (Widget child, Animation<double> animation) {
              return child;
            },
        child: Text(
          text,
          key: ValueKey<String>("$text$i"),
          style: widget.pinTextStyle,
        ),
      );
    } else {
      return Text(
        text,
        key: ValueKey<String>("${strList[i]}$i"),
        style: widget.pinTextStyle,
      );
    }
  }
}
