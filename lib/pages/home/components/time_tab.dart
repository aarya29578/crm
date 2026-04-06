import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';

class TimeTab extends StatelessWidget {
  final String text;
  final bool first;
  final bool last;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeTab({
    super.key,
    required this.text,
    this.first = false,
    this.last = false,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        margin: EdgeInsets.symmetric(horizontal: first ? 0 : 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.MainPurpleBackground
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? ColorConstants.MainPurpleBackground
                : Colors.grey.shade400,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
