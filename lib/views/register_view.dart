import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

import 'package:mynotes/constants/routes.dart';
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
                          
                          try {
      
                            // final userCredential = 
                            await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: email, 
                              password: password,
                            );
                            final user = FirebaseAuth.instance.currentUser;
                            await user?.sendEmailVerification();
                            Navigator.of(context).pushNamed(verifyEmailRoute);

                            // devtools.log(userCredential.toString());

                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password')
                             {
                              await showErrorDialog(context,
                              'Weak password',
                              );
                            }
                            else if(e.code == "email-already-in-use")
                            {
                              await showErrorDialog(
                                context,
                                'Email already in use',
                              );
                            }
                            else if (e.code == 'invalid-email')
                            {
                               await showErrorDialog(
                                context,
                                'Invalid email address',
                              );
                            }
                            else
                            {
                              await showErrorDialog(context,
                              'Error ${e.code}',
                              );
                            }
                         } catch (e)
                         {
                          await showErrorDialog(
                              context,
                              e.toString(),
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