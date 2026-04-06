import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/pages/Auth/AuthController.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        controller.isLogin.value
                            ? "Welcome Back!"
                            : "Create New Account",
                        style: TextStyle(
                          color: ColorConstants.MainPurpleBackground,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        controller.isLogin.value
                            ? "Sign in to continue"
                            : "Get your free account now",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (controller.isLogin.value == false)
                        FormBuilderTextField(
                          name: 'name',
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                        ),
                      if (controller.isLogin.value == false)
                        const SizedBox(height: 20),
                      if (controller.isLogin.value == false)
                        FormBuilderTextField(
                          name: 'tenantName',
                          decoration: InputDecoration(
                            labelText: 'Company Name',
                            hintText: 'Enter Company Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                        ),
                      if (controller.isLogin.value == false)
                        const SizedBox(height: 20),
                      FormBuilderTextField(
                        name: 'email',
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        name: 'password',
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            onTap: () {
                              controller.showPass.value =
                                  !controller.showPass.value;
                            },
                            child: Icon(
                              controller.showPass.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        obscureText: controller.showPass.value,
                      ),
                      const SizedBox(height: 20),

                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       // Handle forgot password navigation
                      //     },
                      //     child: Text(
                      //       controller.isLogin.value ? 'Forgot Password?' : '',
                      //       style: TextStyle(
                      //         color: ColorConstants.MainPurpleBackground,
                      //         fontWeight: FontWeight.w500,
                      //         decoration: TextDecoration.underline,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Get.rawSnackbar(message: "TEST");
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final formData = _formKey.currentState!.value;
                              if (controller.isLogin.value == false) {
                                ScaffoldMessenger.of(Get.context!).showSnackBar(
                                  const SnackBar(
                                    content: Text("User not found!"),
                                  ),
                                );
                                controller.register(formData, context);
                                _formKey.currentState?.reset();
                              }
                              // else {
                              //   controller.login(formData, context);
                              // }
                              else {
                                final requestData = {
                                  ...formData,
                                  "isMobile": true,
                                };

                                controller.login(requestData, context);
                              }

                              // Handle login logic here
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                ColorConstants.MainPurpleBackground,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            controller.isLogin.value ? 'Sign In' : 'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 40),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(
                      //       controller.isLogin.value
                      //           ? "Don't have an account? "
                      //           : "Already have an account ?",
                      //     ),
                      //     SizedBox(width: 10),
                      //     GestureDetector(
                      //       onTap: () {
                      //         controller.isLogin.value =
                      //             !controller.isLogin.value;
                      //         _formKey.currentState!.reset();
                      //       },
                      //       child: Text(
                      //         controller.isLogin.value ? 'Sign Up' : "Sign In",
                      //         style: TextStyle(
                      //           color: ColorConstants.MainPurpleBackground,
                      //           decoration: TextDecoration.underline,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
