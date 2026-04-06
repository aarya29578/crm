import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter_svg/svg.dart';

class StatusChangePopup {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    SizedBox(
                      width: 100,
                      height: 60,
                      child: SvgPicture.asset("assets/svgs/climb.svg"),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Move to",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Status Buttons
                    ...[
                      "Interested",
                      "Meeting done",
                      "Visit done",
                      "Final negotiation",
                      "Booking done",
                      "Failed",
                    ].map(
                      (status) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle status change here
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              side: BorderSide(
                                color: status == "Failed"
                                    ? Colors.red
                                    : ColorConstants.MainPurpleBackground,
                              ),
                              foregroundColor: status == "Failed"
                                  ? Colors.red
                                  : ColorConstants.MainPurpleBackground,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Close Icon Button
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: ColorConstants.MainPurpleBackground,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
