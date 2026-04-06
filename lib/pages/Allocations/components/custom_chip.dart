import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';

Widget buildCustomChip({
  required String text,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Padding(
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
                    color: ColorConstants.MainPurpleBackground.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
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
                color: isSelected
                    ? Colors.white
                    : ColorConstants.MainPurpleBackground,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
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
