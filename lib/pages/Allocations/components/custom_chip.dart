import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';

Widget buildCustomChip({
  Key? key,
  required String text,
  required bool isSelected,
  required VoidCallback onTap,
  bool isLoading = false,
  Widget? trailing,
}) {
  final chipTextColor = isSelected
      ? Colors.white
      : ColorConstants.MainPurpleBackground;

  return Padding(
    key: key,
    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.MainPurpleBackground
              : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: ColorConstants.MainPurpleBackground),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorConstants.MainPurpleBackground.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: chipTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 4),
              SizedBox(
                key: const ValueKey('chip-loading-indicator'),
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(chipTextColor),
                ),
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing,
            ],
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 12, color: Colors.white),
            ],
          ],
        ),
      ),
    ),
  );
}
