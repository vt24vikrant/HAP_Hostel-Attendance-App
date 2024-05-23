import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            children: [
              //logo
              Icon(Icons.person,
              size:80 ,
              color: Theme.of(context).colorScheme.inversePrimary,)
              //appname

              //username

              //password

              //forgot password

              //sign in

              //don't have acc
            ],
          ),
        ));
  }
}
