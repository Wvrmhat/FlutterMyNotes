
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/constants/routes.dart';

import 'package:mynotes/utilities/show_error_dialog.dart';


class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
      appBar: AppBar(
        title: const Text("Login"),
      ),
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
                          
                          try {
                                final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: email, 
                                password: password,
                             );
                          
                            devtools.log(userCredential.toString());

                            Navigator.of(context).pushNamedAndRemoveUntil(
                              notesRoute, 
                              (route) => false);

                          } on FirebaseAuthException catch (e) {                    
                            // print("Something bad happened");
                            // print(e.runtimeType);
                            if (e.code == 'unknown-error')
                            {
                              await showErrorDialog(
                                context, 
                                'User not found',
                              );
                              // devtools.log('User not found');
                            }
                            else if (e.code == 'wrong-password') {
                               await showErrorDialog(
                                context, 
                                'Wrong credentials',
                              );
                              // devtools.log("Wrong password");
                            }
                            else 
                            {
                              await showErrorDialog(
                                context, 
                                'Error: ${e.code}',
                              );
                            }
                          } catch (e) {
                             await showErrorDialog(
                              context, 
                              e.toString(),
                            );
                          }
                          
                        },
                        child: const Text('Login'),
                    
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute, 
                            (route) => false,
                          );
      
                        },
                        child: const Text ("Not Registered yet? Register here!"),
                      )
      
                  ],
                ),
    );
  // State<MyHomePage> createState() => _MyHomePageState();
  }
}


