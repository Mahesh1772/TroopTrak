import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/theme_context.dart';

/// Text field with case-insensitive suggestions (replaces `easy_autocomplete`).
class SuggestionField extends StatefulWidget {
  const SuggestionField({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.labelText,
    this.validator,
  });

  final TextEditingController controller;
  final List<String> suggestions;
  final String labelText;
  final FormFieldValidator<String>? validator;

  @override
  State<SuggestionField> createState() => _SuggestionFieldState();
}

class _SuggestionFieldState extends State<SuggestionField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Iterable<String> _options(TextEditingValue value) {
    final query = value.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return widget.suggestions.where((s) => s.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focus,
      optionsBuilder: _options,
      onSelected: (s) => widget.controller.text = s.trim(),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
          TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: widget.validator,
        onFieldSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(labelText: widget.labelText),
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: context.palette.cardElevated,
          elevation: 4,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 400),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    dense: true,
                    title: Text(option, style: context.textStyles.titleSmall),
                    onTap: () => onSelected(option),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
