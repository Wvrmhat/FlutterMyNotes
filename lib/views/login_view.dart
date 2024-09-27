import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
// import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  // CloseDialog? _closeDialogHandle;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          // final closeDialog = _closeDialogHandle;

          // if (!state.isLoading && closeDialog != null)
          // {
          //   closeDialog();
          //   _closeDialogHandle = null;
          // } else if (state.isLoading && closeDialog == null) {
          //   _closeDialogHandle = showLoadingDialog(
          //   context: context,
          //   text: 'Loading...',
          //   );
          // }

            if (state.exception is UserNotFoundAuthException) 
            {
              await showErrorDialog(context, 'Cannot find user with entered credentials');
            } 
             else if (state.exception is WrongPasswordAuthException) 
             {
                await showErrorDialog(context, 'Wrong credentials');
             } 
            else if (state.exception is GenericAuthException) 
            {
              await showErrorDialog(context, 'Authentication error');
            }
          }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Log in to your account to interact and create your notes."
              ),
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
                controller: _password,
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
                  final password = _password.text;
          
                  // try {
                  // await AuthService.firebase().logIn(
                  //   email: email,
                  //   password: password,
                  // );
                  // final user = AuthService.firebase().currentUser;
                  // if (user?.isEmailVerified ?? false) {
                  //   Navigator.of(context)
                  //       .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  // } else {
                  //   Navigator.of(context).pushNamedAndRemoveUntil(
                  //       verifyEmailRoute, (route) => false);
                  // }
          
                  context.read<AuthBloc>().add(
                        AuthEventLogIn(
                          email,
                          password,
                        ),
                      );
                  // devtools.log(userCredential.toString());
                  //   } on UserNotFoundAuthException {
                  //     await showErrorDialog(
                  //       context,
                  //       'User not found',
                  //     );
                  //   } on WrongPasswordAuthException {
                  //     await showErrorDialog(
                  //       context,
                  //       'Wrong credentials',
                  //     );
                  //   } on GenericAuthException {
                  //     await showErrorDialog(
                  //       context,
                  //       'Authentication error',
                  //     );
                  //   }
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    const AuthEventForgotPassword(),
                  );
          
                },
                child: const Text("I forgot my password"),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    const AuthEventShouldRegister(),
                  );
                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //   registerRoute,
                  //   (route) => false,
                  // );
                },
                child: const Text("Not Registered yet? Register here!"),
              )
            ],
          ),
        ),
      ),
    );
    // State<MyHomePage> createState() => _MyHomePageState();
  }
}
