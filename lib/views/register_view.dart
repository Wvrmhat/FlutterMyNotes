import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _passowrd;

  @override
  void initState() {
    _email = TextEditingController();
    _passowrd = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _passowrd.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Column(
                  children: [
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                      ),
                    ),
                    TextField(
                      controller: _passowrd,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                      ),
                    ),
                    TextButton(
                        onPressed: () async {
                  
                          final email = _email.text;
                          final password = _passowrd.text;
                          
                          try {                   // uses authervice and handles auth related exceptions
                            AuthService.firebase().createUser(email: email, password: password,);
                            AuthService.firebase().sendEmailVerification();     // verifies email from authservice

                            Navigator.of(context).pushNamed(verifyEmailRoute);

                            // devtools.log(userCredential.toString());
                          } on WeakPasswordAuthException {
                             await showErrorDialog(context,
                              'Weak password',
                              );
                          } on EmailAlreadyInUseAuthException {
                            await showErrorDialog(
                                context,
                                'Email already in use',
                              );

                          } on InvalidEmailAuthException {
                            await showErrorDialog(
                                context,
                                'Invalid email address',
                              );

                          } on GenericAuthException {
                             await showErrorDialog(context,
                              'Failed to register',
                              );
                          } 

                        },
                        child: const Text('Register'),
                    
                      ),
                      TextButton(onPressed: () {
                         Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, 
                          (route) => false,
                        );

                      },
                      child: const Text("Already registered? Login Here!"),
                    )
                  ],
                ),
    );
  // State<MyHomePage> createState() => _MyHomePageState();
  }
}