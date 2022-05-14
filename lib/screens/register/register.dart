import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/screens/register/register_controller.dart';

import '../../models/download_state.dart';
import '../../shared/components.dart';
import '../login/login.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({Key? key}) : super(key: key);

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final RegisterController registerController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return Scaffold(
          body: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'REGISTER ',
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            ?.copyWith(fontSize: 32),
                      ),
                      Text(
                        'Register to challenge friends and view your statistics ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        onTap: () {
                          registerController.getImageFromGallery();
                        },
                        child: registerController.pickedImageObs.value == null
                            ? CircleAvatar(
                                radius: 50,
                                child: Image.asset(
                                  'assets/images/user.png',
                                  width: 200,
                                  height: 200,
                                ),
                              )
                            : ClipOval(
                                child: Image.file(
                                  registerController.pickedImageObs.value ??
                                      File(''),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      DefaultFormField(
                        labelText: 'Name',
                        controller: nameController,
                        prefixIcon: const Icon(Icons.account_circle),
                        validator: (value) {
                          if (value.toString().isEmpty) {
                            return 'Please enter your name';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      DefaultFormField(
                        labelText: 'Email address',
                        controller: emailController,
                        prefixIcon: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value.toString().isEmpty) {
                            return 'Please enter Email address';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      DefaultFormField(
                        labelText: 'Password',
                        controller: passwordController,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            registerController.changePasswordVisibility();
                          },
                          icon: registerController.isPasswordVisible.value
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                        obscureText:
                            !registerController.isPasswordVisible.value,
                        validator: (value) {
                          if (value.toString().isEmpty) {
                            return 'Please enter password';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      registerController.downloadState.value ==
                              DownloadState.LOADING
                          ? DefaultButton(isLoading: true)
                          : DefaultButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  registerController.register(
                                    email: emailController.text,
                                    password: passwordController.text,
                                    name: nameController.text,
                                  );
                                }
                              },
                              text: 'register'),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          TextButton(
                            onPressed: () {
                              Get.off(
                                () => LoginScreen(),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.blue),
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
          // This trailing comma makes auto-formatting nicer for build methods.
        );
      }),
    );
  }
}
