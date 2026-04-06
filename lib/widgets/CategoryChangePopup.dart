import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/color_palette.dart';

void showCategoryChangePopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First line with "Change category" and "Done"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Change category",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                        color: ColorConstants.MainPurpleBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              // Second line with instruction
              Text(
                "Please rate this person",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 15),

              // Three category options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cold option
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text("Cold"),
                          SizedBox(height: 5),
                          Icon(Icons.local_fire_department, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // Warm option
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text("Warm"),
                          SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // Hot option
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text("Hot"),
                          SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Add some bottom padding for devices with notches
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      );
    },
  );
}
