import 'package:flutter/material.dart';

FollowUpCard(name, time) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.only(left: 10),
    decoration: BoxDecoration(
      color: Colors.green.shade400,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white, width: 1.0),
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 60,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.whatshot, color: Colors.white, size: 16),
                    SizedBox(width: 3),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  "  $time",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: const Color.fromARGB(251, 231, 228, 228),
                width: 1,
              ),
            ),
          ),
        ),
        //Icon(Icons.call, color: Colors.white),
        Container(
          height: 60,
          width: 60, // Fixed width to match height
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.green[400],
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: const Icon(Icons.call_outlined, color: Colors.white, size: 22),
        ),
      ],
    ),
  );
}
