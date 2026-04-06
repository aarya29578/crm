import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Quotes/add_quote_page.dart';
import 'package:crm_flutter/pages/Quotes/quotes_controller.dart';
import 'package:crm_flutter/pages/Quotes/quotes_items_page.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  final QuotesController qcontroller = Get.put(QuotesController());
  final ScrollController _scrollController = ScrollController();
  final double _cardElevation = 2.0;
  final double _cardMargin = 8.0;
  final double _cardPadding = 16.0;

  @override
  void initState() {
    super.initState();
    qcontroller.getAllQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: ColorConstants.MainPurpleBackground,
        title: Text("Quotes", style: whiteHeading),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => qcontroller.getAllQuotes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your logic for adding a new organization here
          // Get.snackbar(
          //   'Add Organization',
          //   'Add organization functionality will go here',
          // );
          Get.to(AddQuotePage());
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Obx(() {
          final response = qcontroller.allQuotesRes.value;
          if (response.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final quotesList = response.data!;

          if (quotesList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.business_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No Quotes found', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    'Add new quotes to see them here',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => await qcontroller.getAllQuotes(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: quotesList.length,
              itemBuilder: (context, index) {
                final quotes = quotesList[index];
                return Card(
                  elevation: _cardElevation,
                  color: Colors.white,
                  margin: EdgeInsets.all(_cardMargin),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(_cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            Icon(Icons.receipt, color: Colors.blue.shade700),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                quotes.subject ?? 'New Quote',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  color: Colors.blue,
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: Colors.red,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Divider(height: 20, thickness: 1),

                        // Description Section
                        Row(
                          children: [
                            _buildSectionTitle("Description:"),
                            SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 4),
                              child: Text(
                                quotes.description ?? "No description provided",
                                style: greyHeading.copyWith(fontSize: 14),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Address Section
                        _buildSectionTitle("Address Information:"),
                        _buildInfoRow(
                          "Billing:",
                          quotes.billingAddress?.line1 ?? "Not specified",
                        ),
                        _buildInfoRow(
                          "Shipping:",
                          quotes.shippingAddress?.line1 ?? "Not specified",
                        ),

                        const SizedBox(height: 16),

                        // Quote Details Section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade100,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Quote Details"),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                "Discount Percent:",
                                quotes.discountPercent?.numberDecimal ?? "0",
                                isAmount: false,
                              ),
                              _buildDetailRow(
                                "Discount Amount:",
                                quotes.discountAmount?.numberDecimal ?? "0",
                              ),
                              _buildDetailRow(
                                "Tax Amount:",
                                quotes.taxAmount?.numberDecimal ?? "0",
                              ),
                              _buildDetailRow(
                                "Adjustment:",
                                quotes.adjustmentAmount?.numberDecimal ?? "0",
                              ),
                              const Divider(height: 20),
                              _buildDetailRow(
                                "Sub Total:",
                                quotes.subTotal?.numberDecimal ?? "0",
                                isBold: true,
                              ),
                              _buildDetailRow(
                                "Grand Total:",
                                quotes.grandTotal?.numberDecimal ?? "0",
                                isBold: true,
                                textColor: Colors.green.shade700,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Items Section
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              if (quotes.items != null &&
                                  quotes.items!.isNotEmpty) {
                                Get.to(
                                  () => const QuotesItemsPage(),
                                  arguments: quotes.items,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "View Items (${quotes.items?.length ?? 0})",
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: Colors.blue.shade800,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: blackSmallTitle.copyWith(fontSize: 15, color: Colors.black87),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: blackSmallTitle.copyWith(fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: greyHeading.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isAmount = true,
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: greyHeading.copyWith(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            isAmount ? "\$$value" : "$value%",
            style: blackSmallTitle.copyWith(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
