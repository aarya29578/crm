import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Quotes/components/TextFields.dart';

class QuoteItemCard extends StatefulWidget {
  final int index;
  final Function() onRemove;

  const QuoteItemCard({super.key, required this.index, required this.onRemove});

  @override
  State<QuoteItemCard> createState() => _QuoteItemCardState();
}

class _QuoteItemCardState extends State<QuoteItemCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Item ${widget.index + 1}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            SizedBox(height: 10),
            FormTextField(name: "items[${widget.index}].name", label: "Name"),
            SizedBox(height: 10),
            FormTextField(
              name: "items[${widget.index}].sku",
              label: "SKU",
              maxLength: 4,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FormTextField(
                    name: "items[${widget.index}].price",
                    label: "Price",
                    maxLength: 4,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: FormTextField(
                    name: "items[${widget.index}].quantity",
                    label: "Quantity",
                    maxLength: 4,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            FormTextField(
              name: "items[${widget.index}].total",
              label: "Total",
              maxLength: 4,
            ),
          ],
        ),
      ),
    );
  }
}
