import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

QuoteTitle(title, description) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          fontSize: 20,
        ),
      ),
      Text(description, softWrap: true, style: greyHeading),
    ],
  );
}

Widget FormTextField({
  required String name,
  required String label,
  bool required = true,
  String? hintText,
  String? helperText,
  String? initialValue,
  TextInputType? keyboardType,
  bool obscureText = false,
  int? maxLines = 1,
  int? minLines,
  int? maxLength,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool enabled = true,
  ValueChanged<String?>? onChanged,
  EdgeInsetsGeometry? contentPadding,
  InputBorder? focusedBorder,
  InputBorder? errorBorder,
  Color? fillColor,
  bool filled = false,
  bool expands = true,
}) {
  return FormBuilderTextField(
    name: name,
    initialValue: initialValue,
    keyboardType: keyboardType,
    obscureText: obscureText,
    maxLines: maxLines,
    minLines: minLines,
    maxLength: maxLength,
    enabled: enabled,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: filled,
      errorMaxLines: 2,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      alignLabelWithHint: true,
      counterText: "",
      fillColor: fillColor ?? Colors.grey.shade100,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder:
          focusedBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
      errorBorder:
          errorBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
    validator: FormBuilderValidators.compose([
      if (required)
        FormBuilderValidators.required(errorText: '$label is required'),
      if (keyboardType == TextInputType.number)
        FormBuilderValidators.numeric(errorText: 'Please enter numbers only'),
      if (keyboardType == TextInputType.emailAddress)
        FormBuilderValidators.email(errorText: 'Please enter a valid email'),
    ]),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    valueTransformer: (value) {
      // Convert empty strings to null for cleaner form data
      if (value == null || value.isEmpty) return null;
      return value;
    },
  );
}
