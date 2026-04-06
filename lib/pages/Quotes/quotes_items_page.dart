import 'package:flutter/material.dart';
import 'package:crm_flutter/api/response/all_quotes_response.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';

class QuotesItemsPage extends StatelessWidget {
  const QuotesItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Items> items = Get.arguments ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.MainPurpleBackground,
        title: Text("Quote Items", style: whiteHeading),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final Items item = items[index];
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SKU: ${item.sku ?? 'N/A'}", style: blackHeading),
                  const SizedBox(height: 8),
                  Text("Name: ${item.name ?? 'N/A'}", style: greyHeading),
                  const SizedBox(height: 8),
                  Text(
                    "Quantity: ${item.quantity?.toString() ?? 'N/A'}",
                    style: greyHeading,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Price: \$${item.price?.numberDecimal ?? 'N/A'}",
                    style: greyHeading,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Total: \$${item.total?.numberDecimal ?? 'N/A'}",
                    style: greyHeading,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Product ID: ${item.productId ?? 'N/A'}",
                    style: greyHeading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
