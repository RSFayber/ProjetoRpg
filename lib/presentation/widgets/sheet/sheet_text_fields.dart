import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/sheet_theme.dart';

/// Campo de texto que mantem foco durante rebuilds do Riverpod.
class SheetControlledTextField extends StatefulWidget {
  const SheetControlledTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.style,
    this.decoration,
    this.maxLines = 1,
    this.minLines,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final TextStyle? style;
  final InputDecoration? decoration;
  final int maxLines;
  final int? minLines;

  @override
  State<SheetControlledTextField> createState() => _SheetControlledTextFieldState();
}

class _SheetControlledTextFieldState extends State<SheetControlledTextField> {
  late final TextEditingController _controller;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(SheetControlledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _syncing = true;
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
      _syncing = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      style: widget.style ?? SheetDecorations.value(context),
      inputFormatters: widget.keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: widget.decoration,
      onChanged: (text) {
        if (!_syncing) {
          widget.onChanged(text);
        }
      },
    );
  }
}
