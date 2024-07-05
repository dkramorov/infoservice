import 'package:flutter/material.dart';

import '../pages/themes.dart';

class TextFieldCustom extends StatefulWidget {
  const TextFieldCustom({
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.controller,
    this.maxLength,
    this.maxLines,
    this.labelText,
    this.suffix,
    super.key,
  });

  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final int? maxLength;
  final int? maxLines;
  final String? labelText;
  final Widget? suffix;

  @override
  State<TextFieldCustom> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  final FocusNode focusNode = FocusNode();
  String error = '';
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();

    super.dispose();
  }

  void _onFocusChange() => setState(() => isFocused = focusNode.hasFocus);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: Durations.medium1,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: white,
            border: Border.all(
              width: 1,
              color: error.isNotEmpty
                  ? Theme.of(context).colorScheme.error
                  : isFocused
                      ? blue
                      : borderPrimary,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            validator: widget.validator,
            obscureText: widget.obscureText,
            focusNode: focusNode,
            keyboardType: widget.keyboardType,
            controller: widget.controller,
            maxLength: widget.maxLength,
            scrollPadding: const EdgeInsets.all(0),
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            style: TextStyle(
              fontSize: 13,
              fontWeight: w400,
              color: black,
            ),
            cursorColor: Colors.black,
            cursorErrorColor: Colors.black,
            decoration: InputDecoration(
              labelText: widget.labelText,

              /// really bad workaround
              errorStyle: const TextStyle(
                height: 0.01,
                color: Colors.transparent,
              ),
              labelStyle: TextStyle(
                fontSize: 13.5,
                fontWeight: w400,
                color: gray100,
              ),

              filled: true,
              isDense: true,
              counterText: "",
              suffixIcon: widget.suffix,
              suffixIconConstraints: BoxConstraints.tight(
                const Size(24, 24),
              ),
              fillColor: transparent,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                fontSize: 13.5,
                fontWeight: w300,
                color: gray100,
              ),
            ),
            onSaved: (value) => setState(
              () => error = widget.validator?.call(value) ?? '',
            ),
          ),
        ),
        AnimatedContainer(
            height: error.isNotEmpty ? 32 : 0,
            duration: Durations.medium1,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            )),
      ],
    );
  }
}
