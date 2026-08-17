import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  late final AuthController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
  }

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

                  // =================================================
                  // IMPORTANT
                  // Groups email + password for Autofill
                  // =================================================
                  child: AutofillGroup(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // =================================================
                        // Title
                        // =================================================

                        Text(
                          controller.isLogin.value
                              ? "Welcome Back!"
                              : "Create New Account",
                          style: TextStyle(
                            color:
                                ColorConstants.MainPurpleBackground,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          controller.isLogin.value
                              ? "Sign in to continue"
                              : "Get your free account now",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =================================================
                        // Full Name - Signup only
                        // =================================================

                        if (!controller.isLogin.value)
                          FormBuilderTextField(
                            name: 'name',
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter Full Name',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              prefixIcon:
                                  const Icon(Icons.person),
                            ),
                          ),

                        if (!controller.isLogin.value)
                          const SizedBox(height: 20),

                        // =================================================
                        // Company Name - Signup only
                        // =================================================

                        if (!controller.isLogin.value)
                          FormBuilderTextField(
                            name: 'tenantName',
                            decoration: InputDecoration(
                              labelText: 'Company Name',
                              hintText: 'Enter Company Name',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              prefixIcon:
                                  const Icon(Icons.business),
                            ),
                          ),

                        if (!controller.isLogin.value)
                          const SizedBox(height: 20),

                        // =================================================
                        // EMAIL
                        // =================================================

                        FormBuilderTextField(
                          name: 'email',

                          // Tell Android/iOS this is a username/email.
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],

                          keyboardType:
                              TextInputType.emailAddress,

                          textInputAction:
                              TextInputAction.next,

                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            prefixIcon:
                                const Icon(Icons.email),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =================================================
                        // PASSWORD
                        // =================================================

                        FormBuilderTextField(
                          name: 'password',

                          // Tell Android/iOS this is a password.
                          autofillHints: const [
                            AutofillHints.password,
                          ],

                          obscureText:
                              controller.showPass.value,

                          textInputAction:
                              TextInputAction.done,

                          decoration: InputDecoration(
                            suffixIcon:
                                GestureDetector(
                              onTap: () {
                                controller.showPass.value =
                                    !controller
                                        .showPass
                                        .value;
                              },
                              child: Icon(
                                controller.showPass.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),

                            labelText: 'Password',
                            hintText:
                                'Enter your password',

                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                            ),

                            prefixIcon:
                                const Icon(Icons.lock),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =================================================
                        // Login / Signup Button
                        // =================================================

                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton(
                            onPressed: () async {
                              final isValid = _formKey
                                      .currentState
                                      ?.saveAndValidate() ??
                                  false;

                              if (!isValid) {
                                return;
                              }

                              final formData =
                                  _formKey.currentState!.value;

                              // ===========================================
                              // SIGN UP
                              // ===========================================

                              if (!controller.isLogin.value) {
                                controller.register(
                                  formData,
                                  context,
                                );

                                _formKey.currentState?.reset();

                                return;
                              }

                              // ===========================================
                              // LOGIN
                              // ===========================================

                              final requestData = {
                                ...formData,
                                "isMobile": true,
                              };

                              await controller.login(
                                requestData,
                                context,
                              );
                            },

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  ColorConstants
                                      .MainPurpleBackground,

                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 15,
                              ),

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),

                            child: Text(
                              controller.isLogin.value
                                  ? 'Sign In'
                                  : 'Sign Up',

                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // =================================================
                        // Switch Login / Signup
                        // =================================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            Text(
                              controller.isLogin.value
                                  ? "Don't have an account? "
                                  : "Already have an account ?",
                            ),

                            const SizedBox(width: 10),

                            GestureDetector(
                              onTap: () {
                                controller.isLogin.value =
                                    !controller
                                        .isLogin
                                        .value;

                                _formKey.currentState
                                    ?.reset();
                              },

                              child: Text(
                                controller.isLogin.value
                                    ? 'Sign Up'
                                    : "Sign In",

                                style: TextStyle(
                                  color: ColorConstants
                                      .MainPurpleBackground,

                                  decoration:
                                      TextDecoration
                                          .underline,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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