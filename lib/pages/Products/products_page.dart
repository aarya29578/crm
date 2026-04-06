import 'package:flutter/material.dart';
import 'package:crm_flutter/api/response/all_products_response.dart';
import 'package:crm_flutter/pages/Products/add_product_page.dart';
import 'package:crm_flutter/pages/Products/products_controller.dart';
//import 'package:crm_flutter/pages/Quotes/add_quote_page.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductsController productsController = Get.put(ProductsController());
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    productsController.getAllProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Products", style: whiteHeading),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => productsController.getAllProducts(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(AddProductPage(isEdit: false)),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Obx(() {
          final response = productsController.allProductsRes.value;
          if (response.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (response.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: response.data!.length,
            itemBuilder: (context, index) {
              final product = response.data![index];
              return _buildProductCard(product);
            },
          );
        }),
      ),
    );
  }

  Widget _buildProductCard(Data product) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name row with action buttons
            Row(
              children: [
                const Icon(
                  Icons.card_travel,
                  color: Colors.blueAccent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product.name ?? "No product name",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Edit and Delete buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: Colors.blue,
                      onPressed: () {
                        Get.to(
                          AddProductPage(isEdit: true, productRes: product),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      onPressed: () => _showDeleteDialog(product),
                    ),
                  ],
                ),
              ],
            ),
            // Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),

            // Product details
            _buildDetailRow("SKU", product.sku?.toString() ?? 'N/A'),
            _buildDetailRow("Quantity", product.quantity?.toString() ?? '0'),
            _buildDetailRow(
              "Price",
              product.price?.numberDecimal?.toString() ?? 'N/A',
              isPrice: true,
            ),

            // Description with multiple lines
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Description:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product.description ?? "No description available",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dates at the bottom
            if (product.createdAt != null || product.updatedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (product.createdAt != null)
                      Text(
                        'Created: ${_formatDate(product.createdAt!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    if (product.updatedAt != null)
                      Text(
                        'Updated: ${_formatDate(product.updatedAt!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Data product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              productsController.deleteProduct(product.sId!);
              print('Deleted Product: ${product.name}');
              Navigator.pop(context);

              //Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            isPrice ? '\$$value' : value,
            style: TextStyle(
              color: isPrice ? Colors.green : null,
              fontWeight: isPrice ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
