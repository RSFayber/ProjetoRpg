import 'package:flutter/material.dart';

import '../../../core/theme/sheet_theme.dart';
import 'sheet_text_fields.dart';

class SheetPanel extends StatelessWidget {
  const SheetPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(6),
    this.fill,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SheetDecorations.panel(fill: fill),
      padding: padding,
      child: child,
    );
  }
}

class SheetLabel extends StatelessWidget {
  const SheetLabel(this.text, {super.key, this.align = TextAlign.left});

  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: align,
      style: SheetDecorations.label(context),
    );
  }
}

class SheetFieldBox extends StatelessWidget {
  const SheetFieldBox({
    super.key,
    required this.label,
    required this.child,
    this.flex = 1,
  });

  final String label;
  final Widget child;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: SheetDecorations.panel(),
        padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetLabel(label),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }
}

class SheetMiniBox extends StatelessWidget {
  const SheetMiniBox({
    super.key,
    required this.label,
    required this.value,
    this.width,
    this.height = 48,
  });

  final String label;
  final String value;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: SheetDecorations.panel(),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SheetLabel(label, align: TextAlign.center),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(value, style: SheetDecorations.value(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SheetDot extends StatelessWidget {
  const SheetDot({super.key, required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: SheetColors.border, width: 1.2),
        color: filled ? SheetColors.border : SheetColors.paper,
      ),
    );
  }
}

class SheetLinedArea extends StatelessWidget {
  const SheetLinedArea({
    super.key,
    required this.label,
    this.lines = 4,
    this.child,
  });

  final String label;
  final int lines;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SheetDecorations.panel(),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetLabel(label),
          const SizedBox(height: 6),
          if (child != null)
            child!
          else
            ...List.generate(
              lines,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  height: 14,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: SheetColors.borderLight),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String formatModifier(int value) => value >= 0 ? '+$value' : '$value';

String formatSpeedMeters(double meters) {
  final rounded = (meters * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return '${rounded.toInt()} m';
  }
  return '$rounded m';
}

class SheetTextArea extends StatelessWidget {
  const SheetTextArea({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.minLines = 2,
    this.maxLines = 6,
    this.compact = false,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int maxLines;
  /// Sem painel extra — para uso dentro de outro [SheetPanel].
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final field = SheetControlledTextField(
      value: value,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetLabel(label),
          const SizedBox(height: 4),
          field,
        ],
      );
    }

    return Container(
      decoration: SheetDecorations.panel(),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetLabel(label),
          const SizedBox(height: 4),
          field,
        ],
      ),
    );
  }
}

class SheetTappableDot extends StatelessWidget {
  const SheetTappableDot({
    super.key,
    required this.filled,
    required this.onTap,
  });

  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SheetDot(filled: filled),
    );
  }
}

class SheetDeathSaveRow extends StatelessWidget {
  const SheetDeathSaveRow({
    super.key,
    required this.label,
    required this.count,
    required this.onChanged,
  });

  final String label;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: SheetDecorations.label(context)),
        for (var i = 0; i < 3; i++)
          SheetTappableDot(
            filled: i < count,
            onTap: () => onChanged(i < count ? i : i + 1),
          ),
      ],
    );
  }
}
