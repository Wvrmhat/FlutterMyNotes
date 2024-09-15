import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';

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
      appBar: AppBar(
        title: const Text('Register'),
    ),
    body: FutureBuilder(
      future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),

      builder: (context, snapshot) { 
        switch (snapshot.connectionState) {
          

          case ConnectionState.done:
            
            return Column(
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

                          final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: email, 
                            password: password,
                          );
                          print(userCredential);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password')
                           {
                            print('weak password');
                          }
                          else if(e.code == "email-already-in-use")
                          {
                            print("Email already in use");
                          }
                          else if (e.code == 'invalid-email')
                          {
                            print("Invalid email entered");
                          }
                       }
                      },
                      child: const Text('Register'),
                  
                    ),
                ],
              );
              default: 
              return const Text('Loading...');
            }
          }, 
        ),  
      );
  // State<MyHomePage> createState() => _MyHomePageState();
  }
}