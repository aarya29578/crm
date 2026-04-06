import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crm_flutter/pages/Products/products_controller.dart';
import 'package:crm_flutter/pages/Quotes/components/TextFields.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:crm_flutter/api/response/all_products_response.dart';

class AddProductPage extends StatefulWidget {
  final bool isEdit;
  final Data? productRes;

  const AddProductPage({super.key, required this.isEdit, this.productRes});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  ProductsController productsController = Get.put(ProductsController());

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Enter Product Details", style: whiteHeading),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuoteTitle(
                  "Product Details",
                  "Information about the products related to quote.",
                ),
                SizedBox(height: 20),

                FormTextField(
                  name: 'name',
                  label: 'Product Name',
                  initialValue: widget.isEdit ? widget.productRes?.name : null,
                ),
                SizedBox(height: 12),

                FormTextField(
                  name: 'sku',
                  label: 'SKU',
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  initialValue: widget.isEdit
                      ? widget.productRes?.sku.toString()
                      : null,
                ),
                SizedBox(height: 12),

                FormTextField(
                  name: 'quantity',
                  label: 'quantity',
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  initialValue: widget.isEdit
                      ? widget.productRes?.quantity.toString()
                      : null,
                ),
                SizedBox(height: 12),

                FormTextField(
                  name: 'price',
                  label: 'price',
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  initialValue: widget.isEdit
                      ? widget.productRes?.price?.numberDecimal.toString()
                      : null,
                ),
                SizedBox(height: 12),

                FormTextField(
                  name: 'description',
                  label: 'description',
                  maxLength: 150,
                  initialValue: widget.isEdit
                      ? widget.productRes?.description
                      : null,
                ),
                SizedBox(height: 12),

                //Submit Button
                SizedBox(height: 50),
                Center(
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 1, // 70% of the screen width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.saveAndValidate()) {
                            //var formData = _formKey.currentState!.value;
                            //print(formData);

                            final formData = Map<String, dynamic>.from(
                              _formKey.currentState!.value,
                            );

                            widget.isEdit
                                ? productsController.updateProduct(
                                    formData,
                                    widget.productRes!.sId,
                                  )
                                : productsController.createProduct(formData);
                          }
                        },

                        child: Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
