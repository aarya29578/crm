import 'package:flutter/material.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/styles/text_styles.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    return Scaffold(
      backgroundColor: ColorConstants.MainPurpleBackground.withValues(
        alpha: 0.06,
      ),
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: ColorConstants.MainPurpleBackground,
        title: Align(
          alignment: Alignment.topLeft,
          child: Text(
            "You can search here...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(right: 10, left: 10),
            color: Colors.white,
            width: double.infinity,
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Text(
                    "Claimed (new to old)",
                    style: TextStyle(
                      color: ColorConstants.MainPurpleBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: 180, // Adjust height to match your text size
                  width: 3,
                  color: Colors.grey.shade200,
                  margin: EdgeInsets.symmetric(
                    horizontal: 10,
                  ), // Same effect as SizedBox(width: 10)
                ),
                Center(
                  child: Text(
                    "Filters (0)",
                    style: TextStyle(
                      color: ColorConstants.MainPurpleBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          //const Divider(),

          // Container(
          //   padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          //   color: Colors.white,
          //   child: Row(
          //     children: [
          //       Icon(Icons.search, size: 20),
          //       SizedBox(width: 10),
          //       Text(
          //         'Search by name or number',
          //         style: TextStyle(
          //           color: Colors.grey.shade400,
          //           fontSize: 16,
          //           letterSpacing: 0,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            //color: ColorConstants.MainPurpleBackground.withValues(alpha: 0.06),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // Unfocused border
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ColorConstants.MainPurpleBackground.withValues(
                      alpha: 0.8,
                    ),
                    width: 1,
                  ),
                ),
                // Focused border
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ColorConstants.MainPurpleBackground,
                    width: 1.8,
                  ),
                ),
              ),
              onChanged: (value) {
                print("Searching: $value");
              },
            ),
          ),

          Expanded(child: Container(color: Colors.grey.shade200)),
        ],
      ),
    );
  }
}
