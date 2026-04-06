import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/api/response/all_products_response.dart'
    as productRes;
import 'package:crm_flutter/api/response/all_quotes_response.dart';
import 'package:crm_flutter/pages/Persons/persons_controller.dart';
import 'package:crm_flutter/pages/Products/products_controller.dart';
import 'package:crm_flutter/pages/Quotes/components/TextFields.dart';
import 'package:crm_flutter/pages/Quotes/quotes_controller.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class AddQuotePage extends StatefulWidget {
  const AddQuotePage({super.key});

  @override
  State<AddQuotePage> createState() => _AddQuotePageState();
}

class _AddQuotePageState extends State<AddQuotePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  PersonsController pcontroller = Get.put(PersonsController());
  ProductsController productController = Get.put(ProductsController());
  QuotesController quotesController = Get.put(QuotesController());

  final QuotesController qcontroller = Get.put(QuotesController());
  final FocusNode _dateTimePickerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState(); // Always call super.initState() first
    qcontroller.getAllQuotes();
    pcontroller.getAllPersons();
    productController.getAllProducts();
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
        title: Text("Enter Quote Details", style: whiteHeading),
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                QuoteTitle(
                  "Quote Information",
                  "Put the basic information of quote.",
                ),
                SizedBox(height: 20),

                //Enter Name
                FormTextField(name: "subject", label: "Full Name"),
                SizedBox(height: 20),
                FormTextField(
                  name: "description",
                  label: "Description",
                  minLines: 1,
                  maxLines: 3,
                ),
                SizedBox(height: 20),

                // Person Dropdown
                // FormBuilderField<String>(
                //   name: 'person_id', // This will store the ID, not the name

                //   validator: FormBuilderValidators.required(
                //     errorText: 'Please select a person',
                //   ),
                //   builder: (FormFieldState<String?> field) {
                //     final personList =
                //         pcontroller.allPersonRes.value.data ?? [];
                //     //print(personList);

                //     return DropdownSearch<String>(
                //       items: personList
                //           .map((e) => e.name ?? 'Unnamed Person')
                //           .toList(),
                //       onChanged: (selectedName) {
                //         if (selectedName == null) {
                //           field.didChange(null);
                //           return;
                //         }

                //         // Find the person by name and store its ID
                //         final selectedOrg = personList.firstWhereOrNull(
                //           (org) => org.name == selectedName,
                //         );

                //         field.didChange(
                //           selectedOrg?.sId,
                //         ); // Store ID in form data
                //       },
                //       dropdownDecoratorProps: DropDownDecoratorProps(
                //         dropdownSearchDecoration: InputDecoration(
                //           labelText: "Select person",
                //           labelStyle: TextStyle(color: Colors.grey.shade500),
                //           border: OutlineInputBorder(),
                //           contentPadding: EdgeInsets.symmetric(horizontal: 12),
                //           errorText: field.errorText,
                //         ),
                //       ),
                //       popupProps: PopupProps.menu(
                //         showSearchBox: true,
                //         searchFieldProps: TextFieldProps(
                //           decoration: InputDecoration(
                //             hintText: "Search persons...",
                //             border: OutlineInputBorder(),
                //             prefixIcon: Icon(Icons.search),
                //           ),
                //         ),
                //         // Display organization names in the dropdown list
                //         itemBuilder: (context, item, isSelected) {
                //           return ListTile(
                //             title: Text(item),
                //             selected: isSelected,
                //           );
                //         },
                //       ),
                //     );
                //   },
                // ),
                SizedBox(height: 20),

                // Expired At details
                // FormBuilderDateTimePicker(
                //   name: 'expired_at',
                //   focusNode: _dateTimePickerFocusNode,
                //   inputType: InputType.both,
                //   initialValue: DateTime.now(),
                //   format: DateFormat('dd MMM yyyy, hh:mm a'),
                //   timePickerInitialEntryMode: TimePickerEntryMode.dialOnly,
                //   valueTransformer: (value) {
                //     if (value == null) return null;
                //     return DateTime.utc(
                //       value.year,
                //       value.month,
                //       value.day,
                //       value.hour,
                //       value.minute,
                //     ).toIso8601String();
                //   },
                //   firstDate: DateTime(2000),
                //   lastDate: DateTime(2100),
                //   decoration: InputDecoration(
                //     labelText: 'Expired At',
                //     suffixIcon: Icon(Icons.calendar_today),
                //     border: OutlineInputBorder(),
                //   ),
                //   // This prevents keyboard from appearing
                //   textInputAction: TextInputAction.none,
                //   // Handle tap to prevent keyboard
                //   onFieldSubmitted: (value) {
                //     _dateTimePickerFocusNode.unfocus();
                //   },
                // ),
                FormBuilderDateTimePicker(
                  name: 'expired_at',
                  focusNode: _dateTimePickerFocusNode,
                  inputType: InputType
                      .date, // Changed from 'both' to 'date' to show only date picker
                  initialValue: DateTime.now(),
                  format: DateFormat(
                    'yyyy-MM-dd',
                  ), // Changed format to match desired output
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  decoration: InputDecoration(
                    labelText: 'Expired At',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  valueTransformer: (value) {
                    if (value == null) return null;
                    // Format as "YYYY-MM-DD" without time
                    return "${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}";
                  },
                  // This prevents keyboard from appearing
                  textInputAction: TextInputAction.none,
                  // Handle tap to prevent keyboard
                  onFieldSubmitted: (value) {
                    _dateTimePickerFocusNode.unfocus();
                  },
                ),
                SizedBox(height: 20),

                QuoteTitle(
                  "Address Information",
                  "Information about the address related to quote.",
                ),
                SizedBox(height: 20),
                FormTextField(
                  name: "billing_address",
                  label: "Billing Address",
                  minLines: 1,
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                FormTextField(
                  name: "shipping_address",
                  label: "Shipping Address",
                  minLines: 1,
                  maxLines: 3,
                ),
                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Add Items",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    ElevatedButton(
                      onPressed: () {
                        print(_formKey.currentState!.value['items']);
                        qcontroller.items.add(
                          Items(
                            name: _formKey.currentState!.value['items.title'],
                            price: _formKey.currentState!.value['items.price'],
                            quantity:
                                _formKey.currentState!.value['items.quantity'],
                            taxPercent: _formKey
                                .currentState!
                                .value['items.tax_percent'],
                            discountPercent: _formKey
                                .currentState!
                                .value['items.discount_percent'],
                          ),
                        );
                        _formKey.currentState!.value['items.title'] = "";
                        _formKey.currentState!.value['items.price'] = "";
                        _formKey.currentState!.value['items.quantity'] = "";
                        _formKey.currentState!.value['items.tax_percent'] = "";
                        _formKey.currentState!.value['items.discount_percent'] =
                            "";
                      },
                      child: Text('Add Item'),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // // Product Dropdown (now stores the entire product object)
                // FormBuilderField<productRes.Data>(
                //   name:
                //       'items.product', // Changed to store the whole product object
                //   validator: FormBuilderValidators.required(
                //     errorText: 'Please select a product',
                //   ),
                //   builder: (FormFieldState<productRes.Data?> field) {
                //     final productList =
                //         productController.allProductsRes.value.data ?? [];

                //     return DropdownSearch<productRes.Data>(
                //       items: productList,
                //       itemAsString:
                //           (product) => product.name ?? 'Unnamed Product',
                //       onChanged: (selectedProduct) {
                //         field.didChange(selectedProduct);

                //         // When product changes, update all related fields
                //         if (selectedProduct != null) {
                //           _formKey.currentState?.fields['items.price']
                //               ?.didChange(selectedProduct.price?.numberDecimal);
                //           _formKey.currentState?.fields['items.quantity']
                //               ?.didChange('1');
                //           _formKey.currentState?.fields['items.title']
                //               ?.didChange(selectedProduct.name ?? '');
                //           // Set other default values as needed
                //         }
                //       },
                //       dropdownDecoratorProps: DropDownDecoratorProps(
                //         dropdownSearchDecoration: InputDecoration(
                //           labelText: "Select product",
                //           labelStyle: TextStyle(color: Colors.grey.shade500),
                //           border: OutlineInputBorder(),
                //           contentPadding: EdgeInsets.symmetric(horizontal: 12),
                //           errorText: field.errorText,
                //         ),
                //       ),
                //       popupProps: PopupProps.menu(
                //         showSearchBox: true,
                //         searchFieldProps: TextFieldProps(
                //           decoration: InputDecoration(
                //             hintText: "Search products...",
                //             border: OutlineInputBorder(),
                //             prefixIcon: Icon(Icons.search),
                //           ),
                //         ),
                //         itemBuilder: (context, product, isSelected) {
                //           return ListTile(
                //             title: Text(product.name ?? 'Unnamed Product'),
                //             subtitle:
                //                 product.description != null
                //                     ? Text(
                //                       product.description!,
                //                       maxLines: 1,
                //                       overflow: TextOverflow.ellipsis,
                //                       style: TextStyle(
                //                         color: Colors.grey.shade600,
                //                       ),
                //                     )
                //                     : null,
                //             trailing:
                //                 product.price?.numberDecimal != null
                //                     ? Text(
                //                       '\$${product.price!.numberDecimal}',
                //                       style: TextStyle(
                //                         fontWeight: FontWeight.bold,
                //                         color: Colors.green.shade700,
                //                       ),
                //                     )
                //                     : null,
                //             selected: isSelected,
                //           );
                //         },
                //       ),
                //     );
                //   },
                // ),

                // Product Dropdown (stores only the product ID)

                //
                // FormBuilderField<String>(
                //   name:
                //       'items.product_id', // Stores only the ID under items.product_id
                //   validator: FormBuilderValidators.required(
                //     errorText: 'Please select a product',
                //   ),
                //   builder: (FormFieldState<String?> field) {
                //     final productList =
                //         productController.allProductsRes.value.data ?? [];

                //     return DropdownSearch<productRes.Data>(
                //       items: productList,
                //       itemAsString: (product) =>
                //           product.name ?? 'Unnamed Product',
                //       onChanged: (selectedProduct) {
                //         // Store only the ID
                //         field.didChange(selectedProduct?.sId);

                //         // When product changes, update all related fields
                //         if (selectedProduct != null) {
                //           _formKey.currentState?.fields['items.price']
                //               ?.didChange(selectedProduct.price?.numberDecimal);
                //           _formKey.currentState?.fields['items.quantity']
                //               ?.didChange('1');
                //           _formKey.currentState?.fields['items.name']
                //               ?.didChange(selectedProduct.name);
                //           // Update other fields as needed
                //         }
                //       },
                //       dropdownDecoratorProps: DropDownDecoratorProps(
                //         dropdownSearchDecoration: InputDecoration(
                //           labelText: "Select product",
                //           labelStyle: TextStyle(color: Colors.grey.shade500),
                //           border: OutlineInputBorder(),
                //           contentPadding: EdgeInsets.symmetric(horizontal: 12),
                //           errorText: field.errorText,
                //         ),
                //       ),
                //       popupProps: PopupProps.menu(
                //         showSearchBox: true,
                //         searchFieldProps: TextFieldProps(
                //           decoration: InputDecoration(
                //             hintText: "Search products...",
                //             border: OutlineInputBorder(),
                //             prefixIcon: Icon(Icons.search),
                //           ),
                //         ),
                //         itemBuilder: (context, product, isSelected) {
                //           return ListTile(
                //             title: Text(product.name ?? 'Unnamed Product'),
                //             subtitle: product.description != null
                //                 ? Text(
                //                     product.description!,
                //                     maxLines: 1,
                //                     overflow: TextOverflow.ellipsis,
                //                     style: TextStyle(
                //                       color: Colors.grey.shade600,
                //                     ),
                //                   )
                //                 : null,
                //             trailing: product.price?.numberDecimal != null
                //                 ? Text(
                //                     '\$${product.price!.numberDecimal}',
                //                     style: TextStyle(
                //                       fontWeight: FontWeight.bold,
                //                       color: Colors.green.shade700,
                //                     ),
                //                   )
                //                 : null,
                //             selected: isSelected,
                //           );
                //         },
                //       ),
                //     );
                //   },
                // ),
                SizedBox(height: 20),

                // All other fields remain the same but will be nested under 'items'
                Row(
                  children: [
                    Expanded(
                      child: FormTextField(
                        name: "items.price",
                        label: "Price",
                        maxLength: 7,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: FormTextField(
                        name: "items.quantity",
                        label: "Quantity",
                        keyboardType: TextInputType.number,

                        maxLength: 4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: FormTextField(
                        name: "items.discount_percent",
                        label: "Discount Percent",
                        maxLength: 3,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: FormTextField(
                        name: "items.tax_percent",
                        label: "Tax Percent",
                        maxLength: 8,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: Text("Discount amount:")),
                    Text(qcontroller.discountAmount.toString()),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(child: Text("Tax amount:")),
                    Text(qcontroller.taxAmount.toString()),
                  ],
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(child: Text("Total amount:")),
                    Text(qcontroller.totalAmount.toString()),
                  ],
                ),
                SizedBox(height: 20),

                QuoteTitle(
                  "Quote Items",
                  "Add Product Request for this quote. ",
                ),
                SizedBox(height: 20),
                FormTextField(
                  name: 'adjustment_amount',
                  label: 'Enter adjustment amount',
                ),
                SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.grey.shade200,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Sub Total:",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            qcontroller.subTotal.value.toString(),
                            style: greyHeading,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Discount:",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            qcontroller.finalDiscountAmount.value.toString(),
                            style: greyHeading,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Tax:",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            qcontroller.finalTaxAmount.value.toString(),
                            style: greyHeading,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),

                      Divider(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Grand Total:",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            qcontroller.grandTotal.value.toString(),
                            style: greyHeading,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),

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
                            final formData = Map<String, dynamic>.from(
                              _formKey.currentState!.value,
                            );

                            // Prepare the final payload
                            final payload = {
                              ...formData,
                              'items': qcontroller.items
                                  .map((item) => item.toJson())
                                  .toList(),
                            };
                            //var formData = _formKey.currentState!.value;
                            //formData['items'] = qcontroller.items;
                            print(payload);
                            //quotesController.createQuote(formData);
                          }
                          print(qcontroller.items.toJson());
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
